// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract Bank {
    // ---------------------------------------------------------------------------//
    // Addresses in the smart contract
    address public owner;
    address[] public Accounts; 

    // ---------------------------------------------------------------------------//
    // Owner's contract
    constructor() {
        owner = msg.sender; // Owner of the contract
    } 

    modifier isAdmin {
        require(owner == msg.sender, "Reserved only for the Owner");
        _;
    }
    // ---------------------------------------------------------------------------//
    // Processes in the Smart Contract 
    // Banking Processes
    // 1. Open Account =>
    // 2. Deposit
    // 3. Withdraw
    // 4. Obtaining the balance
    // 5. Transfer
    // 6. Loan     
    // ---------------------------------------------------------------------------//
    // Mappings in the smart contract
    mapping(address => uint) public balance; 
    mapping (address => bool) public isAddressAdded; // Checking if the address is in the bank account

    // ---------------------------------------------------------------------------//
    // Events in the smart contract
    event BankOpening(address _addressnew);
    event Deposit(address _addressbal, uint _value);
    event Withdrawal(address _addressbal, uint _value);
    event Transfer(address _addressbal, address _addresssend, uint _value);

    // ---------------------------------------------------------------------------//
    // 1. Opening the bank account (Reserved for the Owner of the contract) 
    function addBankAddress(address _newAddress) public payable isAdmin {
        balance[_newAddress] += msg.value;
        Accounts.push(_newAddress);
        isAddressAdded[_newAddress] = true;
        emit BankOpening(_newAddress);
    }
     
    // Get all the addresses in the bank account
    function getBankAddress() public view isAdmin returns(address[] memory) {
        return Accounts;
    }

    // ---------------------------------------------------------------------------//
    // 2. Deposit the money in the bank
    function deposit() public payable {
        require(isAddressAdded[msg.sender] == true, "Please open a bank account");
        require(msg.value > 0, "You must add enough ethers");
        balance[msg.sender] += msg.value; 
        emit Deposit(msg.sender, msg.value); 
    }

    // ---------------------------------------------------------------------------//
    // 3. Withdraw money from the bank
    function withdraw(uint _amount) public {
        require(isAddressAdded[msg.sender] == true, "Please open a bank account");
        require(balance[msg.sender] >= _amount, "Not enough Balance");
        balance[msg.sender] -= _amount; 
        payable(msg.sender).transfer(_amount); //sending the amount to the owner
        emit Withdrawal(msg.sender, _amount);
    }

    // ---------------------------------------------------------------------------// 
    // 4. Obtaining the balance 
    function getBalance() public view returns (uint256) {
        require(isAddressAdded[msg.sender] == true, "Please open a bank account");
        return balance[msg.sender];
    }

    // ---------------------------------------------------------------------------//
    // 5. Transfering the amount 
    function transfer(address _recipient, uint _amount) public {
        require(isAddressAdded[msg.sender] == true, "Please open a bank account");
        require(balance[msg.sender] >= _amount, "Sender does not have enough balance");
        balance[msg.sender] -= _amount; 
        balance[_recipient] += _amount; // sending the amount to the address _recipient
        emit Transfer(msg.sender, _recipient, _amount);
    }

    // ---------------------------------------------------------------------------//
    // 6. Loan 
    // Yet to be implemented

    // ---------------------------------------------------------------------------//
}
