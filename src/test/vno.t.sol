// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/ds-test/src/test.sol";
import "../../lib/ds-test/src/console.sol";
// import "../../lib/ds-test/src/cheats.sol";
import "../vno.sol"; 

interface CheatCodes {
    // function prank(address) external;
    function addr(uint256 privateKey) external returns (address);
    function warp(uint256) external;    // Set block.timestamp
}

contract VNOTest is DSTest {
    VNO vno;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address alice = cheats.addr(1);
    address bob = cheats.addr(2);
    address candice = cheats.addr(3);
    address dominic = cheats.addr(4);

    function setUp() public {
        vno = new VNO();
    }
    
    // testAm for testAnotherMint
    // you need to have the word "test" to actually test
    // to test whether AnotherMint works
    
 
    function testMakeZero () public {
        string memory emptyset = "{}";
        assertTrue(vno.numExists(emptyset)==false);
        
        // assertTrue(vno.nestedSet_to_Num[emptyset]==0);
        // assertTrue(vno.getNumIdentity(emptyset)==0);
        
        // assertTrue(vno.getNumIdentity(emptyset) == 0);
        vno.makeZero();
        assertTrue(vno.numExists(emptyset)==true);
        assertTrue(keccak256(abi.encodePacked(vno.getNumIdentity(emptyset)))==keccak256(abi.encodePacked(emptyset)));
        assertTrue(keccak256(abi.encodePacked(vno.getNumPredecessor(emptyset)))==keccak256(abi.encodePacked(emptyset)));
    }
    
    function testMakeOne () public {
        string memory emptyset = "{}";
        string memory one = "{{}}";
        console.log("Number zero exists:", vno.numExists(emptyset));
        assertTrue(vno.numExists(emptyset)==false);
        vno.makeZero();
        console.log("Number zero exists:", vno.numExists(emptyset));
        assertTrue(vno.numExists(emptyset)==true);
        
        console.log("Number one exists:", vno.numExists(one));
        
        vno.makeSuccessor(vno.getNum(emptyset));
        
        // assertTrue(vno.numExists(vno.successorString(emptyset))==true);
        assertTrue(vno.numExists(one)==true);
        console.log("Number one exists:", vno.numExists(one));
        assertTrue(keccak256(abi.encodePacked(vno.successorString(emptyset)))==keccak256(abi.encodePacked(one)));

        console.log("The identity of the successor of zero is",vno.getNumIdentity(one));
        assertTrue(keccak256(abi.encodePacked(vno.getNumIdentity(one)))==keccak256(abi.encodePacked(one)));
        console.log("The identity of the predecessor of the successor of zero is",vno.getNumIdentity(one));
        assertTrue(keccak256(abi.encodePacked(vno.getNumPredecessor(one)))==keccak256(abi.encodePacked(emptyset)));
    }

//    function testAM() public {
//         uint256 num = 7;
//         uint256 tokenId_before_mint = vno.getCurrentTokenId();
//         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
//         vno.anotherMint(alice, num);
//         uint256 tokenId_after_mint = vno.getCurrentTokenId();
//         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
//         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
//         console.log("The owner of", tokenId_before_mint, "is", vno.ownerOf(tokenId_before_mint));
//         console.log("And the address of Alice is", alice);
//     }


//     // to test whether you get Minttime from AnotherMint 
//     function testAMGetMinttimeFromTokenId () public {
//         uint256 time = 1641070800;
//         cheats.warp(time);
//         uint256 num = 10;
//         uint256 tokenId_before_mint = vno.getCurrentTokenId();
//         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
//         vno.anotherMint(alice, num);
//         uint256 tokenId_after_mint = vno.getCurrentTokenId();
//         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
//         console.log("The token was minted at time", vno.getMinttimeFromTokenId(tokenId_before_mint));
//         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
//         assertTrue(vno.getMinttimeFromTokenId(tokenId_before_mint)==time);
        
//     }

//     // to test whether you can return the number from the tokenId

//     function testAMGetNumberFromTokenId() public {
//         uint256 num = 10;
//         uint256 tokenId_before_mint = vno.getCurrentTokenId();

//         vno.anotherMint(alice, num);
        
//         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
//         assertTrue(vno.getNumFromTokenId(tokenId_before_mint)==num);
        
//     }

//     // to test whether the time is recorded in the metadata of anotherMint

//     function testAMMintingSameNumAtDifferentTimes() public {
//         uint256 early = 1900000000;
//         uint256 later = 2000000000;
//         uint256 num = 10;
        
//         cheats.warp(early);
        
//         uint256 alice_tokenId = vno.getCurrentTokenId();
//         vno.anotherMint(alice, num);
//         console.log("The tokenId Alice minted is:", alice_tokenId, "at time:", vno.getMinttimeFromTokenId(alice_tokenId));
        
//         assertTrue(vno.getMinttimeFromTokenId(alice_tokenId)==early);

//         cheats.warp(later);

//         uint256 bob_tokenId = vno.getCurrentTokenId();
        
//         vno.anotherMint(bob, num);
//         console.log("The tokenId Bob minted is:", bob_tokenId, "at time:", vno.getMinttimeFromTokenId(bob_tokenId));
        
//         assertTrue(vno.ownerOf(alice_tokenId)==alice);
//         assertTrue(vno.getMinttimeFromTokenId(alice_tokenId) < vno.getMinttimeFromTokenId(bob_tokenId));
//         assertTrue(vno.getNumFromTokenId(alice_tokenId) == vno.getNumFromTokenId(bob_tokenId));
//     }

//     function testFirstMintsShouldHaveHigherOrdersThanLaterMints() public {
//         uint256 num = 7;
//         uint256 mint1  = 1;
//         uint256 mint2  = 2;
//         uint256 mint3  = 3;
        
//         cheats.warp(mint1);

//         uint256 alice_tokenId = vno.getCurrentTokenId();
//         vno.anotherMint(alice, num);
//         uint256 alice_mint_time = vno.getMinttimeFromTokenId(    alice_tokenId);
//         uint256 alice_token_num = vno.getNumFromTokenId(         alice_tokenId);
        
        
//         console.log("alice has minted:",                  alice_tokenId);
//         console.log("alice's token has number:",          alice_mint_time);
//         console.log("alice's token was minted at time:",  alice_token_num);

//         cheats.warp(mint2);

//         uint256 bob_tokenId = vno.getCurrentTokenId();
//         vno.anotherMint(bob, num);
//         uint256 bob_mint_time = vno.getMinttimeFromTokenId(      bob_tokenId);
//         uint256 bob_token_num = vno.getNumFromTokenId(           bob_tokenId);
//         console.log("bob has minted:",                   bob_tokenId); 
//         console.log("bob's token has number:",           bob_token_num); 
//         console.log("bob's token was minted at time:",   bob_mint_time);

//         cheats.warp(mint3);

//         uint256 candice_tokenId = vno.getCurrentTokenId();
//         vno.anotherMint(candice, num);
//         uint256 candice_mint_time = vno.getMinttimeFromTokenId(  candice_tokenId);
//         uint256 candice_token_num = vno.getNumFromTokenId(       candice_tokenId);
//         console.log("candice has minted:",                   candice_tokenId);
//         console.log("candice's token has number:",           candice_token_num);
//         console.log("candice's token was minted at time:",   candice_mint_time);

//         assertTrue(alice_token_num == num);
//         assertTrue(bob_token_num == num);
//         assertTrue(candice_token_num == num);
//         assertTrue(alice_token_num == bob_token_num && bob_token_num == candice_token_num);
//         assertTrue(alice_mint_time==mint1);
//         assertTrue(bob_mint_time==mint2);
//         assertTrue(candice_mint_time==mint3);
//         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);
//         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);

//         uint256 alice_order = vno.getOrderFromTokenId(alice_tokenId);
//         uint256 bob_order = vno.getOrderFromTokenId(bob_tokenId);
//         uint256 candice_order = vno.getOrderFromTokenId(candice_tokenId);

//         assertTrue(alice_order == 1);
//         assertTrue(bob_order == 2);
//         assertTrue(candice_order ==3);
//     }   

}