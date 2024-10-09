// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SamoanStablecoin is ERC20, Ownable {
    constructor() ERC20("Samoan Stablecoin", "HAMO") Ownable(msg.sender) {
        // Constructor logic here
    }

    // Additional functions will be added here
}
