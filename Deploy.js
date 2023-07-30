const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const FeeRedistributionContract = await ethers.getContractFactory("FeeRedistributionContract");
    const feeRedistributionContract = await FeeRedistributionContract.deploy();
    await feeRedistributionContract.deployed();

    const PAXGImplementation = await ethers.getContractFactory("PAXGImplementation");
    const paxgImplementation = await PAXGImplementation.deploy();
    await paxgImplementation.deployed();

    const initData = ethers.utils.defaultAbiCoder.encode(
        ["string", "string", "uint256", "uint256", "address"],
        ["PAXG", "PAXG", ethers.utils.parseEther("1000000"), 1, feeRedistributionContract.address]
    );

    const PAXGProxy = await ethers.getContractFactory("PAXGProxy");
    const paxgProxy = await PAXGProxy.deploy(paxgImplementation.address, deployer.address, initData);
    await paxgProxy.deployed();

    const ProxyAdminWrapper = await ethers.getContractFactory("ProxyAdminWrapper");
    const proxyAdminWrapper = await ProxyAdminWrapper.deploy(deployer.address);
    await proxyAdminWrapper.deployed();

    console.log("FeeRedistributionContract deployed to:", feeRedistributionContract.address);
    console.log("PAXGImplementation deployed to:", paxgImplementation.address);
    console.log("PAXGProxy deployed to:", paxgProxy.address);
    console.log("ProxyAdminWrapper deployed to:", proxyAdminWrapper.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
