const hre = require("hardhat");

async function main() {  
    console.log("Start deploy!!")
    const multiSigFactory = await (await hre.ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();
    console.log("MultiSigFactory deployed at ", multiSigFactory.address);


    const travaToken = await (await hre.ethers.getContractFactory("TravaToken")).deploy();
    await travaToken.deployed();
    console.log("TravaToken deployed at ", travaToken.address);

    const recorder = await (await ethers.getContractFactory("Recorder")).deploy(travaToken.address, 0);
    await recorder.deployed();
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
