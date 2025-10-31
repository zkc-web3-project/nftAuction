// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {

    uint256 private _tokenIds;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    //NFT铸造
    function mint(address to) public returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);
        return newTokenId;
    }
    //NFT转移
    function transferNFT(address from, address to, uint256 tokenId) public onlyOwner{
        require(ownerOf(tokenId) == from, "You are not the owner of this NFT");
        _transfer(from, to, tokenId);
    }

    function getCurrentTokenId() public view returns (uint256) {
        return _tokenIds;
    }
}