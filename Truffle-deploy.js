const BaseContract = artifacts.require("BaseContract");
const PAXGImplementation = artifacts.require("PAXGImplementation");
const FeeRedistributionContract = artifacts.require("FeeRedistributionContract");
const PAXGProxy = artifacts.require("PAXGProxy");
const ProxyAdminWrapper = artifacts.require("ProxyAdminWrapper");
const DeployContracts = artifacts.require("DeployContracts");

module.exports = async function(deployer, network, accounts) {
    // Déployez chaque contrat
    await deployer.deploy(BaseContract);
    await deployer.deploy(PAXGImplementation);
    await deployer.deploy(FeeRedistributionContract);
    await deployer.deploy(PAXGProxy);
    await deployer.deploy(ProxyAdminWrapper);
    await deployer.deploy(DeployContracts);

    // Instanciez le contrat DeployContracts
    const deployContractsInstance = await DeployContracts.deployed();

    // Appelez la fonction deploy pour déployer les autres contrats
    await deployContractsInstance.deploy();
};
