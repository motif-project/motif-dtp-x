// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IDTPFactory {
    function createDTP(
        string memory name,
        string memory symbol,
        string memory imageUri,
        address operator
    ) external returns (address);
} 