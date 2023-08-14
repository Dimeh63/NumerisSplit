// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Importation du contrat TransparentUpgradeableProxy d'OpenZeppelin.
// Ce contrat permet de créer un proxy transparent qui peut être mis à jour.
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// Le contrat PAXGProxy hérite de TransparentUpgradeableProxy.
contract PAXGProxy is TransparentUpgradeableProxy {

    // Le constructeur prend trois paramètres :
    // _logic : l'adresse du contrat de logique initial.
    // _admin : l'adresse de l'administrateur du proxy.
    // _data : les données à envoyer au contrat de logique lors de la création du proxy.
    constructor(address _logic, address _admin, bytes memory _data) 
        TransparentUpgradeableProxy(_logic, _admin, _data) 
    {}

    // Fonction pour obtenir l'adresse de l'administrateur du proxy.
    // Cette fonction est utile car la fonction _admin() est interne dans TransparentUpgradeableProxy.
    function admin() public view returns (address) {
        return _admin();
    }
}
