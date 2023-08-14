// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title BaseContract
 * @dev Ce contrat sert de base pour d'autres contrats en intégrant la fonctionnalité "Ownable" d'OpenZeppelin.
 * Il est conçu pour être utilisé avec le modèle de mise à niveau d'OpenZeppelin, où les contrats peuvent être mis à niveau sans perdre l'état.
 */
contract BaseContract is Initializable, OwnableUpgradeable {

    /**
     * @dev Fonction d'initialisation qui configure le propriétaire du contrat.
     * Elle utilise le modificateur 'initializer' pour s'assurer qu'elle ne peut être appelée qu'une seule fois.
     */
    function initialize() public virtual initializer {
        __Ownable_init();
    }
}

