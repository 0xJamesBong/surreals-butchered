// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract VNO is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Number", "Num") {}

    uint256 public createTime;
    
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
 

    // struct Zero {
    //     string identity;
    //     string predecessor;
    // }
    
    string emptyset = "{}";

    struct Num {
        string identity;
        string predecessor; 
    }
    
    mapping(string => Num) public nestedSet_to_Num;

    function makeZero() public returns (Num memory zero) {
        require(numExists(emptyset) == false);
        Num storage z = nestedSet_to_Num[emptyset];
        z.identity = emptyset;
        z.predecessor = emptyset;
        return z;
    }
    
    function successorString(string calldata nestedSet) public returns (string memory successor) {
        bytes memory predecessor = abi.encodePacked(nestedSet);
        string memory successorString = string(abi.encodePacked("{", predecessor, "}"));
        return successorString;

    }

    function makeSuccessor(Num calldata _predecessor) public returns (Num memory successor) {
        // require(numExists(emptyset) == true);
        // require(numExists(emptyset) == false);
        bytes memory _predecessorIdentity = abi.encodePacked(_predecessor.identity);
        string memory successorString = string(abi.encodePacked("{", _predecessorIdentity, "}"));
        // string memory successorString = successorString(_predecessor.identity);
        Num storage n = nestedSet_to_Num[successorString];
        n.identity = successorString;
        n.predecessor = _predecessor.identity;
        return n;
    }

    function numExists(string memory nestedSet) public view returns (bool) {
        // https://ethereum.stackexchange.com/questions/11039/how-can-you-check-if-a-string-is-empty-in-solidity
        bytes memory tempNestedSet = bytes(nestedSet_to_Num[nestedSet].identity); // Uses memory
        // check if non-zero value in struct is zero
        // if it is zero then you know that myMapping[key] doesn't yet exist
        if(tempNestedSet.length != 0) {
            return true;
        } 
        return false;
    }

    function getNum(string calldata nestedSet) public returns (Num memory num) {
        num = nestedSet_to_Num[nestedSet];
        return num;
    }

    function getNumIdentity(string calldata nestedSet) public view returns (string memory numIdentity) {
        numIdentity  = nestedSet_to_Num[nestedSet].identity;
        return numIdentity;
    }
 
    function getNumPredecessor(string calldata nestedSet) public view returns (string memory numPredecessor) {
        numPredecessor = nestedSet_to_Num[nestedSet].predecessor;
        return numPredecessor;
    }

    // function successorString(string calldata nestedSet) public returns (string memory successor) {

    // function addNestedSets (string calldata nestedSet1, string calldata nestedSet2) public returns (string calldata addedNestedSet) {
        // 2 = {{{}}}
        // 3 = {{{{}}}}
        // 5 = {{{{{{{}}}}}}}
    // }
    // 
    // function multiply(uint256 num1, uint256 num2) {}
    // 
    // function exponentiate(uint256 num1, uint256 num1) {}

    // Return argument type struct VNO.Num storage pointer is not implicitly 
    // convertible to expected type (type of first return variable) struct
    //  VNO.Num calldata.

    
    
    //  struct Person
    // {
    //     string name;
    //     uint age;
    // }

// function getSome() public returns (Person a)
//     {
//         Person storage p;
//         p.name = "kashish";
//         p.age =20;
//         return p;
//     }


//     struct IpfsHash {
//     bytes32 hash;
//     uint hashSize;
//   }

//   struct Member {
//     IpfsHash ipfsHash;
//   }

//   mapping(uint => Member) members;

//   function addMember(uint id, bytes32 hash, uint size) public returns(bool success) {
//     members[id].ipfsHash.hash = hash;
//     members[id].ipfsHash.hashSize = size;
//     return true;
//   }

//   function getMember(uint id) public constant returns(bytes32 hash, uint hashSize) {
//     return(members[id].ipfsHash.hash, members[id].ipfsHash.hashSize);
//   }

// Returning structs in new version in solidity
// https://ethereum.stackexchange.com/questions/29365/returning-structs-in-new-version-in-solidity

//  struct Person
//     {
//         string name;
//         uint age;
//     }

// function getSome() public returns (Person a)
//     {
//         Person storage p;
//         p.name = "kashish";
//         p.age =20;
//         return p;
//     }

// function wantSome() public returns (string,uint)
//     {
//         Person storage p2 =getSome();
//         return (p2.name,p2.age); // return multiple values like this
//     }

//     function makeNumber(address to, uint256 n) {
        
//     }

//     function makeSuccessor(address to uint256 tokenId) {
        
//     }


   
}