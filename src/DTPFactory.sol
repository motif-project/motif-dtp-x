// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol"; 
import "./DTPToken.sol";
import "./interfaces/IDTPFactory.sol";
import "./interfaces/IMFTRegistry.sol";
import "./interfaces/IAppRegistry.sol";
import {IBitcoinPodManager} from "@BitDSM/interfaces/IBitcoinPodManager.sol";
import {IBitcoinPod} from "@BitDSM/interfaces/IBitcoinPod.sol";
/**
 * @title DTPFactory
 * @notice Factory contract for creating new DTP tokens
 */
contract DTPFactory is 
    IDTPFactory,
    Initializable, 
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC1271
{

     modifier onlyPodOwner(address pod) {
        require(
            IBitcoinPodManager(bitcoinPodManager).getUserPod(msg.sender) == pod,
            "Caller is not the pod owner"
        );
        _;
    }

    address public mftRegistry;
    address public appRegistry;
    IBitcoinPodManager public bitcoinPodManager;
    // total btc amount delegated to the factory
    uint256 public lockedBitcoinAmount;
    // storage for bitcoin pods
    address[] public bitcoinPods;
    // mapping to check if a pod is locked
    mapping(address => bool) public lockedPods;
    // Add mapping to track which DTP a pod is assigned to
    mapping(address => address) public podToDtp;
    
    // magic value constants for EIP-1271
    bytes4 internal constant _MAGICVALUE = 0x1626ba7e;
    bytes4 internal constant _INVALID_SIGNATURE = 0xffffffff;

    event DTPCreated(
        address indexed dtp,
        address indexed creator,
        string name,
        string symbol,
        address operator
    );

    event PodAssignedToDTP(address indexed dtp, address indexed pod);
    event PodUnassignedFromDTP(address indexed dtp, address indexed pod);


    function initialize(
        address _mftRegistry,
        address _appRegistry,
        address _bitcoinPodManager
    ) external initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        mftRegistry = _mftRegistry;
        appRegistry = _appRegistry;
        bitcoinPodManager = IBitcoinPodManager(_bitcoinPodManager);
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
            address(this)
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
    function isValidSignature(
        bytes32 _hash,
        bytes memory _signature
    ) external view override (IERC1271, IDTPFactory) returns (bytes4) {
        // Recover the signer from the signature
        address signer = ECDSA.recover(_hash, _signature);
        // Check if the signer is the owner
        if (signer == owner()) {
            return _MAGICVALUE;
        }
        return _INVALID_SIGNATURE;
    }
    
    function updateAppMetadataURI(
        string calldata metadataURI
    ) external {
        // check if app is registered
        require(
            IAppRegistry(appRegistry).isAppRegistered(address(this)),
            "App not registered"
        );
        // update metadataURI
        IAppRegistry(appRegistry).updateAppMetadataURI(metadataURI);
    }

    function lockBitcoinPod(
        address pod
    ) external onlyPodOwner(pod){
        // check if the pod has been assigned to DTPFactory
        require(
            IAppRegistry(appRegistry).isAppRegistered(address(this)),
            "App not registered"
        );
        bitcoinPodManager.lockPod(pod);
        lockedPods[pod] = true;
        bitcoinPods.push(pod);
        lockedBitcoinAmount += IBitcoinPod(pod).getBitcoinBalance();
    }

    function _unlockBitcoinPod(
        address pod
    ) internal {
        bitcoinPodManager.unlockPod(pod);
        lockedPods[pod] = false;
        // remove pod from bitcoinPods array
        for (uint256 i = 0; i < bitcoinPods.length; i++) {
            if (bitcoinPods[i] == pod) {
                bitcoinPods[i] = bitcoinPods[bitcoinPods.length - 1];
                bitcoinPods.pop();
            }
        }
        lockedBitcoinAmount -= IBitcoinPod(pod).getBitcoinBalance();
    }

    /**
     * @notice Assigns a locked pod to a DTP token
     * @param dtp Address of the DTP token
     * @param pod Address of the pod to assign
     */
    function assignPodToDtp(address dtp, address pod) external onlyPodOwner(pod) {
        // check if the pod has been assigned to DTPFactory
        require(lockedPods[pod], "Pod must be locked first");
        require(podToDtp[pod] == address(0), "Pod already assigned to a DTP");
        
        DTPToken(dtp).assignPod(pod);
        // mint the pod value to the DTP
        DTPToken(dtp).mint(msg.sender, IBitcoinPod(pod).getBitcoinBalance());
        podToDtp[pod] = dtp;
        emit PodAssignedToDTP(dtp, pod);
    }

    /**
     * @notice Removes a pod assignment from a DTP token
     * @param dtp Address of the DTP token
     * @param pod Address of the pod to unassign
     */
    function unassignPodFromDtp(address dtp, address pod) external onlyPodOwner(pod) {
        require(podToDtp[pod] == dtp, "Pod not assigned to this DTP");
        // check if the burn balance is equal to the pod balance
        require(
            DTPToken(dtp).balanceOf(msg.sender) == IBitcoinPod(pod).getBitcoinBalance(),
            "Burn balance is not equal to the pod balance"
        );
        // burn the pod value from the DTP
        DTPToken(dtp).burn(msg.sender, IBitcoinPod(pod).getBitcoinBalance());
        // unassign the pod from the DTP
        DTPToken(dtp).unassignPod(pod);
        podToDtp[pod] = address(0);
        emit PodUnassignedFromDTP(dtp, pod);
    }

    /**
     * @notice Lock a pod and assign it to a DTP in one transaction
     * @param dtp Address of the DTP token
     * @param pod Address of the pod to lock and assign
     */
    function lockAndAssignPodMintDTP(address dtp, address pod, address mintTo) external onlyPodOwner(pod) {
        // check if the pod has been assigned to DTPFactory
        require(
            IAppRegistry(appRegistry).isAppRegistered(address(this)),
            "App not registered"
        );
        require(podToDtp[pod] == address(0), "Pod already assigned to a DTP");
        
        // First lock the pod
        bitcoinPodManager.lockPod(pod);
        lockedPods[pod] = true;
        bitcoinPods.push(pod);
        lockedBitcoinAmount += IBitcoinPod(pod).getBitcoinBalance();
        
        // Then assign it to the DTP
        DTPToken(dtp).assignPod(pod);
        // mint the pod value to the DTP
        DTPToken(dtp).mint(mintTo, IBitcoinPod(pod).getBitcoinBalance());
        podToDtp[pod] = dtp;
        emit PodAssignedToDTP(dtp, pod);
    }

    function burnAndUnassignDTP(address dtp, address pod, address burnFrom) external onlyPodOwner(pod) {
        // check if the burn address contains the same amount of DTP tokens as the pod
        require(
            DTPToken(dtp).balanceOf(burnFrom) == IBitcoinPod(pod).getBitcoinBalance(),
            "Burn address does not contain the same amount of DTP tokens as the pod"
        );
        // burn the pod value from the DTP
        DTPToken(dtp).burn(burnFrom, IBitcoinPod(pod).getBitcoinBalance());
        // unassign the pod from the DTP
        DTPToken(dtp).unassignPod(pod);
        podToDtp[pod] = address(0);
        emit PodUnassignedFromDTP(dtp, pod);
    }

    function unlockBitcoinPod(address pod) external onlyPodOwner(pod) {
        // revert if the pod is not locked
        require(lockedPods[pod], "Pod is not locked");
        // revert if the pod is assigned to any DTP
        require(podToDtp[pod] == address(0), "Pod is assigned to a DTP");
        _unlockBitcoinPod(pod);
    }
    /**
     * @notice Check if a pod is assigned to any DTP
     * @param pod Address of the pod to check
     * @return bool Whether the pod is assigned
     * @return address The DTP address the pod is assigned to (zero address if unassigned)
     */
    function getPodAssignment(address pod) external view returns (bool, address) {
        address assignedDtp = podToDtp[pod];
        return (assignedDtp != address(0), assignedDtp);
    }

    function getPodBalance(address pod) external view returns (uint256) {
        return IBitcoinPod(pod).getBitcoinBalance();
    }

    function getLockedBitcoinAmount() external view returns (uint256) {
        return lockedBitcoinAmount;
    }

    function getAllBitcoinPods() external view returns (address[] memory) {
        return bitcoinPods;
    }

    function getAssignedPods(address dtp) external view returns (address[] memory) {
        return DTPToken(dtp).getAssignedPods();
    }

    function getCurrentSupply(address dtp) external view returns (uint256) {
        return DTPToken(dtp).currentSupply();
    }
} 
