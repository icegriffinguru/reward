const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NODERewardManagement", function () {
  let iterableMapping;
  let nodeRewardManager;
  let owner, addr1, addr2, addrs;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Get the ContractFactory and Signers here.
    const IterableMapping = await ethers.getContractFactory("IterableMapping");
    iterableMapping = await IterableMapping.deploy();

    const NODERewardManagement = await ethers.getContractFactory("NODERewardManagement", {
      libraries: {
        IterableMapping: iterableMapping.address,
      },
    });

    const _nodePrice = 50;
    const _rewardPerNode = 10;
    const _claimTime = 100;
    nodeRewardManager = await NODERewardManagement.deploy(_nodePrice, _rewardPerNode, _claimTime);
    await nodeRewardManager.deployed();

    // check address is not zero
    expect(await nodeRewardManager.address).to.not.equal(0);
  });

  it("Should be deployed", async function () {
    //address account, string memory nodeName
    const nodeName1 = 'Account1 - Node1';
    nodeRewardManager.createNode(addr1.address, nodeName1);

    // nodeRewardManager.createNode(addr1.address, nodeName1);
    // expect(() => {
    //   nodeRewardManager.createNode(addr1.address, nodeName1);
    // }).to.throw('Cannot create a node with the same name by one user');
  });
});