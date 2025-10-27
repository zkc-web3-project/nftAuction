// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Auction is ReentrancyGuard {
    address public seller;
    address public nftAddress;
    uint256 public nftTokenId;
    uint256 public endTime;
    address public highestBidder;
    uint256 public highestBid;
    bool public ended;

    event AuctionCreated(address indexed seller, address nftAddress, uint256 tokenId, uint256 endTime);
    event BidPlaced(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < endTime, "Auction has ended");
        require(!ended, "Auction already ended");
        _;
    }

    constructor(
        address _seller,
        address _nftAddress,
        uint256 _nftTokenId,
        uint256 _duration
    ) {
        seller = _seller;
        nftAddress = _nftAddress;
        nftTokenId = _nftTokenId;
        endTime = block.timestamp + _duration;
        ended = false;

        // 转移NFT到拍卖合约
        IERC721(nftAddress).transferFrom(seller, address(this), nftTokenId);

        emit AuctionCreated(seller, nftAddress, nftTokenId, endTime);
    }

    function bid() external payable auctionActive nonReentrant {
        require(msg.value > highestBid, "Bid must be higher than current bid");

        // 退还前一个最高出价者的资金
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function endAuction() external nonReentrant {
        require(block.timestamp >= endTime || msg.sender == seller, "Auction not ended");
        require(!ended, "Auction already ended");

        ended = true;

        if (highestBidder != address(0)) {
            // 转移NFT给最高出价者
            IERC721(nftAddress).transferFrom(address(this), highestBidder, nftTokenId);
            // 转移资金给卖家
            payable(seller).transfer(highestBid);
            
            emit AuctionEnded(highestBidder, highestBid);
        } else {
            // 无人出价，退回NFT给卖家
            IERC721(nftAddress).transferFrom(address(this), seller, nftTokenId);
            
            emit AuctionEnded(address(0), 0);
        }
    }

    function getAuctionDetails() external view returns (
        address _seller,
        address _nftAddress,
        uint256 _nftTokenId,
        uint256 _endTime,
        address _highestBidder,
        uint256 _highestBid,
        bool _ended
    ) {
        return (seller, nftAddress, nftTokenId, endTime, highestBidder, highestBid, ended);
    }
}