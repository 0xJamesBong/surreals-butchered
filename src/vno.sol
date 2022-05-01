// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../lib/ds-test/src/console.sol";

contract VNO is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Number", "Num") {}

 
    //////////////////////////////////////////////////////////////////////////////////////////
                                    // String Manipulations
    //////////////////////////////////////////////////////////////////////////////////////////

    function substring(string memory str, uint startIndex, uint endIndex) public returns (string memory substring) {
       bytes memory strBytes = bytes(str);
       bytes memory result = new bytes(endIndex-startIndex);
       for(uint i = startIndex; i < endIndex; i++) {
           result[i-startIndex] = strBytes[i];
       }
       return string(result);
    }
    
    // https://ethereum.stackexchange.com/questions/13862/is-it-possible-to-check-string-variables-length-inside-the-contract
    function utfStringLength(string memory str) public returns (uint length) {
        uint i=0;
        bytes memory string_rep = bytes(str);

        while (i<string_rep.length)
        {
            if (string_rep[i]>>7==0)
                i+=1;
            else if (string_rep[i]>>5==bytes1(uint8(0x6)))
                i+=2;
            else if (string_rep[i]>>4==bytes1(uint8(0xE)))
                i+=3;
            else if (string_rep[i]>>3==bytes1(uint8(0x1E)))
                i+=4;
            else
                //For safety
                i+=1;

            length++;
        }
    }
    
    function isNestedString (string memory where) public returns (bool, uint256 numL, uint256 numR) {
        // https://ethereum.stackexchange.com/questions/69307/find-word-in-string-solidity
        bytes memory whereBytes = bytes (where);
        bool legal = true;
        uint256 numL = 0;
        uint256 numR = 0;        
        for (uint i = 0; i <= whereBytes.length-1; i++) {
            bool flag = false;
            // recording the number of left and right brackets
            if (whereBytes[i]=="{") {
                numL += 1;
            } else if (whereBytes[i]=="}") {
                numR += 1;
            }
            if (whereBytes[i] != "{" && whereBytes[i] != "}")  {
                flag = true;
            } 
            // checking if a } is followed by a { 
            if (i+1 != whereBytes.length && whereBytes[i]=="}" && whereBytes[i+1]=="{") {
                flag = true;    
            }
            // if any one flag is raised, break loop
            if (flag) {
                legal = false;
                break;
            }
        }
        if (numL != numR ) {
            legal = false;
        }
        return (legal, numL, numR);
    }

    function stringsEq(string memory nestedSet1, string memory nestedSet2) public returns (bool) {
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        if (compareNestedSet1 == compareNestedSet2) {
            return true;
        } else {
            return false;
        }
    }

    function isSubstring(string memory nestedSet1, string memory nestedSet2) public returns (bool) {
        // Only determines if nestedSet 1 is a substring of nestedSet2 
        // I don't care about the other way around
        // proper substrings only
        // This function relies on the fact that we have already checked they're legal strings 
        // Which enables the iff that isSubstring(nestedSet1, nestedSet2) == true iff nestedSet1 < nestedSet2 as numbers.
        (bool isNestedString1,,) = isNestedString(nestedSet1);
        (bool isNestedString2,,) = isNestedString(nestedSet2);
        require(isNestedString1 == true, "nestedSet1 is not legal nested substring");
        require(isNestedString2 == true, "nestedSet2 is not legal nested substring");
        if (utfStringLength(nestedSet1) < utfStringLength(nestedSet2)) {
            return true;
        } else {
            return false;
        }
    }

    function successorString(string memory nestedSet) public returns (string memory successor) {
        (bool isNestedString,,) = isNestedString(nestedSet);
        require(isNestedString == true, "nestedSet is not legal nested string");
        bytes memory predecessor = abi.encodePacked(nestedSet);
        string memory successorString = string(abi.encodePacked("{", predecessor, "}"));
        return successorString;
    }

    function predecessorString(string memory nestedSet) public returns (string memory predecessor) {
        (bool isNestedString,,) = isNestedString(nestedSet);
        require(isNestedString == true, "nestedSet is not legal nested string");
        bytes memory thisNestedSet = abi.encodePacked(nestedSet);
        if (keccak256(thisNestedSet) == keccak256(abi.encodePacked(emptyset))) {
            return emptyset;
        } else {
            return string(abi.encodePacked(substring(nestedSet, 1, utfStringLength(nestedSet)-1)));
        }
    }
    

    // struct Zero {
    //     string identity;
    //     string predecessor;
    // }
    
    string emptyset = "{}";
    string one = "{{}}";
    string predecessorOfZero = "{}";

