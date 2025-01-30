// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IMFTRegistry {
    struct DTPMetadata {
        string name;
        string symbol;
        string imageUri;
        address creator;
        address operator;
        uint256 createdAt;
    }

    function registerDTP(
        address dtp,
        address creator,
        string memory name,
        string memory symbol,
        string memory imageUri,
        address operator
    ) external;

    function getDTPMetadata(address dtp) external view returns (DTPMetadata memory);
    function getUserDTPs(address user) external view returns (address[] memory);
    function getAllDTPs() external view returns (address[] memory);
} 