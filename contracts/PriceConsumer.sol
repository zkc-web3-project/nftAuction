// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
//这里可以用导入的AggregatorV3Interface接口，也可以用下面自定义的AggregatorV3Interface接口
// import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";  


// 定义 AggregatorV3Interface 接口
interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}


contract PriceConsumer {
    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal linkUsdPriceFeed;

    // Sepolia 测试网价格源地址
    address constant ETH_USD_SEPOLIA = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant LINK_USD_SEPOLIA = 0xc59E3633BAAC79493d908e63626716e204A45EdF;

    constructor() {
        ethUsdPriceFeed = AggregatorV3Interface(ETH_USD_SEPOLIA);
        linkUsdPriceFeed = AggregatorV3Interface(LINK_USD_SEPOLIA);
    }

    function getETHPrice() public view returns (int) {
        (, int price, , , ) = ethUsdPriceFeed.latestRoundData();
        return price;
    }

    function getLINKPrice() public view returns (int) {
        (, int price, , , ) = linkUsdPriceFeed.latestRoundData();
        return price;
    }

    function convertETHToUSD(uint256 ethAmount) public view returns (uint256) {
        int ethPrice = getETHPrice();
        require(ethPrice > 0, "Invalid ETH price");
        
        // price 有 8 位小数，ethAmount 有 18 位小数
        // 所以需要调整小数位数
        return (ethAmount * uint256(ethPrice)) / 1e8;
    }

    function convertLINKToUSD(uint256 linkAmount) public view returns (uint256) {
        int linkPrice = getLINKPrice();
        require(linkPrice > 0, "Invalid LINK price");
        
        return (linkAmount * uint256(linkPrice)) / 1e8;
    }
}