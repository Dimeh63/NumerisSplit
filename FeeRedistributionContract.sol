// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseContract.sol";
import "./PAXGImplementation.sol";
import "./FeeRedistributionContract.sol";
import "./PAXGProxy.sol";
import "./ProxyAdminWrapper.sol";

/**
 * @title DeployContracts
 * @dev Ce contrat est responsable du déploiement de plusieurs autres contrats associés.
 * Il s'assure que les contrats ne sont déployés qu'une seule fois.
 */
contract DeployContracts is BaseContract {
    // Adresses des contrats déployés
    address public paxgProxy;
    PAXGImplementation public paxgImplementation;
    FeeRedistributionContract public feeRedistributionContract;
    ProxyAdminWrapper public proxyAdmin;
    
    // État pour vérifier si les contrats ont déjà été déployés
    bool public deployed = false;

    /**
     * @dev Déploie tous les contrats associés.
     * Cette fonction ne peut être appelée qu'une fois.
     */
    function deploy() external onlyOwner {
        require(!deployed, "Contract already deployed");

        deployBaseContract();
        deployFeeRedistributionContract();
        deployPAXGImplementation();
        deployPAXGProxy();
        transferOwnership();

        deployed = true; // Indique que les contrats ont été déployés
    }

    /**
     * @dev Déploie le contrat BaseContract.
     * NOTE: L'adresse du contrat déployé n'est pas stockée ou utilisée.
     * À envisager si cette étape est nécessaire.
     */
    function deployBaseContract() internal {
        BaseContract baseContract = new BaseContract();
        baseContract.initialize();
    }

    /**
     * @dev Déploie le contrat FeeRedistributionContract.
     */
    function deployFeeRedistributionContract() internal {
        feeRedistributionContract = new FeeRedistributionContract();
        feeRedistributionContract.initialize();
    }

    /**
     * @dev Déploie le contrat PAXGImplementation.
     */
    function deployPAXGImplementation() internal {
        paxgImplementation = new PAXGImplementation();
        paxgImplementation.initialize(
            "PAXG",
            "PAXG",
            1000000, // Approvisionnement initial
            1, // Pourcentage des frais
            address(feeRedistributionContract)
        );
    }

    /**
     * @dev Déploie le contrat PAXGProxy.
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
     * @dev Transfère la propriété des contrats déployés au propriétaire de DeployContracts.
     */
    function transferOwnership() internal {
        feeRedistributionContract.transferOwnership(owner());
        paxgImplementation.transferOwnership(owner());
    }
}


