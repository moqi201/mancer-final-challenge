// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PersonalVault {
    // Alamat dompet milik pemilik brankas
    address public owner;
    
    // Batas waktu kapan dana bisa diambil
    uint256 public unlockTime;
    
    // Deklarasi seluruh event sesuai spesifikasi brief
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Deklarasi custom error hemat gas sesuai spesifikasi brief
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Satpam pembatas hak akses pemilik
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    // Pembuatan kontrak pertama kali dengan penentuan waktu awal
    constructor(uint256 _unlockTime) payable {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }
    
    // Fungsi untuk menerima setoran koin dari pemilik
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    // Fungsi untuk mengambil seluruh dana jika waktu sudah terpenuhi
    function withdraw() public onlyOwner {
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }
        
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        
        // Mengirim koin menggunakan metode call sesuai instruksi keamanan brief
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(balance, block.timestamp);
    }
    
    // Fungsi untuk memperpanjang durasi penguncian dana
    function extendLock(uint256 newTime) public onlyOwner {
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }
        unlockTime = newTime;
        emit LockExtended(newTime);
    }
}