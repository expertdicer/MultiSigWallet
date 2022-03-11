const { expect } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

//0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1 0x74bb028830ea67a36507945834d480760f9eaf91f7f93d18671eb0d84d5995800b6ef1c70071023bf3882a17923f3960b868cadcf9079c79c1624254e16f3b901c
//0x716CC3A781E39ef20375d1B2eCc39A8Bd6b2Efcf 0xc8fa7f7a1cc3b4f2357bcc8496ab95421694f81574765217e7a776cebe20e57235e1159e0bd32c471869e0e53552e791296f28ce72c50b7618db81ea09e154491b
//0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26 0xf0162ea00615250c46d4bff985cf2d018184c08ea41bf384c26d3e021acc06c35fd780defc016ceac77a5a8d1df896716dab7703a5300b867de6e3b4749423201c


describe("MTS", function () {
  it("MTS", async function () {
     const multiSigFactory = await (await ethers.getContractFactory("MultiSigWalletFactory")).deploy();
     await multiSigFactory.deployed();

    const createTx = await multiSigFactory.create(["0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1", "0x716CC3A781E39ef20375d1B2eCc39A8Bd6b2Efcf", "0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26"], 1, ["0x0000000000000038", "0x0000000000000038", "0x0000000000000038"], ["0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1", "0x716CC3A781E39ef20375d1B2eCc39A8Bd6b2Efcf", "0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26"], ["0x74bb028830ea67a36507945834d480760f9eaf91f7f93d18671eb0d84d5995800b6ef1c70071023bf3882a17923f3960b868cadcf9079c79c1624254e16f3b901c", "0xc8fa7f7a1cc3b4f2357bcc8496ab95421694f81574765217e7a776cebe20e57235e1159e0bd32c471869e0e53552e791296f28ce72c50b7618db81ea09e154491b", "0xf0162ea00615250c46d4bff985cf2d018184c08ea41bf384c26d3e021acc06c35fd780defc016ceac77a5a8d1df896716dab7703a5300b867de6e3b4749423201c"], 1000);    
    console.log("Check same user:" ,await multiSigFactory.checkSameUser(["0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1", "0x716CC3A781E39ef20375d1B2eCc39A8Bd6b2Efcf"]));

    console.log("All address of 0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1:",await multiSigFactory.getAllAddress("0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1"));

    await(multiSigFactory.deleteAddress("0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26", ["0x0000000000000038", "0x0000000000000038", "0x0000000000000038"], ["0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1", "0x716CC3A781E39ef20375d1B2eCc39A8Bd6b2Efcf", "0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26"], ["0x74bb028830ea67a36507945834d480760f9eaf91f7f93d18671eb0d84d5995800b6ef1c70071023bf3882a17923f3960b868cadcf9079c79c1624254e16f3b901c", "0xc8fa7f7a1cc3b4f2357bcc8496ab95421694f81574765217e7a776cebe20e57235e1159e0bd32c471869e0e53552e791296f28ce72c50b7618db81ea09e154491b", "0xf0162ea00615250c46d4bff985cf2d018184c08ea41bf384c26d3e021acc06c35fd780defc016ceac77a5a8d1df896716dab7703a5300b867de6e3b4749423201c"], 100000));
    console.log(await multiSigFactory.checkSameUser(["0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1", "0xe50635d8aeEe3f75DA700fbB234e2a9cfBf46a26"]));
    console.log(await multiSigFactory.getAllAddress("0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1"));
    multisigWalletAddress = await multiSigFactory.ownerToMultiSigWallet("0x82f81FAF4B644DbAa665fCd781caC5A2E37A0EF1")
    console.log("multisigWallet address :", multisigWalletAddress);
    var multiSigWallet = await ethers.getContractAt("MultiSigWallet", multisigWalletAddress);
    console.log("Owners 1:", await multiSigWallet.owners(0))
    console.log("Owners 2:", await multiSigWallet.owners(1))

  });
});
