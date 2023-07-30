// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./PAXGImplementation.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract FeeRedistributionContract is BaseContract {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) public balances;
    PAXGImplementation private paxgTokenInstance;

    function initialize(address _paxgToken) public initializer onlyOwner {
        super.initialize();
        paxgTokenInstance = PAXGImplementation(_paxgToken);
    }

    function updateBalance(address user, uint256 amount) external {
        require(msg.sender == address(paxgTokenInstance), "Only PAXGImplementation can update balance");
        balances[user] = balances[user].add(amount);
    }

    function claimFees() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No fees to claim");
        balances[msg.sender] = 0;
        require(paxgTokenInstance.transfer(msg.sender, amount), "Transfer failed");
    }
}
