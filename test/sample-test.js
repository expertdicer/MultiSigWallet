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

describe("MTS", function () {
  it("MTS", async function () {
    const multiSigFactory = await (await ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();
    console.log("Create first wallet:")
    const createTx = await multiSigFactory.create(getPubkey(0, 1, 2), 1, getChainId(0, 1, 2), getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000);

    console.log("Check same user " + users[0].pubkey + " " + users[1].pubkey + ": ", await multiSigFactory.checkSameUser([users[0].pubkey, users[1].pubkey]));


    console.log("All address of ", users[0].pubkey, await multiSigFactory.getAllAddress(users[0].pubkey));

    console.log("Delete address: ", users[2].pubkey);
    await (multiSigFactory.deleteAddress(users[2].pubkey, getChainId(0, 1, 2), getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000));
    console.log("All address of", users[0].pubkey, await multiSigFactory.getAllAddress(users[0].pubkey));
    
    console.log("Create second wallet:");
    const createTx2 = await multiSigFactory.create(getPubkey(3, 4, 5), 1, getChainId(3, 4, 5), getPubkey(3, 4, 5), getSignatureByIds(getMessage(3, 4, 5), 3, 4, 5), 1000);

    console.log("All address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));

    console.log("Connect two address: ", users[0].pubkey, users[3].pubkey);
    await multiSigFactory.addAddress( getChainId(0, 3), getPubkey(0, 3), getSignatureByIds( getMessage(0, 3), 0, 3 ), 1000 );
    console.log("After connect, all address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));
  });

  // it("MultiSigWallet", async function () {
  //   web3.eth.defaultAccount = users[0].pubkey;
  //   const signer = await ethers.getSigners(); 
  //   const multiSigWallet = await (await ethers.getContractFactory("MultiSigWallet")).deploy( getPubkey(0, 1, 2), 3);
  //   await multiSigWallet.deployed();
  //   console.log(multiSigWallet.address)
  //   //console.log(await multiSigWallet.getMsgSender({from: web3.eth.accounts[0]}));
    

  // });
});
