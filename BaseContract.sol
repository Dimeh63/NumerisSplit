// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BaseContract is Initializable, OwnableUpgradeable {
    function initialize() public virtual initializer {
        __Ownable_init();
    }
}
