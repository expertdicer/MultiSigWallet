require("dotenv").config();
const { expect, assert } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256');
const Web3 = require("web3");

var web3 = new Web3(new Web3.providers.HttpProvider("https://speedy-nodes-nyc.moralis.io/724eeac97cb0de89ff3cffce/eth/kovan"));

const users = [...Array(6).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`], chainId: '0x0000000000000038' }))


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

async function main() {
  // const recorder = await ethers.getContractAt("Recorder", "0x8384DF1C9E68d21D8a812688f7f3DC93FAE06F90");
  //   console.log(await recorder.moderator());
    
  //   // make merge request
  //   await recorder.makeMergeRequest(getPubkey(0, 1), getSignatureByIds(getMessage2(0, 0, 1), 0, 1), 1000, {gasLimit: 3000000});
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});