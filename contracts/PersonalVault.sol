// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PersonalVault {
    address public owner;           // Who owns this vault
    uint256 public unlockTime;      // When funds become available
    
    // Events resmi sesuai spesifikasi brief
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Custom errors (Ditambahkan BalanceZero & TransferFailed sesuai Warning 1)
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();
    error BalanceZero();
    error TransferFailed();

    // Pola Kontrol Akses (Access Control Pattern)
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // Constructor - Fix Warning 1 & Warning 3
    constructor(uint256 _unlockTime) payable {
        if (_unlockTime <= block.timestamp) revert InvalidUnlockTime();
        owner = msg.sender;
        unlockTime = _unlockTime;
        
        // Memancarkan event deposit jika ada ETH saat deployment
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    // 1. Fungsi Setoran (Deposit)
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 2. Fungsi Penarikan (Withdraw) - Fix Warning 1 & CEI Pattern
    function withdraw() public onlyOwner {
        // ---- 1. CHECKS ----
        if (block.timestamp < unlockTime) revert FundsLocked();
        
        uint256 balance = address(this).balance;
        if (balance == 0) revert BalanceZero();
        
        // ---- 2. EFFECTS ----
        emit Withdrawal(balance, block.timestamp);
        
        // ---- 3. INTERACTIONS ----
        (bool success, ) = payable(owner).call{value: balance}("");
        if (!success) revert TransferFailed();
    }

    // 3. Fungsi Perpanjang Kunci (Extend Lock)
    function extendLock(uint256 newTime) public onlyOwner {
        if (newTime <= unlockTime) revert InvalidUnlockTime();
        unlockTime = newTime;
        emit LockExtended(newTime);
    }

    // Fix Warning 2: Menerima transfer ETH langsung ke alamat kontrak
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}