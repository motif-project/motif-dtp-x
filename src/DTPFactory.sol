// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "./DTPToken.sol";
import "./interfaces/IDTPFactory.sol";

/**
 * @title DTPFactory
 * @notice Factory contract for creating new DTP tokens
 */
contract DTPFactory is 
    IDTPFactory,
    Initializable, 
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable 
{
    address public mftRegistry;
    address public appRegistry;
    address public bitcoinPodManager;

    event DTPCreated(
        address indexed dtp,
        address indexed creator,
        string name,
        string symbol,
        address operator
    );

    function initialize(
        address _mftRegistry,
        address _appRegistry,
        address _bitcoinPodManager
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        mftRegistry = _mftRegistry;
        appRegistry = _appRegistry;
        bitcoinPodManager = _bitcoinPodManager;
    }

    function createDTP(
        string memory name,
        string memory symbol,
        string memory imageUri,
        address operator
    ) external nonReentrant returns (address) {
        // Deploy new DTP token
        DTPToken dtp = new DTPToken();
        
        // Initialize token
        dtp.initialize(
            name,
            symbol,
            msg.sender,
            operator,
            bitcoinPodManager
        );

        // Register DTP in registry
        IMFTRegistry(mftRegistry).registerDTP(
            address(dtp),
            msg.sender,
            name,
            symbol,
            imageUri,
            operator
        );

        emit DTPCreated(
            address(dtp),
            msg.sender,
            name,
            symbol,
            operator
        );

        return address(dtp);
    }
} 