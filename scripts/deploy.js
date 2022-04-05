const hre = require("hardhat");

async function main() {  
    const multiSigFactory = await (await hre.ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();

    const travaToken = await (await hre.ethers.getContractFactory("TravaToken")).deploy();
    await travaToken.deployed();

    const recorder = await (await ethers.getContractFactory("Recorder")).deploy(travaToken.address, 0);
    await recorder.deployed();

    console.log("MultiSigFactory deployed at ", multiSigFactory.address);
    console.log("TravaToken deployed at ", travaToken.address);
    console.log("Recorder deployed at ", recorder.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
