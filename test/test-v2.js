require("dotenv").config();
const { expect, assert } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256');
const Web3 = require("web3");

var web3 = new Web3();

const users = [...Array(10).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`], chainId: '0x0000000000000038' }))


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
  return '0x' + ids.map(id => users[id].chainId.substring(2) + users[id].pubkey.substring(2)).join('');

}

function getMessage2(nonce, ...ids) {
  return '0x' + ids.map(id => users[id].pubkey.substring(2)).join('') + changeToHex256(nonce);

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
    await multiSigFactory.create( getPubkey(0, 1, 2), 2, 0, getSignatureByIds(getMessage2(0, 0, 1, 2), 0, 1, 2), 1000 );
    console.log( await( multiSigFactory.getAllAddress(users[0].pubkey)));

    await multiSigFactory.create( getPubkey(4, 5), 2, 0, getSignatureByIds(getMessage2(0, 4, 5), 4, 5), 1000 );
    console.log( await( multiSigFactory.getAllAddress(users[4].pubkey)));

    await multiSigFactory.create( getPubkey(6, 7), 2, 0, getSignatureByIds(getMessage2(0, 6, 7), 6, 7), 1000 );
    console.log( await( multiSigFactory.getAllAddress(users[6].pubkey)));

    const _nonce = await(multiSigFactory.nonce( (await(multiSigFactory.ownerToMultiSigWallet(users[0].pubkey))) )) ;

    await multiSigFactory.updateAddress(
        [
            getPubkey(1, 2, 3),
            getPubkey(1, 2, 4),
            getPubkey(1, 2, 3, 4, 5, 6)
        ],
        [
            _nonce + 1,
            _nonce + 2,
            _nonce + 3,
        ],
        [
            getSignatureByIds(getMessage2(_nonce + 1, 1, 2, 3), 1, 2, 3),
            getSignatureByIds(getMessage2(_nonce + 2, 1, 2, 4), 1, 2, 4),
            getSignatureByIds(getMessage2(_nonce + 3, 1, 2, 3, 4, 5, 6), 1, 2, 3, 4, 5, 6),

        ],
        1000
    );

    console.log( await( multiSigFactory.getAllAddress(users[0].pubkey)));

  });

});
