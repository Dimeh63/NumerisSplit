// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract PAXGProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address _admin, bytes memory _data) 
        TransparentUpgradeableProxy(_logic, _admin, _data) 
    {}

    function admin() public view returns (address) {
        return _admin();
    }
}