//////////////////////////////////////////////////////////////////////////////////////////
                                    // The VNO
//////////////////////////////////////////////////////////////////////////////////////////
    

    // modifier isNS (string memory where) {
    //     (bool isNestedString,,) = isNestedString(where);
    //     require(isNestedString == true);
    //     _;
    // }



    // addition and multiplication in vno are defined as such
    // for any numbers a,b
    // a + 0 = a, a + S(b) = S(a+b)
    // a * 0 = 0, a * S(b) = a * b + a
    // the definition is therefore recursive

    function addNestedSets (string memory nestedSet1, string memory nestedSet2) public returns (string memory addedNestedSet) {
        (bool isNestedString1,,) = isNestedString(nestedSet1);
        (bool isNestedString2,,) = isNestedString(nestedSet2);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        // string memory emptyset = "{}";
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
        bytes32 compareOne = keccak256(abi.encodePacked(one));
        uint256 nestedSet1Length = utfStringLength(nestedSet1);
        // uint256 nestedSet2Length = utfStringLength(nestedSet2);
        
        if (stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)) {
        // if (compareNestedSet1 == compareEmptySet || compareNestedSet2 == compareEmptySet) {
            // if either one is 0 
            if (stringsEq(nestedSet1, emptyset) == false) {
            // if (compareNestedSet1 != compareEmptySet) {
                return nestedSet1;
            } else if (stringsEq(nestedSet2, emptyset) == false) {
            // } else if (compareNestedSet2 != compareEmptySet) {
                return nestedSet2; 
            } else {
                return emptyset;
            }                

        } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
        // } else if (compareNestedSet1 == compareOne || compareNestedSet2 == compareOne) {
            // if either one is 1 
            if (stringsEq(nestedSet1, one) == false) {
            // if (compareNestedSet1 != compareOne) {
                return successorString(nestedSet1);
            } else if ( stringsEq(nestedSet2, one) == false) {
            // } else if ( compareNestedSet2 != compareOne) {
                return successorString(nestedSet2);
            } else {
                // both of them are 1, so the sum is just the successor of either, which is 2
                return successorString(nestedSet1);
            }
        } else {
            string memory substring1 = substring(nestedSet1, 0, nestedSet1Length/2-1);
            string memory substring2 = substring(nestedSet1, nestedSet1Length/2, nestedSet1Length-1);
            // concatenating the three strings together, sandwiching the successor of nestedSet2 with the two substrings obtained from nestedSet1
            return predecessorString(string(abi.encodePacked(abi.encodePacked(substring1, successorString(nestedSet2)), substring2)));    
        }
    }

    // a - a = 0, S(a) - b = S(a-b)
    // a - a = 0, a - b = S(P(a)) - b = S(P(a)-b)
    // subtraction for any x, x-x =0, s(x)-n = s(x-n)
    function subtractNestedSets (string memory minuend, string memory subtrahend) public returns (string memory addedNestedSet) {
        // a - b 
        // a = minuend, b = subtrahend
        (bool isNestedString1,,) = isNestedString(minuend);
        (bool isNestedString2,,) = isNestedString(subtrahend);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        require(isSubstring(subtrahend, minuend) == true || stringsEq(minuend, subtrahend), "the subtrahend is bigger than the minuend. You need to extend this number system to the integers to do that.");
        if (stringsEq(minuend, subtrahend)) {
            return emptyset; 
        } else {
            return successorString(subtractNestedSets(predecessorString(minuend), subtrahend));
        }
    }

    function multiplyNestedSets (string memory nestedSet1, string memory nestedSet2) public returns (string memory addedNestedSet) {
        
        (bool isNestedString1,,) = isNestedString(nestedSet1);
        (bool isNestedString2,,) = isNestedString(nestedSet2);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        // string memory emptyset = "{}";
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
        bytes32 compareOne = keccak256(abi.encodePacked(one));
        // uint256 nestedSet1Length = utfStringLength(nestedSet1);
        // uint256 nestedSet2Length = utfStringLength(nestedSet2);

        // a * 0 = 0, a * S(b) = a * b + a        
        // a * 0 = 0, a * b = a * P(b) + a = a * (b - 1) + a = a * b    
        // the shorter string is put inside the sandwich; because that's the object that will be iterated on

        // if (comepareNestedSet1 == compareNestedSet2 || isSubstring(nestedSet1, nestedSet2) == true) {
            // nestedSet1 <= nestedSet2
            // breaking nestedSet1 into two parts, which are then reorganised to sandwich nestedSet2
            // string memory substring1 = substring(nestedSet2, 0, nestedSet2Length/2-1);
            // string memory substring2 = substring(nestedSet2, nestedSet2Length/2, nestedSet2Length-1);
        // } else {
            // nestedSet2 < nestedSet1
            // breaking nestedSet2 into two parts, which are then reorganised to sandwich nestedSet1
            // string memory substring1 = substring(nestedSet1, 0, nestedSet1Length/2-1);
            // string memory substring2 = substring(nestedSet1, nestedSet1Length/2, nestedSet1Length-1);
        // }
        if (stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)) {
        // if (compareNestedSet1 == compareEmptySet || compareNestedSet2 == compareEmptySet) {
            return emptyset;
        } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
        // } else if (compareNestedSet1 == compareOne || compareNestedSet2 == compareOne) {
            if (stringsEq(nestedSet1, one)) {
                return nestedSet2;
            } else {
                return nestedSet1;
            }
        } else if (isSubstring(nestedSet1, nestedSet2) || stringsEq(nestedSet1, nestedSet2)) {
        // } else if (isSubstring(nestedSet1, nestedSet2) || compareNestedSet1 == compareNestedSet2) {
            return addNestedSets(multiplyNestedSets(nestedSet2, predecessorString(nestedSet1)), nestedSet2);
        } else {
            return addNestedSets(multiplyNestedSets(nestedSet1, predecessorString(nestedSet2)), nestedSet1);
        }

    }


