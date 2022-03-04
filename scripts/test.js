const hre = require("hardhat");


async function main() {

    var networkName = hre.network.name;

    const accounts = await hre.ethers.getSigners();

    var factory = await hre.ethers.getContractFactory("MultiSigWalletFactory");
    var Factory = await factory.deploy();
    await Factory.deployed();

    owners = [ accounts[0].address , accounts[1].address , accounts[2].address]
    await Factory.connect(accounts[0]).create(owners, 2)
    await Factory.connect(accounts[0]).create(owners, 2)
    console.log("Factory address :", Factory.address);
    console.log("Multisig address 1:", await Factory.instantiations(accounts[0].address,0));
    console.log("Multisig address 2:", await Factory.instantiations(accounts[0].address,1));
    var multisigAddress = await Factory.instantiations(accounts[0].address,1);
    var Multisig = await hre.ethers.getContractAt("MultiSigWallet",multisigAddress)
    console.log("Moderator :", await Multisig.moderator())
}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
