require("dotenv").config();
const { expect, assert, use } = require("chai");
const { hexStripZeros } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256');
const Web3 = require("web3");

//var web3 = new Web3(new Web3.providers.HttpProvider(`${process.env.RINKEBYURL}`));
var web3 = new Web3();

const hre = require("hardhat");


const users = [...Array(11).keys()].map(k => ({ pubkey: process.env[`add-${k}`], prikey: process.env[`pri-${k}`]}))


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

    // create wallet 1
    while(true) {
      try {
        console.log("start create wallet 1!!");
        const fatoryCreateTx1 = await multiSigFactory.create(getPubkey(0, 1, 2), 1, getSignatureByIds(getMessage(0, 1, 2), 0, 1, 2), 10000, {gasLimit: 2000000});
        await fatoryCreateTx1.wait();
      } catch(e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[0].pubkey, users[1].pubkey]);

      if (checkSame) {
        console.log("Create wallet 1", await multiSigFactory.getAllAddress(users[0].pubkey));
        break;
      }
    }

    // create wallet 2
    while(true) {
      try {
        console.log("start create wallet 2!!");
        const fatoryCreateTx2 = await multiSigFactory.create(getPubkey(3, 4, 5), 1, getSignatureByIds(getMessage(3, 4, 5), 3, 4, 5), 10000, {gasLimit: 2000000});
        await fatoryCreateTx2.wait();
      } catch(e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[3].pubkey, users[4].pubkey]);

      if (checkSame) {
        console.log("Create wallet 2", await multiSigFactory.getAllAddress(users[3].pubkey));
        break;
      }
    }

    // create recoder merRequest address 0 vs address 3
    while(true) {
      const nonceBefore = Number(await recorder.nonce());
      try {
        console.log("start create tx mer request!!");
        const createMerRequest1 = await recorder.makeMergeRequest(getPubkey(0, 3), getSignatureByIds(getMessage2(nonceBefore, 0, 3), 0, 3), 10000, {gasLimit: 2000000});
        await createMerRequest1.wait();
      } catch (e) {
        console.log(e);
      }
      
      const nonceAfter = Number(await recorder.nonce());
      if (nonceAfter > nonceBefore) {
        console.log("create merge request", users[0].pubkey, users[3].pubkey);
        break;
      }
      
    }

    // connect wallet 1 vs wallet 2
    while(true) {
      try {
        console.log("start create tx connect address!!");
        const connectAddress = await multiSigFactory.addAddress(getPubkey(0, 3), getSignatureByIds( getMessage(0, 3), 0, 3 ), 1000, {gasLimit: 2000000})
      } catch (e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[0].pubkey, users[3].pubkey]);
      if (checkSame) {
        console.log("Connect two address", users[0].pubkey, users[3].pubkey);
        console.log("after connect, all address of wallet", await multiSigFactory.getAllAddress(users[0].pubkey));
        break;
      } 
    }

    // create merge request address 0 vs address 6
    while(true) {
      const nonceBefore = Number(await recorder.nonce());
      try {
        console.log("start merge request!!");
        const createMerRequest1 = await recorder.makeMergeRequest(getPubkey(0, 6), getSignatureByIds(getMessage2(nonceBefore, 0, 6), 0, 6), 10000, {gasLimit: 2000000});
        await createMerRequest1.wait();
      } catch (e) {
        console.log(e);
      }
      
      const nonceAfter = Number(await recorder.nonce());
      if (nonceAfter > nonceBefore) {
        console.log("create merge request", users[0].pubkey, users[6].pubkey);
        break;
      }
      
    }

    // create wallet 3
    while(true) {
      try {
        console.log("start create wallet 2!!");
        const fatoryCreateTx2 = await multiSigFactory.create(getPubkey(7, 8), 1, getSignatureByIds(getMessage(7, 8), 7, 8), 10000, {gasLimit: 2000000});
        await fatoryCreateTx2.wait();
      } catch(e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[7].pubkey, users[8].pubkey]);

      if (checkSame) {
        console.log("Create wallet 3", await multiSigFactory.getAllAddress(users[7].pubkey));
        break;
      }
    }

    // create merge request address 0 vs address 8
    while(true) {
      const nonceBefore = Number(await recorder.nonce());
      try {
        console.log("start merge request!!");
        const createMerRequest1 = await recorder.makeMergeRequest(getPubkey(0, 8), getSignatureByIds(getMessage2(nonceBefore, 0, 8), 0, 8), 10000, {gasLimit: 2000000});
        await createMerRequest1.wait();
      } catch (e) {
        console.log(e);
      }
      
      const nonceAfter = Number(await recorder.nonce());
      if (nonceAfter > nonceBefore) {
        console.log("create merge request", users[0].pubkey, users[8].pubkey);
        break;
      }
      
    }

    // create merge request address 0 vs address 9
    while(true) {
      const nonceBefore = Number(await recorder.nonce());
      try {
        console.log("start merge request!!");
        const createMerRequest1 = await recorder.makeMergeRequest(getPubkey(0, 9), getSignatureByIds(getMessage2(nonceBefore, 0, 9), 0, 9), 10000, {gasLimit: 2000000});
        await createMerRequest1.wait();
      } catch (e) {
        console.log(e);
      }
      
      const nonceAfter = Number(await recorder.nonce());
      if (nonceAfter > nonceBefore) {
        console.log("create merge request", users[0].pubkey, users[9].pubkey);
        break;
      }
      
    }

    // create merge request address 5 vs address 10
    while(true) {
      const nonceBefore = Number(await recorder.nonce());
      try {
        console.log("start merge request!!");
        const createMerRequest1 = await recorder.makeMergeRequest(getPubkey(5, 10), getSignatureByIds(getMessage2(nonceBefore, 5, 10), 5, 10), 10000, {gasLimit: 2000000});
        await createMerRequest1.wait();
      } catch (e) {
        console.log(e);
      }
      
      const nonceAfter = Number(await recorder.nonce());
      if (nonceAfter > nonceBefore) {
        console.log("create merge request", users[5].pubkey, users[10].pubkey);
        break;
      }
      
    }

    // connect address 0, 8
    while(true) {
      try {
        console.log("start create tx connect address!!");
        const connectAddress = await multiSigFactory.addAddress(getPubkey(0, 8), getSignatureByIds( getMessage(0, 8), 0, 8 ), 1000, {gasLimit: 2000000})
      } catch (e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[0].pubkey, users[8].pubkey]);
      if (checkSame) {
        console.log("Connect two address", users[0].pubkey, users[8].pubkey);
        console.log("after connect, all address of wallet", await multiSigFactory.getAllAddress(users[0].pubkey));
        break;
      } 
    }

    // connect address 0, 9
    while(true) {
      try {
        console.log("start create tx connect address!!");
        const connectAddress = await multiSigFactory.addAddress(getPubkey(0, 9), getSignatureByIds( getMessage(0, 9), 0, 9 ), 1000, {gasLimit: 2000000})
      } catch (e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[0].pubkey, users[9].pubkey]);
      if (checkSame) {
        console.log("Connect two address", users[0].pubkey, users[9].pubkey);
        console.log("after connect, all address of wallet", await multiSigFactory.getAllAddress(users[0].pubkey));
        break;
      } 
    }

    // connect address 5, 10
    while(true) {
      try {
        console.log("start create tx connect address!!");
        const connectAddress = await multiSigFactory.addAddress(getPubkey(5, 10), getSignatureByIds( getMessage(5, 10), 5, 10 ), 1000, {gasLimit: 2000000})
      } catch (e) {
        console.log(e);
      }

      const checkSame = await multiSigFactory.checkSameUser([users[5].pubkey, users[10].pubkey]);
      if (checkSame) {
        console.log("Connect two address", users[5].pubkey, users[10].pubkey);
        console.log("after connect, all address of wallet", await multiSigFactory.getAllAddress(users[5].pubkey));
        break;
      } 
    }


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
