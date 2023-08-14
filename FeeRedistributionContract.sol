// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./PAXGImplementation.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract FeeRedistributionContract is BaseContract {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) public balances;
    PAXGImplementation private paxgTokenInstance;

    // Limite maximale de retrait pour éviter des retraits massifs.
    uint256 public maxWithdrawalAmount = 100 ether;

    // Ajout d'événements
    event BalanceUpdated(address indexed user, uint256 amount);
    event FeesClaimed(address indexed user, uint256 amount);

    function initialize(address _paxgToken) public initializer onlyOwner {
        super.initialize();
        paxgTokenInstance = PAXGImplementation(_paxgToken);
    }

    function updateBalance(address user, uint256 amount) external {
        require(msg.sender == address(paxgTokenInstance), "Only PAXGImplementation can update balance");
        balances[user] = balances[user].add(amount);
        emit BalanceUpdated(user, amount); // Émettre un événement lors de la mise à jour du solde
    }

    function claimFees() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No fees to claim");
        require(amount <= maxWithdrawalAmount, "Maximum withdrawal limit exceeded");
        balances[msg.sender] = 0;
        require(paxgTokenInstance.transfer(msg.sender, amount), "Transfer failed");
        emit FeesClaimed(msg.sender, amount); // Émettre un événement lors de la réclamation des frais
    }

    // Fonction pour permettre au propriétaire de mettre à jour la limite de retrait.
    function setMaxWithdrawalAmount(uint256 _amount) external onlyOwner {
        maxWithdrawalAmount = _amount;
    }
}

