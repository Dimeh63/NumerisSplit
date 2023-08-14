const DeployContracts = artifacts.require("DeployContracts");

contract("DeployContracts Test", function(accounts) {
    let deployContractsInstance;

    beforeEach(async () => {
        deployContractsInstance = await DeployContracts.new();
    });

    it("should deploy all contracts", async () => {
        await deployContractsInstance.deploy({from: accounts[0]});
        const deployed = await deployContractsInstance.deployed();
        assert.equal(deployed, true, "Contracts should be deployed");
    });

    it("should not allow deploy to be called more than once", async () => {
        await deployContractsInstance.deploy({from: accounts[0]});
        try {
            await deployContractsInstance.deploy({from: accounts[0]});
            assert.fail("Expected revert not received");
        } catch (error) {
            const revertFound = error.message.search('revert') >= 0;
            assert(revertFound, `Expected "revert", got ${error} instead`);
        }
    });
});
