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

    function setUp() public {
        number = new Number();
    }
    
    function testGetCurrentTokenID() public {
        assertTrue(number.getCurrentTokenId()==0);
        console.log("The current tokenId is:", number.getCurrentTokenId());
    }

    function testMint() public {
        uint256 num = 7;
        uint256 tokenId_before_mint = number.getCurrentTokenId();
        console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
        number.safeMint(alice, num);
        uint256 tokenId_after_mint = number.getCurrentTokenId();
        console.log("The tokenId after Alice minting is:", tokenId_after_mint);
        assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        console.log("The owner of", tokenId_before_mint, "is", number.ownerOf(tokenId_before_mint));
        console.log("And the address of Alice is", alice);
    }

    function testGetNumFromTokenId() public {
        uint256 num = 7;
        uint256 tokenId = number.safeMint(bob, num);
        console.log("The tokenId minted by bob is", tokenId);
        uint256 num_returned = number.getNumFromTokenId(tokenId);
        assertTrue(num == num_returned);
    }

    function testGetMinttimeFromTokenId() public {
        uint256 time = 1641070800;
        cheats.warp(time);
        uint256 num = 10;
        uint256 tokenId_before_mint = number.getCurrentTokenId();
        // console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
        number.safeMint(alice, num);
        // uint256 tokenId_after_mint = number.getCurrentTokenId();
        // console.log("The tokenId after Alice minting is:", tokenId_after_mint);
        console.log("The token was minted at time", number.getMinttimeFromTokenId(tokenId_before_mint));
        // assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        assertTrue(number.getMinttimeFromTokenId(tokenId_before_mint)==time);
    }

    function testMintingSameNumAtDifferentTimes() public {
        uint256 early = 1900000000;
        uint256 later = 2000000000;
        uint256 num = 10;
        
        cheats.warp(early);
        
        uint256 alice_tokenId = number.getCurrentTokenId();
        number.safeMint(alice, num);
        console.log("The tokenId Alice minted is:", alice_tokenId, "at time:", number.getMinttimeFromTokenId(alice_tokenId));
        
        assertTrue(number.getMinttimeFromTokenId(alice_tokenId)==early);

        cheats.warp(later);

        uint256 bob_tokenId = number.getCurrentTokenId();
        
        number.safeMint(bob, num);
        console.log("The tokenId Bob minted is:", bob_tokenId, "at time:", number.getMinttimeFromTokenId(bob_tokenId));
        
        
        // assertTrue(number.ownerOf(tokenId_before_mint)==alice);
        assertTrue(number.getMinttimeFromTokenId(alice_tokenId) < number.getMinttimeFromTokenId(bob_tokenId));
        assertTrue(number.getNumFromTokenId(alice_tokenId) == number.getNumFromTokenId(bob_tokenId));
    }


    // Function to increment count by 1
    // function testInc() public {
    //     counter.inc();
    //     console.log("we are increasing");
    //     assertTrue(counter.get() == 1);
    // }

    // // Function to decrement count by 1
    // function dec() public {
    //     count -= 1;
    // }
}