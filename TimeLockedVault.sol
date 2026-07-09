// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeLockedVault {
    // Alamat dompet milik pemilik brankas
    address public owner;
    
    // Batas waktu kapan brankas boleh dibuka dalam format timestamp
    uint256 public unlockTime;

    // Log bukti transaksi saat koin masuk sesuai instruksi gambar
    event Deposit(address sender, uint256 amount);
    
    // Log bukti transaksi saat koin berhasil ditarik
    event Withdraw(uint256 amount);

    // Satpam khusus agar hanya pemilik yang bisa mengakses fungsi
    modifier onlyOwner() {
        require(msg.sender == owner, "Bukan pemilik");
        _;
    }

    // Satpam untuk memastikan waktu penguncian sudah selesai dilewati
    modifier afterUnlock() {
        require(block.timestamp >= unlockTime, "Belum mencapai waktu buka kunci");
        _;
    }

    // Menetapkan pemilik dan durasi penguncian saat kontrak pertama kali dibuat
    constructor(uint256 _lockDuration) {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockDuration;
    }

    // Fungsi untuk menabung koin ke dalam brankas
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Fungsi untuk mengambil seluruh dana setelah masa kunci berakhir
    function withdraw() public onlyOwner afterUnlock {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit Withdraw(balance);
    }

    // Fungsi pembantu untuk mengecek total saldo di dalam brankas saat ini
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}