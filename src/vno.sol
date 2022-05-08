// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "../lib/forge-std/lib/ds-test/src/console.sol";
import "../lib/forge-std/src/console.sol";

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
        return (compareNestedSet1 == compareNestedSet2);
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
        return (utfStringLength(nestedSet1) < utfStringLength(nestedSet2));    
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
        string memory predecessorString = ((keccak256(thisNestedSet) == keccak256(abi.encodePacked(emptyset))) ? emptyset : string(abi.encodePacked(substring(nestedSet, 1, utfStringLength(nestedSet)-1))));
        return predecessorString;
    }
    
    string emptyset = "{}";
    string one = "{{}}";
    string predecessorOfZero = "{}";

//////////////////////////////////////////////////////////////////////////////////////////
                                    // The VNO
//////////////////////////////////////////////////////////////////////////////////////////
    
    // Addition is defined as such:
    // for any numbers a,b
    // a + 0 = a, a + S(b) = S(a+b), S() being "successor of"
    // the definition is therefore recursive

    function addNestedSets (string memory nestedSet1, string memory nestedSet2) public returns (string memory addedNestedSet) {
        (bool isNestedString1,,) = isNestedString(nestedSet1);
        (bool isNestedString2,,) = isNestedString(nestedSet2);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
        bytes32 compareOne = keccak256(abi.encodePacked(one));
        uint256 nestedSet1Length = utfStringLength(nestedSet1);
        
        
        if (stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)) {
        
            // if either one is 0 
            if (stringsEq(nestedSet1, emptyset) == false) {
                return nestedSet1;
            } else if (stringsEq(nestedSet2, emptyset) == false) {
                return nestedSet2; 
            } else {
                return emptyset;
            }                
        } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
            if (stringsEq(nestedSet1, one) == false) {
                return successorString(nestedSet1);
            } else if ( stringsEq(nestedSet2, one) == false) {
                return successorString(nestedSet2);
            } else {
                return successorString(nestedSet1);
            }
        } else {
            string memory substring1 = substring(nestedSet1, 0, nestedSet1Length/2-1);
            string memory substring2 = substring(nestedSet1, nestedSet1Length/2, nestedSet1Length-1);
            
            // concatenating the three strings together, sandwiching the successor of nestedSet2 with the two substrings obtained from nestedSet1
            return predecessorString(string(abi.encodePacked(abi.encodePacked(substring1, successorString(nestedSet2)), substring2)));    
        }
    }
    // Subtraction is defined as such:
    // For any x, x-x =0, S(x)-n = S(x-n), S() being "successor of"
    // Note that we are careful not to produce negative numbers - this we do by require the subtrahend is a substring of the minuend
    // for the expression a - b, a = minuend, b = subtrahend
    function subtractNestedSets (string memory minuend, string memory subtrahend) public returns (string memory addedNestedSet) {
        (bool isNestedString1,,) = isNestedString(minuend);
        (bool isNestedString2,,) = isNestedString(subtrahend);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        require(isSubstring(subtrahend, minuend) == true || stringsEq(minuend, subtrahend), "the subtrahend is bigger than the minuend. You need to extend this number system to the integers to do that.");
        string memory result = ((stringsEq(minuend, subtrahend)) ? emptyset : successorString(subtractNestedSets(predecessorString(minuend), subtrahend)));
        return result;
    }

    // Multiplication is defined as such:
    // For any a, b, a * 0 = 0, a * S(b) = a * b + a

    function multiplyNestedSets (string memory nestedSet1, string memory nestedSet2) public returns (string memory addedNestedSet) {
        
        (bool isNestedString1,,) = isNestedString(nestedSet1);
        (bool isNestedString2,,) = isNestedString(nestedSet2);
        require(isNestedString1 == true, "nestedSet1 is not legal nested string");
        require(isNestedString2 == true, "nestedSet2 is not legal nested string");
        
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
        bytes32 compareOne = keccak256(abi.encodePacked(one));
        if (stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)) {
            return emptyset;
        } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
            
            string memory result = ((stringsEq(nestedSet1, one)) ? nestedSet2 : nestedSet1);
            return result;
        } else if (isSubstring(nestedSet1, nestedSet2) || stringsEq(nestedSet1, nestedSet2)) {
            return addNestedSets(multiplyNestedSets(nestedSet2, predecessorString(nestedSet1)), nestedSet2);
        } else {
            return addNestedSets(multiplyNestedSets(nestedSet1, predecessorString(nestedSet2)), nestedSet1);
        }
    }


    // Exponentiation is defined as such:
    // for any numbers a,b  
    // a ^ b = a * a ^ P(b), P() being "predecessor of"
    function exponentiateNestedSets (string memory base, string memory exponent) public returns (string memory addedNestedSet) {
        // revert if exponent is zero
        // Although a  ^ 0 == 1 is common knowledge; the proof implicitly assumes the existence of a multiplicative inverse of a, which we do not in this construction of the natural numbers
        // Therefore, exponentiation here is purely a computational shortcut
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


    struct Universal {
        string nestedString;
        uint256 number;
        uint256 instances;
        uint256[] allInstances; // entries are tokenIds
    }

    /*
    The Metadata Struct stores the metadata of each NFT 
    each tokenId has its own metadata struct
    */
    
    struct Metadata {
        Universal universal;
        // string nestedString;
        // uint256 number;
        uint256 mintTime;
        uint256 order;
    }

    mapping(uint256 => Metadata)  public tokenId_to_metadata;     // looks at the token's metadata 
    mapping(uint256 => Universal) public num_to_universal;             //
    mapping(string  => Universal) public nestedString_to_universal;    // looks at the object of the number
    // mapping(uint256 => address)   public universal_to_owner                  // owner of universal
    mapping(uint256 => uint256) public universal_to_tokenId; 
    mapping(uint256 => uint256) universal_to_tax; 
    

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
        return (tempNestedSet.length != 0);
        
        // if(tempNestedSet.length != 0) {
            // return true;
        // } 
        // return false;
    }

    
    function tokenMetadata(uint256 tokenId) public returns (Universal memory num, string memory nestedString, uint256 number, uint256 instances, uint256 mintTime, uint256 order) {
        // this function unwraps the token metadata 
        num = tokenId_to_metadata[tokenId].universal;

        nestedString = num.nestedString;
        number = num.number;
        instances = num.instances; 
        
        mintTime = tokenId_to_metadata[tokenId].mintTime;
        order = tokenId_to_metadata[tokenId].order;
        
        return (num, nestedString, number, instances, mintTime, order);
    }

    function getUniversalFromTokenId(uint256 tokenId) public view returns (Universal memory universal) {
        // uint256 num = tokenId_to_number[tokenId];
        universal = tokenId_to_metadata[tokenId].universal;
        return universal;
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

//////////////////////////////////////////////////////////////////////////////////////////
                            // Minting Functionality
//////////////////////////////////////////////////////////////////////////////////////////

    // mapping(address => uint256) public addressToEarnings;
    mapping(uint256 => uint256) public universalToBalance;
    address payable treasury;
    uint256 treasuryBalance;
    uint256 mathBretherenTax;
    

    function setTreasuryAddress(address newTreasuryAddress) public onlyOwner () {
        treasury = payable(newTreasuryAddress);
        return; 
    }
    
    function viewTreasuryBalances() public view returns (uint256 treasuryBalance) {
        return treasury.balance;
    }

    function viewUniversalBalance(uint256 num) public view returns (uint256 universalBalance){
        universalBalance = universalToBalance[num];
        return universalBalance;
    }


    function setTreasuryTax(uint256 bp) public onlyOwner () {
        // the Math Bretheren Tax applies to all Universal Owners
        // the treasury tax is set in terms of basis points 
        // The tax can range from 0 to 100*10000 = 1,000,000 (which amounts to 100%)
        require(bp >= 0, "negative taxes are not allowed!");
        require(bp <= 1000000, "negative taxes are not allowed!");
        mathBretherenTax = bp;
    }

    function withdrawTreasury(uint256 amount, address to) public {
        require(msg.sender == treasury, "you're not the treasury owner!");
        require(amount <= treasuryBalance, "you're withdrawing more than the treasury!");
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "the withdrawal didn't go through");
        if (success) {
            treasuryBalance = treasuryBalance - amount;
        }
    }

    function viewTreasuryTax() public view returns (uint256 treasuryTax) {
        return mathBretherenTax;
    }
    
    function viewTreasuryBalance() public view returns (uint256 treasuryBalance) {
        return treasuryBalance;
    }

    function payUniversalOwner(uint256 num) internal {
        uint256 tax = universal_to_tax[num];
        // uint256 oldBalance = addressToEarnings[ownerOf(universal_to_tokenId[num])];
        (bool success, ) = payable(address(this)).call{value: tax}("");
        require(success, "tax didn't go through");
        if (success) {
            // recall that universal taxes are set as whole numbers, not percentages
            universalToBalance[num] += tax*(1000000-mathBretherenTax)/1000000;
        }        
    }

    // Needs non-Reentrancy Guard 
    function withdrawUniversalOwnerBalance(uint256 num) public {
        address universalOwner = ownerOf(universal_to_tokenId[num]);
        require(msg.sender == universalOwner, "you don't own this Universal!");
        require(universalToBalance[num] > 0, "there's no money for you withdraw!");

        (bool success, ) = payable(universalOwner).call{value : universalToBalance[num]}(""); 
        require(success, "it didn't go through");  
        if (success) {
            universalToBalance[num] = 0;
        }
    }

    function setUniversalTax(uint256 num, uint256 amount) public {
        require(msg.sender == ownerOf(universal_to_tokenId[num]), "msg.sender is not the owner of the universal!");
        // note that universal taxes are set in absolute amounts, not basis points. 
        require(amount >= 0, "what are you thinking setting a negative tax?");
        universal_to_tax[num] = amount;
    }

    function makeZero(address maker) public returns (uint256 tokenId) {
        // checks if num is new, if new, increases its order to 1 (first!)
        // if not new, does nothing and goes straight next
        uint256 tokenId = _tokenIdCounter.current();
        if (!universalExists(0)) {
        // you can also use the following line to check if the number exists 
        // if ( nestedString_to_universal[emptyset].order == 0 ) {
            Universal storage x = num_to_universal[0];
            x.nestedString = emptyset;
            x.number = nestedStringToNum(emptyset);
            x.instances = 1;
            // nestedString_to_universal[emptyset].instances = 1;
            // uint256 order = nestedString_to_universal[emptyset].instances;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[tokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[0] = tokenId; 
        } else {
            uint256 instances = getInstances(0);    
            num_to_universal[0].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[tokenId] = Metadata(num_to_universal[0], mintTime, order);
        }
        _tokenIdCounter.increment();
        // 
        _safeMint(maker, tokenId);
        return tokenId;
    }


    function mintSuccessor(address maker, uint256 oldTokenId) public returns (uint256 newTokenId) {
        // checks if num is new, if new, increases its order to 1 (first!)
        // if not new, does nothing and goes straight next
        uint256 currentNum = tokenId_to_metadata[oldTokenId].universal.number;
        uint256 targetNum = currentNum + 1;

        require(universalExists(currentNum) == true, "the universal of the predecessor has not been made yet");
        require(ownerOf(oldTokenId) == maker, "you don't own the token you're making the successor of");
        
        uint256 newTokenId = _tokenIdCounter.current();
        
        string memory targetNumNestedString = successorString(tokenId_to_metadata[oldTokenId].universal.nestedString);

        if (!universalExists(targetNum)) {
        // you can also use the following line to check if the number exists 
        // if ( nestedString_to_universal[emptyset].order == 0 ) {
            Universal storage x = num_to_universal[targetNum];
            x.nestedString = targetNumNestedString;
            x.number = targetNum;
            x.instances = 1;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[targetNum] = newTokenId; 
        } else {
            uint256 instances = getInstances(targetNum);    
            num_to_universal[targetNum].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[targetNum], mintTime, order);
            // Minting a successor does not burn the token you're minting from
            // This makes equivalent to a direct mint
            
            // if (maker != ownerOf(universal_to_tokenId[targetNum])) {
                // payUniversalOwner(targetNum);
            // }
        }
        
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }

    // 
    function directMint(address maker, uint256 num) public returns (uint256 newTokenId) {

        require(universalExists(num) == true, "the universal of the predecessor has not been made yet");
        uint256 newTokenId = _tokenIdCounter.current();
        uint256 instances = getInstances(num);    
        num_to_universal[num].instances = instances + 1;    
        uint256 order = instances + 1; 
        uint256 mintTime = Time();
        tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[num], mintTime, order);
        
        if (maker != ownerOf(universal_to_tokenId[num])) {
            payUniversalOwner(num);
        }
        
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }

    function mintByAddition(address maker, uint256 oldTokenId1, uint256 oldTokenId2) public returns (uint256 newTokenId) {
        
        uint256 num1 = tokenId_to_metadata[oldTokenId1].universal.number;
        uint256 num2 = tokenId_to_metadata[oldTokenId2].universal.number;
        uint256 targetNum = num1 + num2;
        
        require(((universalExists(num1) == true) && (universalExists(num2) == true)), "the universals of the constituents don't exist has not been made yet");
        require(((ownerOf(oldTokenId1) == maker) && (ownerOf(oldTokenId2) == maker)), "you don't own the tokens you're adding");
        
        uint256 newTokenId = _tokenIdCounter.current();
        
        string memory targetNumNestedString = addNestedSets(tokenId_to_metadata[oldTokenId1].universal.nestedString, tokenId_to_metadata[oldTokenId2].universal.nestedString);

        if (!universalExists(targetNum)) {
        // you can also use the following line to check if the number exists 
        // if ( nestedString_to_universal[emptyset].order == 0 ) {
            Universal storage x = num_to_universal[targetNum];
            x.nestedString = targetNumNestedString;
            x.number = targetNum;
            x.instances = 1;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[targetNum] = newTokenId; 
        } else {
            uint256 instances = getInstances(targetNum);    
            num_to_universal[targetNum].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[targetNum], mintTime, order);
            
            // if the token used to make the successor is not a universal, we will burn it. 
            
            if (universal_to_tokenId[num1] != oldTokenId1 ) {
                _burn(oldTokenId1);
            }

            if (universal_to_tokenId[num2] != oldTokenId2 ) {
                _burn(oldTokenId2);
            }
            
        }
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }

    function mintByMultiplication(address maker, uint256 oldTokenId1, uint256 oldTokenId2) public returns (uint256 newTokenId) {
        
        
        uint256 num1 = tokenId_to_metadata[oldTokenId1].universal.number;
        uint256 num2 = tokenId_to_metadata[oldTokenId2].universal.number;
        uint256 targetNum = num1 + num2;
        
        require(((universalExists(num1) == true) && (universalExists(num2) == true)), "the universals of the constituents don't exist has not been made yet");
        require(((ownerOf(oldTokenId1) == maker) && (ownerOf(oldTokenId2) == maker)), "you don't own the tokens you're adding");
        
        uint256 newTokenId = _tokenIdCounter.current();
        
        string memory targetNumNestedString = multiplyNestedSets(tokenId_to_metadata[oldTokenId1].universal.nestedString, tokenId_to_metadata[oldTokenId2].universal.nestedString);

        if (!universalExists(targetNum)) {
            Universal storage x = num_to_universal[targetNum];
            x.nestedString = targetNumNestedString;
            x.number = targetNum;
            x.instances = 1;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[targetNum] = newTokenId; 
        } else {
            uint256 instances = getInstances(targetNum);    
            num_to_universal[targetNum].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[targetNum], mintTime, order);
            
            // if the token used to make the successor is not a universal, we will burn it. 
            
            if (universal_to_tokenId[num1] != oldTokenId1 ) {
                _burn(oldTokenId1);
            }

            if (universal_to_tokenId[num2] != oldTokenId2 ) {
                _burn(oldTokenId2);
            }
        }
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }

    function mintByExponentiation(address maker, uint256 oldTokenId1, uint256 oldTokenId2) public returns (uint256 newTokenId) {
        
        
        uint256 num1 = tokenId_to_metadata[oldTokenId1].universal.number;
        uint256 num2 = tokenId_to_metadata[oldTokenId2].universal.number;
        uint256 targetNum = num1 + num2;
        
        require(((universalExists(num1) == true) && (universalExists(num2) == true)), "the universals of the constituents don't exist has not been made yet");
        require(((ownerOf(oldTokenId1) == maker) && (ownerOf(oldTokenId2) == maker)), "you don't own the tokens you're adding");
        
        uint256 newTokenId = _tokenIdCounter.current();
        
        string memory targetNumNestedString = exponentiateNestedSets(tokenId_to_metadata[oldTokenId1].universal.nestedString, tokenId_to_metadata[oldTokenId2].universal.nestedString);

        if (!universalExists(targetNum)) {
            Universal storage x = num_to_universal[targetNum];
            x.nestedString = targetNumNestedString;
            x.number = targetNum;
            x.instances = 1;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[targetNum] = newTokenId; 
        } else {
            uint256 instances = getInstances(targetNum);    
            num_to_universal[targetNum].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[targetNum], mintTime, order);
            
            // if the token used to make the successor is not a universal, we will burn it. 
            
            if (universal_to_tokenId[num1] != oldTokenId1 ) {
                _burn(oldTokenId1);
            }

            if (universal_to_tokenId[num2] != oldTokenId2 ) {
                _burn(oldTokenId2);
            }
            
        }
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }
        
    function mintBySubtraction(address maker, uint256 oldTokenId1, uint256 oldTokenId2) public returns (uint256 newTokenId) {
        
        
        uint256 num1 = tokenId_to_metadata[oldTokenId1].universal.number;
        uint256 num2 = tokenId_to_metadata[oldTokenId2].universal.number;
        uint256 targetNum = num1 + num2;
        
        require(((universalExists(num1) == true) && (universalExists(num2) == true)), "the universals of the constituents don't exist has not been made yet");
        require(((ownerOf(oldTokenId1) == maker) && (ownerOf(oldTokenId2) == maker)), "you don't own the tokens you're adding");
        
        uint256 newTokenId = _tokenIdCounter.current();
        
        string memory targetNumNestedString = subtractNestedSets(tokenId_to_metadata[oldTokenId1].universal.nestedString, tokenId_to_metadata[oldTokenId2].universal.nestedString);

        if (!universalExists(targetNum)) {
            Universal storage x = num_to_universal[targetNum];
            x.nestedString = targetNumNestedString;
            x.number = targetNum;
            x.instances = 1;
            uint256 order = 1;
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(x, mintTime, order);
            universal_to_tokenId[targetNum] = newTokenId; 
        } else {
            uint256 instances = getInstances(targetNum);    
            num_to_universal[targetNum].instances = instances + 1;    
            uint256 order = instances + 1; 
            uint256 mintTime = Time();
            tokenId_to_metadata[newTokenId] = Metadata(num_to_universal[targetNum], mintTime, order);
            
            // if the token used to make the successor is not a universal, we will burn it. 
            
            if (universal_to_tokenId[num1] != oldTokenId1 ) {
                _burn(oldTokenId1);
            }

            if (universal_to_tokenId[num2] != oldTokenId2 ) {
                _burn(oldTokenId2);
            }
            
        }
        _tokenIdCounter.increment();
        
        _safeMint(maker, newTokenId);
        return newTokenId;
    }

}