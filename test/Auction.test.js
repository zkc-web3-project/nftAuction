const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT Auction Market", function () {
  let nft;
  let auctionFactory;
  let priceConsumer;
  let owner;
  let seller;
  let bidder1;
  let bidder2;

  beforeEach(async function () {
    [owner, seller, bidder1, bidder2] = await ethers.getSigners();

    // 部署 NFT 合约
    const MyNFT = await ethers.getContractFactory("MyNFT");
    nft = await MyNFT.deploy();
    await nft.deployed();

    // 部署拍卖工厂
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    auctionFactory = await AuctionFactory.deploy();
    await auctionFactory.deployed();

    // 部署价格预言机
    const PriceConsumer = await ethers.getContractFactory("PriceConsumer");
    priceConsumer = await PriceConsumer.deploy();
    await priceConsumer.deployed();
  });

  describe("NFT Contract", function () {
    it("Should mint NFT successfully", async function () {
      await nft.connect(seller).mint(seller.address);
      expect(await nft.ownerOf(1)).to.equal(seller.address);
    });
  });

  describe("Auction Factory", function () {
    it("Should create auction successfully", async function () {
      // 卖家铸造NFT
      await nft.connect(seller).mint(seller.address);
      
      // 卖家授权工厂合约可以转移NFT
      await nft.connect(seller).approve(auctionFactory.address, 1);

      // 创建拍卖
      const duration = 24 * 60 * 60; // 24小时
      await auctionFactory.connect(seller).createAuction(nft.address, 1, duration);

      const auctions = await auctionFactory.getAllAuctions();
      expect(auctions.length).to.equal(1);
    });
  });

  describe("Auction", function () {
    let auction;
    const duration = 24 * 60 * 60; // 24小时

    beforeEach(async function () {
      // 设置拍卖
      await nft.connect(seller).mint(seller.address);
      await nft.connect(seller).approve(auctionFactory.address, 1);
      
      await auctionFactory.connect(seller).createAuction(nft.address, 1, duration);
      
      const auctions = await auctionFactory.getAllAuctions();
      const Auction = await ethers.getContractFactory("Auction");
      auction = await Auction.attach(auctions[0]);
    });

    it("Should place bid successfully", async function () {
      const bidAmount = ethers.utils.parseEther("0.1");
      
      await auction.connect(bidder1).bid({ value: bidAmount });
      
      expect(await auction.highestBidder()).to.equal(bidder1.address);
      expect(await auction.highestBid()).to.equal(bidAmount);
    });

    it("Should reject lower bid", async function () {
      const firstBid = ethers.utils.parseEther("0.1");
      const secondBid = ethers.utils.parseEther("0.05");
      
      await auction.connect(bidder1).bid({ value: firstBid });
      
      await expect(
        auction.connect(bidder2).bid({ value: secondBid })
      ).to.be.revertedWith("Bid must be higher than current bid");
    });

    it("Should end auction and transfer NFT", async function () {
      const bidAmount = ethers.utils.parseEther("0.1");
      
      await auction.connect(bidder1).bid({ value: bidAmount });
      
      // 增加时间到拍卖结束
      await ethers.provider.send("evm_increaseTime", [duration + 1]);
      await ethers.provider.send("evm_mine");
      
      await auction.connect(seller).endAuction();
      
      expect(await nft.ownerOf(1)).to.equal(bidder1.address);
    });
  });

  describe("Price Consumer", function () {
    it("Should get ETH price", async function () {
      const price = await priceConsumer.getETHPrice();
      expect(price).to.be.gt(0);
    });

    it("Should convert ETH to USD", async function () {
      const ethAmount = ethers.utils.parseEther("1");
      const usdValue = await priceConsumer.convertETHToUSD(ethAmount);
      expect(usdValue).to.be.gt(0);
    });
  });
});