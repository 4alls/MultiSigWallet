// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract MultiSigWallet {

    struct Transaction {
        address to;
        uint value;
        uint votes;
    }

    uint public quorum;
    Transaction[] public transactions;

    mapping(address account => bool isSigner) public signers;

    constructor(uint _quorum, address[] memory _signers) {
        quorum = _quorum;

        for (uint i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            signers[signer] = true;
        }
    }

    function proposeTransaction(address _to, uint _value) external {
        require(signers[msg.sender] == true, "Not signer");
        transactions.push(Transaction({to: _to, value: _value, votes: 1}));
    }
}
