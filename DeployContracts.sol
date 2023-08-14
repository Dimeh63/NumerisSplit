// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./PAXGImplementation.sol";
import "./FeeRedistributionContract.sol";
import "./PAXGProxy.sol";
import "./ProxyAdminWrapper.sol";

contract DeployContracts is BaseContract {
    address public paxgProxy;
    PAXGImplementation public paxgImplementation;
    FeeRedistributionContract public feeRedistributionContract;
    ProxyAdminWrapper public proxyAdmin;
    bool public deployed = false; // Ajout d'une variable pour vérifier si le contrat a été déployé

    function deploy() external onlyOwner {
        require(!deployed, "Contract already deployed"); // Vérification pour s'assurer que le contrat n'est déployé qu'une seule fois
        deployBaseContract();
        deployFeeRedistributionContract();
        deployPAXGImplementation();
        deployPAXGProxy();
        transferOwnership();
        deployed = true; // Mettre à jour l'état après le déploiement
    }

    function deployBaseContract() internal {
        BaseContract baseContract = new BaseContract();
        baseContract.initialize();
    }

    function deployFeeRedistributionContract() internal {
        feeRedistributionContract = new FeeRedistributionContract();
        feeRedistributionContract.initialize();
    }

    function deployPAXGImplementation() internal {
        paxgImplementation = new PAXGImplementation();
        paxgImplementation.initialize(
            "PAXG",
            "PAXG",
            1000000, // Initial supply
            1, // Fee percentage
            address(feeRedistributionContract) // Fee redistribution contract address
        );
    }

    function deployPAXGProxy() internal {
        proxyAdmin = new ProxyAdminWrapper(msg.sender); // Create ProxyAdmin with sender as initial owner
        bytes memory initData = abi.encodeWithSignature("initialize(string,string,uint256,uint256,address)", "PAXG", "PAXG", 1000000, 1, address(feeRedistributionContract));
        paxgProxy = address(new PAXGProxy(address(paxgImplementation), address(proxyAdmin), initData));
        proxyAdmin.transferOwnership(owner());
    }

    function transferOwnership() internal {
        feeRedistributionContract.transferOwnership(owner());
        paxgImplementation.transferOwnership(owner());
    }
}
