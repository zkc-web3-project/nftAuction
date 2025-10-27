// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Auction.sol";

contract AuctionFactoryV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public auctions;
    mapping(address => bool) public isAuction;
    mapping(address => address[]) public userAuctions;
    uint256 public feePercentage; // 新增功能：收取手续费
    address public feeRecipient;

    event AuctionCreated(address indexed seller, address auctionAddress, address nftAddress, uint256 tokenId);
    event FeeUpdated(uint256 newFeePercentage);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        feePercentage = 100; // 1% 手续费
        feeRecipient = msg.sender;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _duration
    ) external returns (address) {
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

    // 新增功能：设置手续费
    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 1000, "Fee too high"); // 最大10%
        feePercentage = _feePercentage;
        emit FeeUpdated(_feePercentage);
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
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

    // 新增功能：计算手续费
    function calculateFee(uint256 amount) public view returns (uint256) {
        return (amount * feePercentage) / 10000;
    }
}