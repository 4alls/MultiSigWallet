// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/// @title Wallet mulit-signatures
/// @author Thibaut Baudry
/// @notice Ce contrat intelligent représente une wallet multiSig

contract MultiSigWallet {

    struct Transaction {
        address to;
        uint amount;
        uint votes;
        uint deadline;
        bool executed;
    }

    uint public quorum;
    Transaction[] public transactions;
    
    mapping(address account => bool isSigner) public signers;
    mapping(uint id => mapping(address signer => bool validated)) public validations;

    /// @dev Définit le quorum
    /// @dev Définit les addresses données en paramètre comme signataires de la wallet
    /// @param _quorum Nombre nécessaire pour effectuer des transactions avec cette wallet
    /// @param _signers Tableau d'addresses des signataires
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

    /// @dev S'assure que l'appelant d'une fonction est enregistré comme signataire de la wallet
    modifier onlySigner() {
        require(signers[msg.sender] == true, "Not signer");
        _;
    }

    /// @notice Récupère le nombre de transactions
    /// @return uint Le nombre de transactions
    function transactionCount() external view returns (uint) {
        return transactions.length;
    }

    /// @notice Ajoute une transaction dans le tableau de transactions en attente
    /// @notice Attribue un vote automatique à cette transaction du fait de la proposition
    /// @notice Fixe la deadline pour l'éxecution de la transaction à 1 jour
    /// @notice Enregistre la validation de la transaction par le signataire ayant proposé la transaction
    /// @dev Ne peut être exécutée que par un signataire de la wallet
    /// @param _to Le destinataire de la transaction
    /// @param _amount Le montant de la transaction
    function proposeTransaction(address _to, uint _amount) external onlySigner {
        transactions.push(Transaction({to: _to, amount: _amount, votes: 1, deadline: block.timestamp + 1 days, executed: false}));
        validations[transactions.length][msg.sender] = true;
    }

    /// @notice Attribue un vote à la transaction
    /// @notice Enregistre la validation de la transaction par le signataire ayant validé la transaction
    /// @notice Exécute la transaction si son nombre de votes est supérieur ou égal ou quorum
    /// @dev Ne peut être exécutée que par un signataire de la wallet
    /// @param _id Le numéro de la transaction que l'on veut exécuter
    function validateTransaction(uint _id) external onlySigner {
        require(validations[_id][msg.sender] == false, "Already validated");
        require(transactions[_id].executed == false, "Already executed");
        require(block.timestamp < transactions[_id].deadline, "Invalid transaction");

        transactions[_id].votes ++;
        validations[_id][msg.sender] = true;

        if (transactions[_id].votes >= quorum) {
            address payable to = payable(transactions[_id].to);
            to.transfer(transactions[_id].amount);
        }
    }

    /// @notice Permet à la wallet de recevoir des fonds :)
    receive() external payable {}
}


