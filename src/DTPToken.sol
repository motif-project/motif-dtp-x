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
    address public bitcoinPodManager;
    
    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator can call");
        _;
    }

    modifier onlyPodManager() {
        require(msg.sender == bitcoinPodManager, "Only pod manager can call");
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address owner,
        address _operator,
        address _bitcoinPodManager
    ) external initializer {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        transferOwnership(owner);
        operator = _operator;
        bitcoinPodManager = _bitcoinPodManager;
    }

    function mint(address to, uint256 amount) external onlyPodManager {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyPodManager {
        _burn(from, amount);
    }
} 