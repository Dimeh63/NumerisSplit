// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./FeeRedistributionContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

contract PAXGImplementation is BaseContract, ERC20Upgradeable, PausableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    uint256 private feePercentage;
    address private feeReceiver;
    FeeRedistributionContract private feeRedistributionContractInstance;

    event FeesUpdated(uint256 feePercentage);
    event FeeReceiverUpdated(address feeReceiver);

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _feePercentage,
        address _feeRedistributionContract
    ) public initializer onlyOwner {
        __ERC20_init(_name, _symbol);
        __Pausable_init();
        super.initialize();
        _mint(msg.sender, _initialSupply);
        feePercentage = _feePercentage;
        feeReceiver = _feeRedistributionContract;
        feeRedistributionContractInstance = FeeRedistributionContract(_feeRedistributionContract);
        feeRedistributionContractInstance.initialize(address(this));
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
        emit FeesUpdated(_feePercentage);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override whenNotPaused {
        require(balanceOf(sender) >= amount, "Insufficient balance for transfer");
        uint256 feeAmount = amount.mul(feePercentage).div(100);
        uint256 transferAmount = amount.sub(feeAmount);
        super._transfer(sender, recipient, transferAmount);
        super._transfer(sender, feeReceiver, feeAmount);
        feeRedistributionContractInstance.updateBalance(recipient, feeAmount);
    }
}
