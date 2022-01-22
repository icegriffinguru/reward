const { expect, assert } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

const fs = require("fs");

const address = require("./utils/address");
const {
    convertFromBigNumber,
    convertToBigNumber
} = require("./utils/convertBigNumber.js");

/////////////////////////////////
// Params
/////////////////////////////////
const gasAddUp = 50000;

const nodePrice = convertToBigNumber(10);
const rewardPerNode = convertToBigNumber(1.1 / 6); // 11 / day as 10% cashoutFee roi = 10 days
const claimTime = 4 * 3600;
// const claimTime = 100;

const shares = [ // payees shares, total must be 100, must match address.Payees.length
    45,
    45,
    10,
];
const balances = [ // must match address.Addresses.length 
    // total will be initial total supply
    1, // supply
    1, // futurUsePool
    910000, // distributionPool
    10000, // liquidityPool creation
    26666,
    26666,
    26666,
];

// [1,1,910000,10000,26666,26666,26666]
const fees = [
    // totalFee = rewardsFee + liquidityPoolFee + futurFee
    10, // futurFee (Node creation: contract balance perc sent to futurUsePool) avax
    60, // rewardsFee (Node creation: contract balance perc to calc rewardsPoolTokens)
    10, // liquidityPoolFee (Node creation: contract balance perc to add lp liquidity) avax/tokens
    10, // cashoutFee (cashout: reward amount perc sent to futurUsePool) avax
    1 // rwSwap (Node creation: rewardsPoolTokens perc sent to distributionPool) avax
    // (rewardsPoolTokens - (rwSwap calc) sent to distributionPool) tokens
];
const swapAmount = 50; // * 10**18 swapTokensAmount compared with contract balance (createNode swaps)
/////////////////////////////////


async function replaceInAddressFile(searchPattern, newLine) {
    return new Promise((resolve, error) => {
        fs.readFile("./scripts/address.js", "utf8", function(err, data) {
            let formatted = data.replace(searchPattern, newLine);
            fs.writeFile("./scripts/address.js", formatted, function(err) {
                if (err)
                    console.log(err);
                resolve();
            })
        })
    })
}

const convertSolIntToBigNumber = (v) => {
  return v.value;
};

