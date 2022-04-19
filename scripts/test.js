// require("dotenv").config();
// const { expect, assert } = require("chai");
// const { hexStripZeros } = require("ethers/lib/utils");
// const { ethers } = require("hardhat");
// const keccak256 = require('keccak256');
// const Web3 = require("web3");

// var web3 = new Web3(new Web3.providers.HttpProvider("https://speedy-nodes-nyc.moralis.io/724eeac97cb0de89ff3cffce/eth/kovan"));

// const users = [...Array(11).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`], chainId: '0x0000000000000038' }))


// function getSignature(mess, id) {
//   var data = '0x' + keccak256(mess).toString('hex');
//   const res = web3.eth.accounts.sign(
//     data,
//     users[id].prikey
//   ).signature;
//   return res;
// }

// function changeToHex256(num) {
//   var hex = num.toString(16).toString();
//   while (hex.length < 64) hex = '0' + hex;
//   return hex;
// }

// function getMessage(...ids) {
//   return '0x' + ids.map(id => users[id].chainId.substring(2) + users[id].pubkey.substring(2)).join('');

// }

// function getMessage2(nonce, ...ids) {
//   return '0x' + ids.map(id => users[id].pubkey.substring(2)).join('') + changeToHex256(nonce);

// }

// function getPubkey(...ids) {
//   return ids.map(i => users[i].pubkey);
// }

// function getChainId(...ids) {
//   return ids.map(i => users[i].chainId);
// }

// function getSignatureByIds(data, ...ids) {
//   return ids.map(i => getSignature(data, i));
// }

// function mulSigFactoryCreateTx() {
  
// }

// async function recoderCreateTx() {
// //

// }

// async function main() {
//     // const multiSigFactory = await ethers.getContractAt("MultiSigWalletFactory", "0xCDA456FEf9aDCb651CcD58Ed6687c0e96FB3f02F");
//     // console.log("Create first wallet:")
//     // const createTx = await multiSigFactory.create(getPubkey(8, 9, 10), 1, getChainId(8, 9, 10), getPubkey(8, 9, 10), getSignatureByIds(getMessage(8, 9, 10), 8, 9, 10), 10000, {gasLimit: 2000000});
//     // var checkSameUser = await multiSigFactory.checkSameUser([users[8].pubkey, users[9].pubkey]);
//     // console.log("Check same user " + users[8].pubkey + " " + users[9].pubkey + ": ", checkSameUser);

//     // console.log("All address of ", users[8].pubkey, await multiSigFactory.getAllAddress(users[9].pubkey));
//     // console.log("Delete address: ", users[10].pubkey);
//     // await (multiSigFactory.deleteAddress(users[10].pubkey, getChainId(8, 9, 10), getPubkey(8, 9, 10), getSignatureByIds(getMessage(8, 9, 10), 8, 9, 10), 1000, {gasLimit: 2000000}));
//     // checkSameUser = await multiSigFactory.checkSameUser([users[8].pubkey, users[10].pubkey]);
//     // console.log("Check same user ", users[0].pubkey, users[1].pubkey, "after delete: ", checkSameUser);

//     // console.log("All address of", users[0].pubkey, "after delete user", users[2].pubkey,await multiSigFactory.getAllAddress(users[0].pubkey, {gasLimit: 2000000}));
    
//     // console.log("All address of ", users[3].pubkey, await multiSigFactory.getAllAddress(users[3].pubkey, {gasLimit: 2000000}));
    
//     // const addressWallet1 = await multiSigFactory.ownerToMultiSigWallet(users[0].pubkey);
//     // const addressWallet2 = await multiSigFactory.ownerToMultiSigWallet(users[3].pubkey);

//     // console.log("Connect two address: ", users[8].pubkey, users[7].pubkey);
//     // await multiSigFactory.addAddress( getChainId(8, 7), getPubkey(8, 7), getSignatureByIds( getMessage(8, 7), 8, 7 ), 1000, {gasLimit: 2000000} );
//     // console.log("After connect, all address of ", users[8].pubkey, await multiSigFactory.getAllAddress(users[8].pubkey));
//     // console.log("After connect, all address of ", users[7].pubkey, await multiSigFactory.getAllAddress(users[7].pubkey));
    

//     // await multiSigFactory.updaterConnectAddress(users[8].pubkey, [users[5].pubkey], {gasLimit: 2000000});
//     // console.log("After connect, all address of ", users[5].pubkey, await multiSigFactory.getAllAddress(users[5].pubkey));

//     ///////////////
//     // console.log("--------------------------------");
//     // const recorder = await ethers.getContractAt("Recorder", "0xDA9CF05f45A309d4fFdc85188F11c04F4D772640");

//     // make merge request
//     // await recorder.makeMergeRequest(getPubkey(8, 7), getSignatureByIds(getMessage2(0, 8, 7), 8, 7), 10000, {gasLimit: 2000000});
//     // console.log( await recorder.mergeRequest(users[8].pubkey), users[7].pubkey );
//     // console.log("nonce", await recorder.nonce());


//     // await recorder.makeMergeRequest(getPubkey(8, 5), getSignatureByIds(getMessage2(1, 8, 5), 8, 5), 10000, {gasLimit: 2000000});
//     // console.log( await recorder.mergeRequest(users[8].pubkey), users[5].pubkey );
//     // console.log("nonce", await recorder.nonce());

//     /////////
//     const multiSigFactory = await ethers.getContractAt("MultiSigWalletFactory", "0xdB4e35F36b9Ce55822a6d88F097107B52d0bF79f");
//     console.log("-----", await multiSigFactory.ownerToMultiSigWallet("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"));
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
// });