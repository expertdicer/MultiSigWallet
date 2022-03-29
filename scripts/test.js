require("dotenv").config();
const { expect } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const Web3 = require("web3");

var web3 = new Web3();

const users = [...Array(6).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`], chainId: '0x0000000000000038' }))

function getSignature(mess, id) {
  var data = '0x' + keccak256(mess).toString('hex');
  const res = web3.eth.accounts.sign(
    data,
    users[id].prikey
  ).signature;
  return res;
}

function getMessage(...ids) {
  return '0x' + ids.map(id => users[id].chainId.substring(2) + users[id].pubkey.substring(2)).join('');

}

function getPubkey(...ids) {
  return ids.map(i => users[i].pubkey);
}

function getChainId(...ids) {
  return ids.map(i => users[i].chainId);
}

function getSignatureByIds(data, ...ids) {
  return ids.map(i => getSignature(data, i));
}

async function main() {
    const accounts = await hre.ethers.getSigners();
    const multiSigFactory = await (await ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();
    const createTx = await multiSigFactory.create(getPubkey(0, 1, 2), 1, getChainId(0, 1, 2), getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000);

    console.log("Check same user:", await multiSigFactory.checkSameUser([users[0].pubkey, users[1].pubkey]));


    console.log("All address of ", users[0].pubkey, await multiSigFactory.getAllAddress(users[0].pubkey));

    await (multiSigFactory.deleteAddress(users[2].pubkey, getChainId(0, 1, 2), getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000));
    console.log(await multiSigFactory.checkSameUser([users[0].pubkey, users[2].pubkey]));


    console.log(await multiSigFactory.getAllAddress(users[0].pubkey));
    multisigWalletAddress = await multiSigFactory.ownerToMultiSigWallet(users[0].pubkey)
    console.log("multisigWallet address :", multisigWalletAddress);

    const multiSigWallet = await ethers.getContractAt("MultiSigWallet", multisigWalletAddress);
    console.log("Owners 1:", await multiSigWallet.owners(0))
    console.log("Owners 2:", await multiSigWallet.owners(1))

    console.log("\nMultiSigFatory2:");

    const createTx2 = await multiSigFactory.create(getPubkey(3, 4, 5), 1, getChainId(3, 4, 5), getPubkey(3, 4, 5), getSignatureByIds(getMessage(3, 4, 5), 3, 4, 5), 1000);

    console.log("All address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));

    await multiSigFactory.addAddress( getChainId(0, 3), getPubkey(0, 3), getSignatureByIds( getMessage(0, 3), 0, 3 ), 1000 );
    console.log("All address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));
    
    multisigWalletAddress = await multiSigFactory.ownerToMultiSigWallet(users[0].pubkey)
    console.log("multisigWallet address :", multisigWalletAddress);

    const multiSigWallet2 = await ethers.getContractAt("MultiSigWallet", multisigWalletAddress);
    for (let i = 0; i < 5; i++) {
        console.log("Owner ",i+1," address :", await multiSigWallet2.owners(i));
    }

    await multiSigWallet2.connect(accounts[0]).submitTransaction(multiSigWallet2.address, 0, );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});