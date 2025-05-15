// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract MultiSigWallet {

    struct Transaction {
        address to;
        uint value;
        uint votes;
        uint deadline;
        bool executed;
    }

    uint public quorum;
    Transaction[] public transactions;
    
    mapping(address account => bool isSigner) public signers;
    mapping(uint id => mapping(address signer => bool validated)) public validations;

    modifier onlySigner() {
        require(signers[msg.sender] == true, "Not signer");
        _;
    }

    constructor(uint _quorum, address[] memory _signers) {
        require(_quorum > 1 && _quorum <= _signers.length);
        quorum = _quorum;

        for (uint i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Address zero");
            require(signers[signer] == false, "Duplicate signer");

            signers[signer] = true;
        }
    }

    function transactionCount() external view returns (uint) {
        return transactions.length;
    }

    function proposeTransaction(address _to, uint _value) external onlySigner {
        uint id = transactions.length;
        transactions.push(Transaction({to: _to, value: _value, votes: 1, deadline: block.timestamp + 1 days, executed: false}));
        validations[id][msg.sender] = true;
    }

    function validateTransaction(uint _id) external onlySigner {
        require(validations[_id][msg.sender] == false, "Already validated");
        require(transactions[_id].executed == false, "Already executed");
        require(block.timestamp < transactions[_id].deadline, "Invalid transaction");

        transactions[_id].votes ++;
        validations[_id][msg.sender] = true;

        if (transactions[_id].votes >= quorum) {
            address payable to = payable(transactions[_id].to);
            uint value = transactions[_id].value;
            to.transfer(value);
        }
    }

    receive() external payable {}
}


