// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Importation des contrats nécessaires et des bibliothèques d'OpenZeppelin.
import "./BaseContract.sol";
import "./FeeRedistributionContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

// Le contrat PAXGImplementation hérite de plusieurs contrats, notamment ERC20 et Pausable.
contract PAXGImplementation is BaseContract, ERC20Upgradeable, PausableUpgradeable {
    // Utilisation des bibliothèques pour les opérations mathématiques et les adresses.
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    // Variables d'état privées pour stocker le pourcentage des frais et l'adresse du récepteur des frais.
    uint256 private feePercentage;
    address private feeReceiver;
    // Instance du contrat FeeRedistributionContract pour interagir avec lui.
    FeeRedistributionContract private feeRedistributionContractInstance;

    // Événements pour signaler les mises à jour des frais et du récepteur des frais.
    event FeesUpdated(uint256 feePercentage);
    event FeeReceiverUpdated(address feeReceiver);

    // Fonction d'initialisation pour définir les paramètres initiaux du contrat.
    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _feePercentage,
        address _feeRedistributionContract
    ) public initializer onlyOwner {
        // Initialisation des contrats ERC20 et Pausable.
        __ERC20_init(_name, _symbol);
        __Pausable_init();
        super.initialize();
        // Émission des tokens initiaux.
        _mint(msg.sender, _initialSupply);
        // Configuration du pourcentage des frais et du récepteur des frais.
        setFeePercentage(_feePercentage);
        setFeeReceiver(_feeRedistributionContract);
    }

    // Fonction pour mettre à jour le pourcentage des frais.
    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        // Validation pour s'assurer que le pourcentage des frais est entre 0 et 5.
        require(_feePercentage >= 0 && _feePercentage <= 5, "Fee percentage should be between 0 and 5");
        feePercentage = _feePercentage;
        emit FeesUpdated(_feePercentage);
    }

    // Fonction pour mettre à jour l'adresse du récepteur des frais.
    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        // Validation pour s'assurer que l'adresse n'est pas nulle.
        require(_feeReceiver != address(0), "Fee receiver cannot be zero address");
        feeReceiver = _feeReceiver;
        // Mise à jour de l'instance du contrat FeeRedistributionContract.
        feeRedistributionContractInstance = FeeRedistributionContract(_feeReceiver);
        emit FeeReceiverUpdated(_feeReceiver);
    }

    // Fonctions pour mettre le contrat en pause et le reprendre.
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Surcharge de la fonction de transfert pour inclure la logique des frais.
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override whenNotPaused {
        // Vérification du solde du sender.
        require(balanceOf(sender) >= amount, "Insufficient balance for transfer");
        // Calcul du montant des frais.
        uint256 feeAmount = amount.mul(feePercentage).div(100);
        uint256 transferAmount = amount.sub(feeAmount);
        // Transfert des tokens et des frais.
        super._transfer(sender, recipient, transferAmount);
        super._transfer(sender, feeReceiver, feeAmount);
        // Mise à jour du solde dans le contrat FeeRedistributionContract.
        feeRedistributionContractInstance.updateBalance(recipient, feeAmount);
    }
}
