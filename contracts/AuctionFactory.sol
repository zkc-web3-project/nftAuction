// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./Auction.sol";

contract AuctionFactory {
    address[] public auctions;
    mapping(address => bool) public isAuction;
    mapping(address => address[]) public userAuctions;

    event AuctionCreated(address indexed seller, address auctionAddress, address nftAddress, uint256 tokenId);

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _duration
    ) external returns (address) {
        // 创建新的拍卖合约
        Auction newAuction = new Auction(
            msg.sender,
            _nftAddress,
            _tokenId,
            _duration
        );

        address auctionAddress = address(newAuction);
        auctions.push(auctionAddress);
        isAuction[auctionAddress] = true;
        userAuctions[msg.sender].push(auctionAddress);

        emit AuctionCreated(msg.sender, auctionAddress, _nftAddress, _tokenId);
        return auctionAddress;
    }

    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }

    function getUserAuctions(address user) external view returns (address[] memory) {
        return userAuctions[user];
    }

    function getAuctionsCount() external view returns (uint256) {
        return auctions.length;
    }
}