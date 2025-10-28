// require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-ignition");

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    // 你也可以配置本地网络用于测试
    localhost: {
      chainId: 31337,
    }
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};