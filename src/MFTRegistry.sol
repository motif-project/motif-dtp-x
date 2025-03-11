// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "./interfaces/IMFTRegistry.sol";

/**
 * @title MFTRegistry
 * @notice Registry for tracking all DTPs created through Motif
 */
contract MFTRegistry is 
    IMFTRegistry,
    Initializable, 
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable 
{
    // Mapping from DTP token address to metadata
    mapping(address => DTPMetadata) public dtpMetadata;
    
    // Mapping from user address to their DTP tokens
    mapping(address => address[]) public userDTPs;
    
    // Array of all DTP tokens
    address[] public allDTPs;

    // Motif registry address
    address public motifRegistry;

    event DTPCreated(
        address indexed dtp,
        address indexed creator,
        string name,
        string symbol,
        address operator
    );

    function initialize(address _motifRegistry) external initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();
        __ReentrancyGuard_init();
        motifRegistry = _motifRegistry;
    }

    function registerDTP(
        address dtp,
        address creator,
        string memory name,
        string memory symbol,
        string memory imageUri,
        address operator
    ) external whenNotPaused nonReentrant {
        require(dtp != address(0), "Invalid DTP address");
        require(dtpMetadata[dtp].creator == address(0), "DTP already registered");

        dtpMetadata[dtp] = DTPMetadata({
            name: name,
            symbol: symbol,
            imageUri: imageUri,
            creator: creator,
            operator: operator,
            createdAt: block.timestamp
        });

        userDTPs[creator].push(dtp);
        allDTPs.push(dtp);

        emit DTPCreated(dtp, creator, name, symbol, operator);
    }

    function getDTPMetadata(address dtp) external view returns (DTPMetadata memory) {
        return dtpMetadata[dtp];
    }

    function getUserDTPs(address user) external view returns (address[] memory) {
        return userDTPs[user];
    }

    function getAllDTPs() external view returns (address[] memory) {
        return allDTPs;
    }
} 