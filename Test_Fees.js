const PAXGImplementation = artifacts.require("PAXGImplementation");
const FeeRedistributionContract = artifacts.require("FeeRedistributionContract");

contract("PAXGImplementation Test", function(accounts) {
    let paxgInstance, feeRedistributionInstance;

    beforeEach(async () => {
        paxgInstance = await PAXGImplementation.new();
        feeRedistributionInstance = await FeeRedistributionContract.new();
        // Initialisez les contrats comme nécessaire...
    });

    it("should transfer tokens and deduct fees", async () => {
        const initialAmount = 1000;
        const transferAmount = 100;
        const feePercentage = 1; // Supposons que les frais soient de 1%
        const expectedFee = transferAmount * feePercentage / 100;

        // Supposons que accounts[0] ait 1000 tokens pour commencer
        await paxgInstance.transfer(accounts[1], transferAmount, {from: accounts[0]});

        const balanceAfterTransfer = await paxgInstance.balanceOf(accounts[0]);
        assert.equal(balanceAfterTransfer.toNumber(), initialAmount - transferAmount, "Balance should decrease after transfer");

        const feeBalance = await feeRedistributionInstance.totalFees();
        assert.equal(feeBalance.toNumber(), expectedFee, "Fees should be deducted and added to the redistribution contract");
    });
});
