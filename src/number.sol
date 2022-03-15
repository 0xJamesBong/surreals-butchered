// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "../lib/ds-test/src/console.sol";

contract Number is ERC721Enumerable {
    // ReentrancyGuard, Ownable
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Number", "Num") {}
    
    // order describes how many NFTs of the same number has been minted
    //  a virgin number has order of 0 
    // first mints of a number has order 0
    // the order updates every time a number is minted
    struct numN {
        uint256 number;
        uint256 order;
    }

    // the Metadata Struct stores the metadata of each NFT 
    // each tokenId has its own metadata Struct

    struct Metadata {
        uint256 number;
        uint256 mintTime;
        uint256 order;
    }

    mapping(uint256 => numN) num_to_numN;
    mapping(uint256 => Metadata) tokenId_to_metadata;

    function anotherMint(address to, uint256 num) public returns (uint256) {
        
        // checks if num is new, if new, increases its order to 1 (first!)
        // if not new, does nothing and goes straight next
        if ( num_to_numN[num].order == 0 ) {
            num_to_numN[num].number = num;
            num_to_numN[num].order = 1;
        }
        
        uint256 order = num_to_numN[num].order;
        uint256 tokenId = _tokenIdCounter.current();
        uint256 mintTime = Time();
        tokenId_to_metadata[tokenId] = Metadata(num, mintTime, order);
        num_to_numN[num].order+=1; 
        _tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        return tokenId;
    }



    function getCurrentTokenId() public view returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId;
    }

    function getMinttimeFromTokenId(uint256 tokenId) public view returns (uint256) {
        uint256 minttime = tokenId_to_metadata[tokenId].mintTime;
        return minttime;
    }
 
    function getNumFromTokenId(uint256 tokenId) public view returns (uint256) {
        // uint256 num = tokenId_to_number[tokenId];
        uint256 num = tokenId_to_metadata[tokenId].number;
        return num;
    }

    function Time() public view returns (uint256) {
        uint256 createTime = block.timestamp;
        return createTime;
    }

    function getOrderFromTokenId(uint256 tokenId) public view returns (uint256) {
        uint256 order = tokenId_to_metadata[tokenId].order; 
        return order;
    }
    
}