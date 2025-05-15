// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract MultiSigWallet {

    uint public quorum;

    mapping(address account => bool isSigner) public signers;

    constructor(uint _quorum, address[] memory _signers) {
        quorum = _quorum;

        for (uint i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            signers[signer] = true;
        }
    }
}
