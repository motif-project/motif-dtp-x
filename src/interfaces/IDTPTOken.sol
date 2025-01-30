// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IDTPToken {
    function initialize(
        string memory name,
        string memory symbol,
        address owner,
        address operator,
        address bitcoinPodManager
    ) external;

    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
} 