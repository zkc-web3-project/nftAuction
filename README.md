# NFT拍卖市场

## 项目介绍
    该项目是一个基于Solidity的NFT拍卖市场，使用Hardhat作为测试环境，主要功能包括：
1. 基础的 NFT 合约 - 支持铸造和转移
2. 拍卖合约 - 支持创建拍卖、出价和结束拍卖
3. 工厂模式 - 管理多个拍卖实例
4. Chainlink 集成 - 获取价格数据
5. 可升级合约 - 使用 UUPS 模式
6. 完整的测试覆盖

## 运行package.json 中添加脚本
{
  "scripts": {
    "test": "npx hardhat test",
    "deploy": "npx hardhat deploy --network localhost",
    "deploy:sepolia": "npx hardhat deploy --network sepolia",
    "node": "npx hardhat node"
  }
}
## 运行测试
npx hardhat test
## 启动本地节点
npx hardhat node
## 部署到本地节点
npx hardhat deploy --network localhost
## 部署到Sepolia测试网络
npx hardhat deploy --network sepolia
