// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Importation du contrat ProxyAdmin d'OpenZeppelin.
// ProxyAdmin est un contrat qui sert d'administrateur pour les proxies transparents.
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

// Le contrat ProxyAdminWrapper hérite de ProxyAdmin.
contract ProxyAdminWrapper is ProxyAdmin {

    // Le constructeur prend un paramètre :
    // initialOwner : l'adresse du propriétaire initial du contrat ProxyAdmin.
    constructor(address initialOwner) ProxyAdmin() {
        // Transfert de la propriété du contrat ProxyAdmin à l'adresse fournie.
        transferOwnership(initialOwner);
    }
}

