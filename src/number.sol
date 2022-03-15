// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Number is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Number", "Num") {}

    uint256 public createTime;
    
    struct metadata{
        uint256 number;
        uint256 mintTime;
    }
    
    mapping(uint256 => bool) public tokenId_to_firstOrNot;
    mapping(uint256 => uint256) public tokenId_to_number;
    mapping(uint256 => uint256) public tokenId_to_minttime;

    
    function getFirstBool(uint256 tokenId) public view returns (bool) {
        bool whetherFirstOrNot = tokenId_to_firstOrNot[tokenId];
        return whetherFirstOrNot;
    }

    function getNumber(uint256 tokenId) public view returns (uint256) {
        uint256 number = tokenId_to_number[tokenId];
        return number;
    }

    function getMinttime(uint256 tokenId) public view returns (uint256) {
        uint256 minttime = tokenId_to_minttime[tokenId];
        return minttime;
    }

    function safeMint(address to, uint256 number) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        tokenId_to_number[tokenId] = number;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function getCurrentTokenId() public view returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId;
    }

    // function Time() public {
    //     createTime = block.timestamp;
    // }

    // function safeMint(address to, uint256 number) public {
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    //     console.log(createTime);
    //     Time();
    //     console.log(createTime);
    //     writeMetadata(number, createTime, tokenId);
    // }

    // function writeMetadata(uint256 _time, uint256 _number, uint256 tokenId) private {
    //     tokenId_to_metadata[tokenId] = metadata({
    //         time: _time,
    //         number: _number
    //     });
        
    // }

    // function readMetadata(uint256 tokenId) public view returns (uint256, uint256) {
    //     // metadata = tokenId_to_metadata[tokenId];
    //     uint256 time = tokenId_to_metadata[tokenId].time;
    //     uint256 number = tokenId_to_metadata[tokenId].number;
    //     return (time, number);
    // }

    
}