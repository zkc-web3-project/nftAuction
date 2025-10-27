const { ethers, upgrades } = require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const AuctionFactoryV2 = await ethers.getContractFactory("AuctionFactoryV2");
  
  const factory = await upgrades.deployProxy(AuctionFactoryV2, [], {
    initializer: "initialize",
    kind: "uups",
  });

  await factory.deployed();
  console.log("AuctionFactoryV2 deployed to:", factory.address);
};

module.exports.tags = ["AuctionFactoryV2"];