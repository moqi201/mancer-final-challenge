// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PersonalVault {
    address public owner;           // Who owns this vault
    uint256 public unlockTime;      // When funds become available
    
    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Custom errors
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Access Control Pattern
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // Constructor
    constructor(uint256 _unlockTime) payable {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    // 1. Deposit Function
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 2. Withdraw Function
    function withdraw() public onlyOwner {
        // Time Handling
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }
        
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        
        // Safe ETH transfer using call
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(balance, block.timestamp);
    }

    // 3. Extend Lock Function
    function extendLock(uint256 newTime) public onlyOwner {
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }
        unlockTime = newTime;
        emit LockExtended(newTime);
    }
}