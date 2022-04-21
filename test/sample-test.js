require("dotenv").config();
const { expect, assert } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256');
const Web3 = require("web3");

var web3 = new Web3();

const users = [...Array(6).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`] }))


function getSignature(mess, id) {
  var data = '0x' + keccak256(mess).toString('hex');
  const res = web3.eth.accounts.sign(
    data,
    users[id].prikey
  ).signature;
  return res;
}

function changeToHex256(num) {
  var hex = num.toString(16).toString();
  while (hex.length < 64) hex = '0' + hex;
  return hex;
}

function getMessage(...ids) {
  return '0x' + ids.map(id => users[id].pubkey.substring(2)).join('');

}

function getMessage2(nonce, ...ids) {
  return '0x' + ids.map(id => users[id].pubkey.substring(2)).join('') + changeToHex256(nonce);

}

function getPubkey(...ids) {
  return ids.map(i => users[i].pubkey);
}

function getSignatureByIds(data, ...ids) {
  return ids.map(i => getSignature(data, i));
}

describe("MTS", function () {
  it("MTS", async function () {
    const multiSigFactory = await (await ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();
    console.log("Create first wallet:")
    const createTx = await multiSigFactory.create(getPubkey(0, 1, 2), 1, getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000);
    var checkSameUser = await multiSigFactory.checkSameUser([users[0].pubkey, users[1].pubkey]);
    expect(checkSameUser).equal(true);
    console.log("Check same user " + users[0].pubkey + " " + users[1].pubkey + ": ", checkSameUser);

    console.log("All address of ", users[0].pubkey, await multiSigFactory.getAllAddress(users[0].pubkey));
    console.log("Delete address: ", users[2].pubkey);
    await (multiSigFactory.deleteAddress(users[2].pubkey, getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000));
    checkSameUser = await multiSigFactory.checkSameUser([users[0].pubkey, users[2].pubkey]);
    expect(checkSameUser).equal(false);
    console.log("Check same user ", users[0].pubkey, users[1].pubkey, "after delete: ", checkSameUser);

    console.log("All address of", users[0].pubkey, "after delete user", users[2].pubkey,await multiSigFactory.getAllAddress(users[0].pubkey));
    
    console.log("Create second wallet:");
    const createTx2 = await multiSigFactory.create(getPubkey(3, 4, 5), 1, getPubkey(3, 4, 5), getSignatureByIds(getMessage(3, 4, 5), 3, 4, 5), 1000);

    console.log("All address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));
    
    const addressWallet1 = await multiSigFactory.ownerToMultiSigWallet(users[0].pubkey);
    const addressWallet2 = await multiSigFactory.ownerToMultiSigWallet(users[3].pubkey);

    console.log("Connect two address: ", users[0].pubkey, users[3].pubkey);
    await multiSigFactory.addAddress( getPubkey(0, 3), getSignatureByIds( getMessage(0, 3), 0, 3 ), 1000 );
    console.log("After connect, all address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey));
    console.log("After connect, all address of ", users[0].pubkey, await multiSigFactory.getAllAddress(users[0].pubkey));
    

    const wallet1 = await ethers.getContractAt("MultiSigWallet", addressWallet1);
    var ownerOfWallet1 = await wallet1.getOwners()
    console.log("Owner of multiSigWallet 1 after merger: ", ownerOfWallet1);
    console.log("address of multiSigWallet 2: ", addressWallet2);
  });

  
  
  it("MultiSigWallet", async function () {

    const signer = await ethers.getSigners();

    const multiSigWallet = await (await ethers.getContractFactory("MultiSigWallet")).deploy([signer[0].address, signer[1].address, signer[2].address], 1);

    // change requirement to 2
    const data = multiSigWallet.interface.encodeFunctionData("changeRequirement(uint256)", [2]);
    await multiSigWallet.connect(signer[1]).submitTransaction(multiSigWallet.address, 0, data);
    console.log("change requirement to 2");
    expect(await multiSigWallet.required()).equal(2);

    // change requirement to 3
    const data2 = multiSigWallet.interface.encodeFunctionData("changeRequirement(uint256)", [3]);
    await multiSigWallet.connect(signer[0]).submitTransaction(multiSigWallet.address, 0, data2);
    //await multiSigWallet.connect(signer[0]).revokeConfirmation(1);
    //console.log("number tx pending:", (await multiSigWallet.getTransactionCount(true, false)).toString());
    await multiSigWallet.connect(signer[1]).confirmTransaction(1);
    console.log("change requirement to 3");
    expect((await multiSigWallet.required())).equal(3);

    console.log("number confirm tx 1: ", (await multiSigWallet.getConfirmationCount(1)).toString());
    console.log("number tx excute:", (await multiSigWallet.getTransactionCount(false, true)).toString());
    //console.log(await multiSigWallet.getTransactionIds(0, 1, false, true));
  });

  it("Check recoder", async function() {
    const travaToken = await (await ethers.getContractFactory("TravaToken")).deploy();
    await travaToken.transfer(users[0].pubkey, 100000);
    await travaToken.transfer(users[1].pubkey, 100000);
    await travaToken.transfer(users[2].pubkey, 100000);
    await travaToken.transfer(users[3].pubkey, 100000);

    const recorder = await (await ethers.getContractFactory("Recorder")).deploy(travaToken.address, 1);
    // const recorder = await ethers.getContractAt("TravaToken", "0x8384DF1C9E68d21D8a812688f7f3DC93FAE06F90");
    
    // make merge request
    await recorder.makeMergeRequest(getPubkey(0, 1), getSignatureByIds(getMessage2(0, 0, 1), 0, 1), 1000);
    console.log( await recorder.mergeRequest(users[0].pubkey), users[1].pubkey );
    console.log("nonce", await recorder.nonce());
    console.log(await recorder.deposited(0));


    await recorder.makeMergeRequest(getPubkey(1, 2), getSignatureByIds(getMessage2(1, 1, 2), 1, 2), 1000);
    console.log( await recorder.mergeRequest(users[1].pubkey), users[2].pubkey );
    console.log("nonce", await recorder.nonce());
    console.log(await recorder.deposited(1));
    
  });

  it("Check role updater in multisigFatory", async function() {
    const signer = await ethers.getSigners();

    const multiSigFactory = await (await ethers.getContractFactory("MultiSigWalletFactory")).deploy();
    await multiSigFactory.deployed();
    console.log("Create first wallet:")
    const createTx = await multiSigFactory.create(getPubkey(0, 1, 2), 1, getPubkey(0, 1, 2), getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 1000);

    await multiSigFactory.addNewUpdater( signer[7].address );
    console.log("check updater", signer[7].address, await multiSigFactory.updater(signer[7].address));        

    await multiSigFactory.connect(signer[7]).addNewUpdater( signer[8].address );
    console.log("check updater", signer[8].address, await multiSigFactory.updater(signer[8].address));
  
    await multiSigFactory.connect(signer[7]).updaterConnectAddress(users[0].pubkey, getPubkey(3, 4, 5));
    console.log("check same wallet", await multiSigFactory.checkSameUser(getPubkey(0, 5)));
  });

});
