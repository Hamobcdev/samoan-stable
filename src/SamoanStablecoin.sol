// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SamoanStablecoin is ERC20, AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant PRICE_UPDATER_ROLE =
        keccak256("PRICE_UPDATER_ROLE");

    AggregatorV3Interface private priceFeed;
    uint256 public lastUpdatedPrice;
    uint256 public constant PRICE_PRECISION = 1e8;

    event PriceUpdated(uint256 newPrice);

    constructor(address _priceFeed) ERC20("Samoan Stablecoin", "SAMOA") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(PRICE_UPDATER_ROLE, msg.sender);

        priceFeed = AggregatorV3Interface(_priceFeed);
        updatePrice();
    }

    function mint(
        address to,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) whenNotPaused nonReentrant {
        _mint(to, amount);
    }

    function burn(
        address from,
        uint256 amount
    ) external onlyRole(BURNER_ROLE) whenNotPaused nonReentrant {
        _burn(from, amount);
    }

    function updatePrice() public onlyRole(PRICE_UPDATER_ROLE) whenNotPaused {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        lastUpdatedPrice = uint256(price);
        emit PriceUpdated(lastUpdatedPrice);
    }

    function getLatestPrice() public view returns (uint256) {
        return lastUpdatedPrice;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // Override required by Solidity
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC20, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
