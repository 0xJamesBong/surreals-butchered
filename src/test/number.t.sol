// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/ds-test/src/test.sol";
import "../../lib/ds-test/src/console.sol";
import "../../lib/ds-test/src/cheats.sol";
import "../number.sol"; 

contract NumberTest is DSTest, CheatCodes {
    Number number;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address alice = cheats.addr(1);

    function setUp() public {
        number = new Number();
    }
    
    function testGetCurrentTokenID() public {
        assertTrue(number.getCurrentTokenId()==0);
    }

    // function testMint() public {
    //     number.safeMint(alice, number);
    //     assertTrue(number.ownerOf(number.))
    // }

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