const { ethers } = require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("AuctionFactory", {
    from: deployer,
    args: [],
    log: true,
  });
};

module.exports.tags = ["AuctionFactory"];