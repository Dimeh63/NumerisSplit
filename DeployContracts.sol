// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./PAXGImplementation.sol";
import "./FeeRedistributionContract.sol";
import "./PAXGProxy.sol";
import "./ProxyAdminWrapper.sol";

contract DeployContracts is BaseContract {
    // Variables d'état pour stocker les adresses des contrats déployés
    address public paxgProxy;
    PAXGImplementation public paxgImplementation;
    FeeRedistributionContract public feeRedistributionContract;
    ProxyAdminWrapper public proxyAdmin;
    
    // Variable pour vérifier si le contrat a été déployé
    bool public deployed = false;

    /**
     * @dev Fonction pour déployer tous les contrats associés.
     * Ne peut être appelé qu'une fois.
     */
    function deploy() external onlyOwner {
        require(!deployed, "Contract already deployed");

        deployBaseContract();
        deployFeeRedistributionContract();
        deployPAXGImplementation();
        deployPAXGProxy();
        transferOwnership();

        deployed = true; // Mettre à jour l'état après le déploiement
    }

    /**
     * @dev Fonction pour déployer le contrat BaseContract.
     * NOTE: L'adresse du contrat déployé n'est pas stockée ou utilisée.
     * À envisager si cette étape est nécessaire.
     */
    function deployBaseContract() internal {
        BaseContract baseContract = new BaseContract();
        baseContract.initialize();
    }

    /**
     * @dev Fonction pour déployer le contrat FeeRedistributionContract.
     */
    function deployFeeRedistributionContract() internal {
        feeRedistributionContract = new FeeRedistributionContract();
        feeRedistributionContract.initialize();
    }

    /**
     * @dev Fonction pour déployer le contrat PAXGImplementation.
     */
    function deployPAXGImplementation() internal {
        paxgImplementation = new PAXGImplementation();
        paxgImplementation.initialize(
            "PAXG",
            "PAXG",
            1000000, // Initial supply
            1, // Fee percentage
            address(feeRedistributionContract)
        );
    }

    /**
     * @dev Fonction pour déployer le contrat PAXGProxy.
     */
    function deployPAXGProxy() internal {
        proxyAdmin = new ProxyAdminWrapper(msg.sender);
        bytes memory initData = abi.encodeWithSignature(
            "initialize(string,string,uint256,uint256,address)",
            "PAXG",
            "PAXG",
            1000000,
            1,
            address(feeRedistributionContract)
        );
        paxgProxy = address(new PAXGProxy(address(paxgImplementation), address(proxyAdmin), initData));
        proxyAdmin.transferOwnership(owner());
    }

    /**
     * @dev Fonction pour transférer la propriété des contrats déployés au propriétaire de DeployContracts.
     */
    function transferOwnership() internal {
        feeRedistributionContract.transferOwnership(owner());
        paxgImplementation.transferOwnership(owner());
    }
}