// addition and multiplication in vno are defined as such
// for any numbers a,b
// a + 0 = a, a + S(b) = S(a+b)
// a * 0 = 0, a * S(b) = a * b + a
// the definition is therefore recursive
// 
    // function multiply(uint256 num1, uint256 num2) {}
    // 
    // function exponentiate(uint256 num1, uint256 num1) {}

    // Return argument type struct VNO.Num storage pointer is not implicitly 
    // convertible to expected type (type of first return variable) struct
    //  VNO.Num memory.

    // a ^ S(b) = a * a ^ b 
    // a ^ b = a * a ^ P(b)
    function exponentiateNestedSets (string memory base, string memory exponent) public returns (string memory addedNestedSet) {
        // revert if exponent is zero
        // although a  ^ 0 == 1 is common knowledge; the proof implicitly assumes the inverse of a, which we do not in this construction
        // therefore the exponentiation here is purely a computational shortcut
        require(!stringsEq(exponent, emptyset));
        // // revert if 0 ^ 0 
        // require( !stringsEq(base, emptyset) && !stringsEq(exponent, emptyset));
        (bool isNestedString1,,) = isNestedString(base);
        (bool isNestedString2,,) = isNestedString(exponent);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        if (stringsEq(base, emptyset)) {
            return emptyset;
        } else if (stringsEq(base, one)) {
            return one;
        } else if (stringsEq(exponent, one)) {
            return base;
        } else {
            return multiplyNestedSets(base, exponentiateNestedSets(base, predecessorString(exponent)));
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////
                        // The Object of the Number (metadata)
//////////////////////////////////////////////////////////////////////////////////////////


    // struct Num {
    //     string identity;
    //     string predecessor; 
    // }

    // uint256 public createTime;
    
    /* 
    we need two structs because one represents the Idea - the metaphysical object - of the number
    and the other represents the metadata of the token


    the order counts how many NFTs of the same number has been minted
    in a sense, if the struct universal is the Universal, the very idea of the Number,
    then the order is the number of instances - particulars - of the Universal instantiated

    a virgin number has order of 0 
    first mints of a number has order 0
    the order updates every time a number is minted
    */

    struct universal {
        string nestedString;
        uint256 number;
        uint256 instances;
    }


    /*
    The Metadata Struct stores the metadata of each NFT 
    each tokenId has its own metadata struct
    */
    
    struct Metadata {
        universal num;
        // string nestedString;
        // uint256 number;
        uint256 mintTime;
        uint256 order;
    }

    mapping(uint256 => Metadata)    public tokenId_to_metadata;     // looks at the token's metadata 
    mapping(uint256 => universal)        public num_to_universal;             //
    mapping(string  => universal)        public nestedString_to_universal;    // looks at the object of the number
    

    function nestedStringToNum(string memory nestedString) public returns (uint256 num) {
        uint256 x = utfStringLength(nestedString)/2-1;
        return x;
    }

    function getCurrentTokenId() public view returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        return tokenId;
    }

    function Time() public view returns (uint256 timeCreated) {
        timeCreated = block.timestamp;
        return timeCreated;
    }

    
    function universalExists(uint256 num) public view returns (bool) {
        //   checks if the metaphysical object of number exists
        //     // https://ethereum.stackexchange.com/questions/11039/how-can-you-check-if-a-string-is-empty-in-solidity
        bytes memory tempNestedSet = bytes(num_to_universal[num].nestedString); // Uses memory
        // check if non-zero value in struct is zero
        // if it is zero then you know that myMapping[key] doesn't yet exist
        if(tempNestedSet.length != 0) {
            return true;
        } 
        return false;
    }


    // function universalExists(string memory nestedSet) public view returns (bool) {
    //     //   checks if the metaphysical object of number exists
    //     //     // https://ethereum.stackexchange.com/questions/11039/how-can-you-check-if-a-string-is-empty-in-solidity
    //     bytes memory tempNestedSet = bytes(nestedString_to_universal[nestedSet].nestedString); // Uses memory
    //     // check if non-zero value in struct is zero
    //     // if it is zero then you know that myMapping[key] doesn't yet exist
    //     if(tempNestedSet.length != 0) {
    //         return true;
    //     } 
    //     return false;
    // }

    // get token metadata 
    
    function tokenMetadata(uint256 tokenId) public returns (universal memory num, string memory nestedString, uint256 number, uint256 instances, uint256 mintTime, uint256 order) {
        // this function unwraps the token metadata 
        num = tokenId_to_metadata[tokenId].num;

        nestedString = num.nestedString;
        number = num.number;
        instances = num.instances; 
        
        mintTime = tokenId_to_metadata[tokenId].mintTime;
        order = tokenId_to_metadata[tokenId].order;
        
        return (num, nestedString, number, instances, mintTime, order);
    }

    function getUniversalFromTokenId(uint256 tokenId) public view returns (universal memory num) {
        // uint256 num = tokenId_to_number[tokenId];
        num = tokenId_to_metadata[tokenId].num;
        return num;
    }  

    function getNestedStringFromTokenId(uint256 tokenId) public view returns (string memory nestedString) {
        nestedString = getUniversalFromTokenId(tokenId).nestedString;
        return nestedString;
    }

    function getNumberFromTokenId(uint256 tokenId) public view returns (uint256 number) {
        number = getUniversalFromTokenId(tokenId).number;
        return number;
    }

    function getInstancesFromTokenId(uint256 tokenId) public view returns (uint256 instances) {
        instances = getUniversalFromTokenId(tokenId).instances;
        return instances;
    }

    function getMinttimeFromTokenId(uint256 tokenId) public view returns (uint256 mintTime) {
        mintTime = tokenId_to_metadata[tokenId].mintTime;
        return mintTime;
    }

    function getInstances(uint256 num) public view returns (uint256 instances) {
    
        instances = num_to_universal[num].instances;
        return instances;
    }




    function makeZero(address to) public returns (uint256 tokenId) {
        // checks if num is new, if new, increases its order to 1 (first!)
        // if not new, does nothing and goes straight next
        uint256 tokenId = _tokenIdCounter.current();
        if (!universalExists(0)) {
        // you can also use the following line to check if the number exists 
        // if ( nestedString_to_universal[emptyset].order == 0 ) {
            universal storage x = num_to_universal[0];
            x.nestedString = emptyset;
            x.number = nestedStringToNum(emptyset);
            x.instances = 1;
            // nestedString_to_universal[emptyset].instances = 1;
            // uint256 order = nestedString_to_universal[emptyset].instances;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[tokenId] = Metadata(x, mintTime, order);
        } else {
            uint256 instances = getInstances(0);    
            num_to_universal[0].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[tokenId] = Metadata(num_to_universal[0], mintTime, order);
        }
        _tokenIdCounter.increment();
        // 
        _safeMint(to, tokenId);
        return tokenId;
    }
    // function makeZero(address to) public returns (uint256 tokenId) {
    //     // checks if num is new, if new, increases its order to 1 (first!)
    //     // if not new, does nothing and goes straight next
    //     if (!universalExists(emptyset)) {
    //     // you can also use the following line to check if the number exists 
    //     // if ( nestedString_to_universal[emptyset].order == 0 ) {
    //         nestedString_to_universal[emptyset].nestedString = emptyset;
    //         nestedString_to_universal[emptyset].number = nestedStringToNum(emptyset);
    //         // nestedString_to_universal[emptyset].instances = 1;
    //         // uint256 order = nestedString_to_universal[emptyset].instances;
    //     } else {
    //         // nestedString_to_universal[emptyset].instances = getInstances(emptyset) + 1;
    //         // uint256 order = getInstances(emptyset) + 1; 
    //     }
    //     uint256 instances = getInstances(emptyset);
    //     universal storage x = nestedString_to_universal[emptyset];
    //     nestedString_to_universal[emptyset].instances = instances + 1;
    //     uint256 order = instances + 1; 
    //     uint256 tokenId = _tokenIdCounter.current();
    //     uint256 mintTime = Time();

    //     tokenId_to_metadata[tokenId] = Metadata(x, mintTime, order);
    //     // num_to_universal[num].order+=1; 
    //     _tokenIdCounter.increment();
    //     // 
    //     _safeMint(to, tokenId);
    //     return tokenId;
    // }
    
    // function makeZero() public returns (Num memory zero) {
        // require(universalExists(emptyset) == false);
        // Num storage z = nestedSet_to_Num[emptyset];
        // z.identity = emptyset;
        // z.predecessor = emptyset;
        // return z;
    // }

    // function anotherMint(address to, uint256 num) public returns (uint256) {
        
    //     // checks if num is new, if new, increases its order to 1 (first!)
    //     // if not new, does nothing and goes straight next
    //     if ( num_to_universal[num].order == 0 ) {
    //         num_to_universal[num].number = num;
    //         num_to_universal[num].order = 1;
    //     }
        
    //     uint256 order = num_to_universal[num].order;
    //     uint256 tokenId = _tokenIdCounter.current();
    //     uint256 mintTime = Time();
    //     tokenId_to_metadata[tokenId] = Metadata(num, mintTime, order);
    //     num_to_universal[num].order+=1; 
    //     _tokenIdCounter.increment();
        
    //     _safeMint(to, tokenId);
    //     return tokenId;
    // }

    
    
    

    // function getNum(string memory nestedSet) public returns (Num memory num) {
    //     num = nestedSet_to_Num[nestedSet];
    //     return num;
    // }

    // function getNumIdentity(string memory nestedSet) public view returns (string memory numIdentity) {
    //     numIdentity  = nestedSet_to_Num[nestedSet].identity;
    //     return numIdentity;
    // }
 
    // function getNumPredecessor(string memory nestedSet) public view returns (string memory numPredecessor) {
    //     numPredecessor = nestedSet_to_Num[nestedSet].predecessor;
    //     return numPredecessor;
    // }

    // function makeSuccessor(Num memory _predecessor) public returns (Num memory successor) {
    //     // require(universalExists(emptyset) == true);
    //     // require(universalExists(emptyset) == false);
    //     bytes memory _predecessorIdentity = abi.encodePacked(_predecessor.identity);
    //     string memory successorString = string(abi.encodePacked("{", _predecessorIdentity, "}"));
    //     // string memory successorString = successorString(_predecessor.identity);
    //     Num storage n = nestedSet_to_Num[successorString];
    //     n.identity = successorString;
    //     n.predecessor = _predecessor.identity;
    //     return n;
    // }
    
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