describe("NODERewardManagement", function () {
  let iterableMapping;
  let nodeRewardManager;
  let owner, addr1, addr2, addr3, addrs;
  let nodePrice, rewardPerNode, claimTime;
  let polar;
  
  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    // let [owner, payees, addresses, metamask] = await getWallets();

    // Get the ContractFactory and Signers here.
    const IterableMapping = await ethers.getContractFactory("IterableMapping");
    iterableMapping = await IterableMapping.deploy();

    const NODERewardManagement = await ethers.getContractFactory("NODERewardManagement", {
      libraries: {
        IterableMapping: iterableMapping.address,
      },
    });

    nodePrice = 50;
    rewardPerNode = 10;
    claimTime = 2;
    nodeRewardManager = await NODERewardManagement.deploy(nodePrice, rewardPerNode, claimTime);
    await nodeRewardManager.deployed();

    // check address is not zero
    expect(await nodeRewardManager.address).to.not.equal(0);

    // create polar
    const PolarNodesV2 = await ethers.getContractFactory("PolarNodesV2");
      // , {
      // libraries: {
      //   IterableMapping: iterableMapping.address,
      // },
      // }
    // );

    // Token Contract
    // const payees = [addr1.address, addr2.address, addr3.address]
    // const addresses = [addr1.address, addr2.address, addr3.address, addrs[0].address, addrs[1].address, addrs[2].address, addrs[3].address]
    // const PolarNodesV2 = await ethers.getContractFactory("PolarNodes");
    polar = await PolarNodesV2.connect(owner).deploy(
      address.Payees, shares, address.Addresses,
      balances, fees, swapAmount, address.JoeRouter, {
          gasLimit: "0x1000000"
      }
    );
    await polar.callStatic.setNodeManagement(nodeRewardManager.address);
    // str = "const Token = \"" + token.address + "\";";
    // console.log(str);
    // await replaceInAddressFile(/const Token(.*);/g, str)
    // await token.deployed();

    // const polar = await PolarNodesV2.deploy([addr2], [100], [addr2], [100], [100, 100, 100, 100], 1000, addr3);
    // console.log(polar);
    // constructor(
    //   address[] memory payees,
    //   uint256[] memory shares,
    //   address[] memory addresses,
    //   uint256[] memory balances,
    //   uint256[] memory fees,
    //   uint256 swapAmount,
    //   address uniV2Router
  });

  it("Create nodes and check properties", async function () {


    // //address account, string memory nodeName
    // const nodeName1 = 'Account1 - Node1';
    // nodeRewardManager.createNode(addr1.address, nodeName1);

    // // create another nodes
    // nodeRewardManager.createNode(addr1.address, 'Account1 - Node2');
    // nodeRewardManager.createNode(addr1.address, 'Account1 - Node3');
    // nodeRewardManager.createNode(addr1.address, 'Account1 - Node4');
    // nodeRewardManager.createNode(addr2.address, 'Account2 - Node1');
    // nodeRewardManager.createNode(addr2.address, 'Account2 - Node2');
    // nodeRewardManager.createNode(addr3.address, 'Account3 - Node1');
    // nodeRewardManager.createNode(addr3.address, 'Account3 - Node2');

    // // check length of the name of the created node is the same
    // const names1 = await nodeRewardManager._getNodesNames(addr1.address);
    // const names2 = await nodeRewardManager._getNodesNames(addr2.address);
    // const names3 = await nodeRewardManager._getNodesNames(addr3.address);
    // // console.log('names', names);
    // expect(names1).to.have.lengthOf(nodeName1.length * 4 + 3);
    // expect(names2).to.have.lengthOf(nodeName1.length * 2 + 1);
    // expect(names3).to.have.lengthOf(nodeName1.length * 2 + 1);

    // // solidity's timestamp is in seconds
    // const creationTime1 = await nodeRewardManager._getNodesCreationTime(addr1.address);
    // const creationTime2 = await nodeRewardManager._getNodesCreationTime(addr2.address);
    // const creationTime3 = await nodeRewardManager._getNodesCreationTime(addr3.address);
    // // check creation time is not zero
    // expect(creationTime1).to.not.equal('');
    // expect(creationTime2).to.not.equal('');
    // expect(creationTime3).to.not.equal('');

    // // creation time array of each account
    // const cts1 = creationTime1.split('#')
    // const cts2 = creationTime2.split('#')
    // const cts3 = creationTime3.split('#')
    // console.log('Creation Times: ', cts1, cts2, cts3)

    // // check properties of nodeRewardManager
    // const _claimTime = await nodeRewardManager.claimTime();
    // const _nodePrice = await nodeRewardManager.nodePrice();
    // const _rewardPerNode = await nodeRewardManager.rewardPerNode();
    // console.log('_claimTime', parseInt(_claimTime))
    // console.log('_nodePrice', parseInt(_nodePrice))
    // console.log('_rewardPerNode', parseInt(_rewardPerNode))
    // assert(_claimTime.eq(ethers.BigNumber.from(claimTime)));
    // assert(_nodePrice.eq(ethers.BigNumber.from(nodePrice)));
    // assert(_rewardPerNode.eq(ethers.BigNumber.from(rewardPerNode)));
    // // expect('claimTime', _claimTime).to.equal(claimTime);
    // // expect('nodePrice', _nodePrice).to.equal(nodePrice);
    // // expect('rewardPerNode', _rewardPerNode).to.equal(rewardPerNode);

    // //# formula reward = rewardPerNode * (block.timestamp - node.lastClaimTime) / claimTime

    // //# check list
    // // function _cashoutNodeReward(address account, uint256 _creationTime)
    // const _nodeReward11 = await nodeRewardManager.callStatic._cashoutNodeReward(addr1.address, cts1[0])
    // console.log('_nodeReward11', _nodeReward11);
    // // assert(_nodeReward11.eq(ethers.BigNumber.from(rewardPerNode)));


    // // function _cashoutAllNodesReward(address account)
    // const _nodeReward1 = await nodeRewardManager.callStatic._cashoutAllNodesReward(addr1.address)
    // console.log('_nodeReward1', _nodeReward1);
   

    // function claimable(NodeEntity memory node) private view returns (bool) {
    // function _getRewardAmountOf(address account)
    // function _getRewardAmountOf(address account, uint256 _creationTime)
    // function _getNodeRewardAmountOf(address account, uint256 creationTime)
    // function _getNodesNames(address account)
    // function _getNodesCreationTime(address account)
    // function _getNodesRewardAvailable(address account)
    // function _getNodesLastClaimTime(address account)
    // function _changeNodePrice(uint256 newNodePrice) external onlySentry {
    // function _changeRewardPerNode(uint256 newPrice) external onlySentry {
    // function _changeClaimTime(uint256 newTime) external onlySentry {
    // function _changeAutoDistri(bool newMode) external onlySentry {
    // function _changeGasDistri(uint256 newGasDistri) external onlySentry {
    // function _getNodeNumberOf(address account) public view returns (uint256) {

    // const temp = await nodeRewardManager.callStatic.isNameAvailable(addr1.address, 'name')
    
    await nodeRewardManager.createNode(addr3.address, 'Account1 - Node2');
    await nodeRewardManager.createNode(addr3.address, 'Account1 - Node3');
    await nodeRewardManager.createNode(addr3.address, 'Account1 - Node4');
    await nodeRewardManager.createNode(addr2.address, 'Account2 - Node1');
    await nodeRewardManager.createNode(addr2.address, 'Account2 - Node2');
    await nodeRewardManager.moveAccount(nodeRewardManager.address, addr3.address)
    const names1_again = await nodeRewardManager._getNodesNames(addr3.address);
    console.log('names1_again', names1_again);

    await nodeRewardManager.moveAccount(nodeRewardManager.address, addr2.address)
    const names2_again = await nodeRewardManager._getNodesNames(addr2.address);
    console.log('names2_again', names2_again);
  });
});