var SafeMath = artifacts.require('./SafeMath.sol');
var StarCoin = artifacts.require("./StarCoin.sol");
var StarCoinPreSale = artifacts.require("./StarCoinPreSale.sol");
var InvestorWhiteList = artifacts.require("./InvestorWhiteList.sol");

module.exports = async function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, StarCoin);
  deployer.link(SafeMath, StarCoinPreSale);
  deployer.deploy(StarCoin).then(async function() {
    await deployer.deploy(InvestorWhiteList);
    const token = StarCoin.address;
    const investorWhiteList = InvestorWhiteList.address;
    const hardCap = 632860;
    const softCap = 0;
    const beneficiary = web3.eth.accounts[0];
    const startBlock = web3.eth.blockNumber;
    const endBlock = web3.eth.blockNumber + 100;
    deployer.deploy(StarCoinPreSale, hardCap, softCap, token, beneficiary, investorWhiteList, startBlock, endBlock);
  });
};
