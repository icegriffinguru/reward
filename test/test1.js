const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NODERewardManagement", function () {
  it("Should be deployed", async function () {
    const IterableMapping = await ethers.getContractFactory("IterableMapping");
    const iterableMapping = await IterableMapping.deploy();

    const NODERewardManagement = await ethers.getContractFactory("NODERewardManagement", {
      libraries: {
        IterableMapping: iterableMapping.address,
      },
    });

    const _nodePrice = 50;
    const _rewardPerNode = 10;
    const _claimTime = 100;
    const nodeRewardManager = await NODERewardManagement.deploy(_nodePrice, _rewardPerNode, _claimTime);
    await nodeRewardManager.deployed();

    // check address is not zero
    expect(await nodeRewardManager.address).to.not.equal(0);
  });
});