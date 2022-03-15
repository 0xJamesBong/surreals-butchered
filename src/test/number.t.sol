// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/ds-test/src/test.sol";
import "../../lib/ds-test/src/console.sol";
// import "../../lib/ds-test/src/cheats.sol";
import "../number.sol"; 

interface CheatCodes {
    // function prank(address) external;
    function addr(uint256 privateKey) external returns (address);
    function warp(uint256) external;    // Set block.timestamp
}

contract NumberTest is DSTest {
    Number number;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address alice = cheats.addr(1);
    address bob = cheats.addr(2);
    address candice = cheats.addr(3);
    address dominic = cheats.addr(4);

    function setUp() public {
        number = new Number();
    }
    
    // testAm for testAnotherMint
    // you need to have the word "test" to actually test
    // to test whether AnotherMint works
    
    function testAM() public {
        uint256 num = 7;
        uint256 tokenId_before_mint = number.getCurrentTokenId();
        console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
        number.anotherMint(alice, num);
        uint256 tokenId_after_mint = number.getCurrentTokenId();
        console.log("The tokenId after Alice minting is:", tokenId_after_mint);
        assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        console.log("The owner of", tokenId_before_mint, "is", number.ownerOf(tokenId_before_mint));
        console.log("And the address of Alice is", alice);
    }

    
    // to test whether you get Minttime from AnotherMint 
    function testAMGetMinttimeFromTokenId () public {
        uint256 time = 1641070800;
        cheats.warp(time);
        uint256 num = 10;
        uint256 tokenId_before_mint = number.getCurrentTokenId();
        console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
        number.anotherMint(alice, num);
        uint256 tokenId_after_mint = number.getCurrentTokenId();
        console.log("The tokenId after Alice minting is:", tokenId_after_mint);
        console.log("The token was minted at time", number.getMinttimeFromTokenId(tokenId_before_mint));
        assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        assertTrue(number.getMinttimeFromTokenId(tokenId_before_mint)==time);
        
    }

    // to test whether you can return the number from the tokenId

    function testAMGetNumberFromTokenId() public {
        uint256 num = 10;
        uint256 tokenId_before_mint = number.getCurrentTokenId();

        number.anotherMint(alice, num);
        
        assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        assertTrue(number.getNumFromTokenId(tokenId_before_mint)==num);
        
    }

    // to test whether the time is recorded in the metadata of anotherMint

    function testAMMintingSameNumAtDifferentTimes() public {
        uint256 early = 1900000000;
        uint256 later = 2000000000;
        uint256 num = 10;
        
        cheats.warp(early);
        
        uint256 alice_tokenId = number.getCurrentTokenId();
        number.anotherMint(alice, num);
        console.log("The tokenId Alice minted is:", alice_tokenId, "at time:", number.getMinttimeFromTokenId(alice_tokenId));
        
        assertTrue(number.getMinttimeFromTokenId(alice_tokenId)==early);

        cheats.warp(later);

        uint256 bob_tokenId = number.getCurrentTokenId();
        
        number.anotherMint(bob, num);
        console.log("The tokenId Bob minted is:", bob_tokenId, "at time:", number.getMinttimeFromTokenId(bob_tokenId));
        
        assertTrue(number.ownerOf(alice_tokenId)==alice);
        assertTrue(number.getMinttimeFromTokenId(alice_tokenId) < number.getMinttimeFromTokenId(bob_tokenId));
        assertTrue(number.getNumFromTokenId(alice_tokenId) == number.getNumFromTokenId(bob_tokenId));
    }

    function testFirstMintsShouldHaveHigherOrdersThanLaterMints() public {
        uint256 num = 7;
        uint256 mint1  = 1;
        uint256 mint2  = 2;
        uint256 mint3  = 3;
        
        cheats.warp(mint1);

        uint256 alice_tokenId = number.getCurrentTokenId();
        number.anotherMint(alice, num);
        uint256 alice_mint_time = number.getMinttimeFromTokenId(    alice_tokenId);
        uint256 alice_token_num = number.getNumFromTokenId(         alice_tokenId);
        
        
        console.log("alice has minted:",                  alice_tokenId);
        console.log("alice's token has number:",          alice_mint_time);
        console.log("alice's token was minted at time:",  alice_token_num);

        cheats.warp(mint2);

        uint256 bob_tokenId = number.getCurrentTokenId();
        number.anotherMint(bob, num);
        uint256 bob_mint_time = number.getMinttimeFromTokenId(      bob_tokenId);
        uint256 bob_token_num = number.getNumFromTokenId(           bob_tokenId);
        console.log("bob has minted:",                   bob_tokenId); 
        console.log("bob's token has number:",           bob_token_num); 
        console.log("bob's token was minted at time:",   bob_mint_time);

        cheats.warp(mint3);

        uint256 candice_tokenId = number.getCurrentTokenId();
        number.anotherMint(candice, num);
        uint256 candice_mint_time = number.getMinttimeFromTokenId(  candice_tokenId);
        uint256 candice_token_num = number.getNumFromTokenId(       candice_tokenId);
        console.log("candice has minted:",                   candice_tokenId);
        console.log("candice's token has number:",           candice_token_num);
        console.log("candice's token was minted at time:",   candice_mint_time);

        assertTrue(alice_token_num == num);
        assertTrue(bob_token_num == num);
        assertTrue(candice_token_num == num);
        assertTrue(alice_token_num == bob_token_num && bob_token_num == candice_token_num);
        assertTrue(alice_mint_time==mint1);
        assertTrue(bob_mint_time==mint2);
        assertTrue(candice_mint_time==mint3);
        assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);
        assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);

        uint256 alice_order = number.getOrderFromTokenId(alice_tokenId);
        uint256 bob_order = number.getOrderFromTokenId(bob_tokenId);
        uint256 candice_order = number.getOrderFromTokenId(candice_tokenId);

        assertTrue(alice_order == 1);
        assertTrue(bob_order == 2);
        assertTrue(candice_order ==3);
    }   

}