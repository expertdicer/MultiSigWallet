require("dotenv").config();
const ethers = require('ethers')
const Web3 = require("web3");

var web3 = new Web3();
web3.eth.defaultAccount = "0x3Bb94b440bFd48a0948E165F68554AD7EA1ecf65";

const user = "0x3Bb94b440bFd48a0948E165F68554AD7EA1ecf65";
const mes = "test sign mess";
let users2 = [
  {
      chainId: 56,
      pubkey: '0x9bce4936c65d6440c18b6211410630273bc9a243139ded6c28e16ec373d9a555d0be9ea5a9e1817197e74d5dd81bcdc106d5871962a14e99d2da4fc6e2d70ec4'
  },
]  
let users = [
  {
      chainId: 56,
      pubkey: '0x9bce4936c65d6440c18b6211410630273bc9a243139ded6c28e16ec373d9a555d0be9ea5a9e1817197e74d5dd81bcdc106d5871962a14e99d2da4fc6e2d70ec4'
  },
  {
      chainId: '0x0000000000000038',
      pubkey: '0xc78e4c04b149d256751e625760812ac17dad79ee8928ef449631b813caf5cdf17178bc9c3f7ad48992d25546894937400387b173e526eea27d72174376b8ccbf'
  },
  {
      chainId: '0x0000000000000038',
      pubkey: '0xd9fd1e07c27081af36af154ee93f7c51653cea405a9c1dedb26ac2aa0dac611dfb600e3f9f0a3d39538e938dd8f3241807b45b938998edccdc87e58f0236929b'
  }
]
function packUserFusionData(datas) {
  var ret = '0x';
  for (let data of datas) {
      let id = data.chainId;
      if (!isNaN(data.chainId))
          id = ethers.BigNumber.from(id).toHexString();
      ret += id.slice((id.indexOf('0x') === 0) ? 2 : 0);
      ret += data.pubkey.slice((data.pubkey.indexOf('0x') === 0) ? 2 : 0);
  }
  return [ret, ret.length / 2 - 1];
}

const account = web3.eth.accounts.privateKeyToAccount(
  `0x${process.env.PRIVATE_KEY}`
);

const constructData = (user, mes) => {
  return web3.utils.soliditySha3(
    { t: "address", v: user },
    { t: "string", v: mes }
  );
};

const signMessage = async (message) => {
  var signature = await web3.eth.accounts.sign(
    message,
    `0x${process.env.PRIVATE_KEY}`
  );
  return signature;
};

const recover = async (messageHash, v, r, s) => {
  const address = await web3.eth.accounts.recover({
    messageHash,
    v,
    r,
    s,
  });

  console.log(address);
};



var data = constructData(user, mes);
data = packUserFusionData(users2);
data = '0x00000000000000389bce4936c65d6440c18b6211410630273bc9a243139ded6c28e16ec373d9a555d0be9ea5a9e1817197e74d5dd81bcdc106d5871962a14e99d2da4fc6e2d70ec4'
signMessage(data).then((result) => {
  console.log(result);
  recover(result.messageHash, result.v, result.r, result.s);

  
});

signMessage(data).then((result) => {
  console.log(result);
  recover(result.messageHash, result.v, result.r, result.s);

  
});

signMessage(data).then((result) => {
  console.log(result);
  recover(result.messageHash, result.v, result.r, result.s);

  
});

