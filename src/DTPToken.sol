// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "./interfaces/IDTPToken.sol";

/**
 * @title DTPToken
 * @notice ERC20 token representing a Bitcoin DTP
 */
contract DTPToken is 
    IDTPToken,
    ERC20Upgradeable,
    OwnableUpgradeable 
{
    address public operator;
    address public dtpFactory;
    uint256 public currentSupply;

    // Array to store assigned pod addresses
    address[] public assignedPods;
    // Mapping to efficiently check if a pod is assigned
    mapping(address => bool) public isPodAssigned;

    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator can call");
        _;
    }

    modifier onlyDtpFactory() {
        require(msg.sender == dtpFactory, "Only DTP factory can call");
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address owner,
        address _operator,
        address _dtpFactory
    ) external initializer {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        transferOwnership(owner);
        operator = _operator;
        dtpFactory = _dtpFactory;
    }

    function mint(address to, uint256 satAmount) external onlyDtpFactory {
        // convert sat in 10^8 to erc20 in 10^18
        uint256 erc20Amount = satAmount * 10 ** 10;
        _mint(to, erc20Amount);
        currentSupply += erc20Amount;
    }

    function burn(address from, uint256 satAmount) external onlyDtpFactory {
        // convert sat in 10^8 to erc20 in 10^18
        uint256 erc20Amount = satAmount * 10 ** 10;
        _burn(from, erc20Amount);
        currentSupply -= erc20Amount;
    }

    /**
     * @notice Assigns a pod to this DTP token
     * @param pod Address of the pod to assign
     */
    function assignPod(address pod) external onlyDtpFactory {
        require(!isPodAssigned[pod], "Pod already assigned");
        isPodAssigned[pod] = true;
        assignedPods.push(pod);
    }

    /**
     * @notice Removes a pod assignment from this DTP token
     * @param pod Address of the pod to unassign
     */
    function unassignPod(address pod) external onlyDtpFactory {
        require(isPodAssigned[pod], "Pod not assigned");
        isPodAssigned[pod] = false;
        
        // Remove pod from array
        for (uint256 i = 0; i < assignedPods.length; i++) {
            if (assignedPods[i] == pod) {
                assignedPods[i] = assignedPods[assignedPods.length - 1];
                assignedPods.pop();
                break;
            }
        }
    }

    /**
     * @notice Returns all pods assigned to this DTP token
     * @return Array of pod addresses
     */
    function getAssignedPods() external view returns (address[] memory) {
        return assignedPods;
    }

    function getCurrentSupply() external view returns (uint256) {
        return currentSupply;
    }
    function isPodAssignedToDtp(address pod) external view returns (bool) {
        return isPodAssigned[pod];
    }
} 

