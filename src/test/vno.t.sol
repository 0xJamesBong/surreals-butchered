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
    
    struct Universal {
        string nestedString;
        uint256 number;
        uint256 instances;
    }

    string emptyset = "{}";
    string e = "{}";
    string i = "{{}}";
    string ii = "{{{}}}";
    string iii = "{{{{}}}}";
    string v  = "{{{{{{}}}}}}";
    string vi  = "{{{{{{{}}}}}}}";
    
    

    // function testutfStringLength() public {
    //     string memory two   = "{{{}}}";
    //     string memory three = "{{{{}}}}";
    //     string memory five  = "{{{{{{{}}}}}}}";
    //     assertEq(vno.utfStringLength(two),6);
    //     assertEq(vno.utfStringLength(three),8);
    //     assertEq(vno.utfStringLength(five),14);
    // }

    // function testPredecessorString() public {
    //     string memory predE = vno.predecessorString(e);
    //     string memory predi = vno.predecessorString(i);
    //     string memory predii = vno.predecessorString(ii);
    //     console.log("The predecessor of zero should be", e, predE   );
    //     console.log("The predecessor of one  should be", e,  predi  );
    //     console.log("The predecessor of two  should be", i,  predii  );
    //     assertTrue(keccak256(abi.encodePacked(e))==keccak256(abi.encodePacked(predE)));
    //     // assertTrue(keccak256(abi.encodePacked(e))==keccak256(abi.encodePacked(predi)));
    //     assertTrue(keccak256(abi.encodePacked(i))==keccak256(abi.encodePacked(predii)));
    // }
    
    // function testIsNestedString() public {
    //     string memory five                   = "{{{{{{}}}}}}";
    //     string memory otherGlyphs        = "{1a44}";
    //     string memory misordered     = "}{}}";
    //     string memory notequalbrackets     = "{}}";
    //     string memory asymmetricNestedString = "{{{{{}}}";
    //     // 
    //     // (bool isFive                     , uint256 numLfive,                    uint256 numRfive)   = vno.isNestedString(five                  );
    //     (bool isOtherGlyphs             , uint256 numLOtherGlyphs,              uint256 numROtherGlyphs)                = vno.isNestedString(otherGlyphs                  );
    //     (bool isMisordered              , uint256 numLmisordered,               uint256 numRmisordered)                 = vno.isNestedString(misordered       );
    //     (bool isnotequalbrackets        , uint256 numLnotequalbrackets,         uint256 numRnotequalbrackets)           = vno.isNestedString(notequalbrackets    );
    //     (bool isAsymmetricNestedString  , uint256 numLAsymmetricNestedString,   uint256 numRAsymmetricNestedString)     = vno.isNestedString(asymmetricNestedString);

    //     // console.log(isFive, numLfive, numRfive);
    //     console.log(isOtherGlyphs,              numLOtherGlyphs,            numROtherGlyphs);
    //     console.log(isMisordered,               numLmisordered,             numRmisordered     );
    //     console.log(isnotequalbrackets,         numLnotequalbrackets,       numRnotequalbrackets);
    //     console.log(isAsymmetricNestedString,   numLAsymmetricNestedString, numRAsymmetricNestedString );

    //     // assertTrue(isFive                     == true  );
    //     assertTrue(isOtherGlyphs            == false );
    //     assertTrue(isMisordered             == false );
    //     assertTrue(isnotequalbrackets       == false );
    //     assertTrue(isAsymmetricNestedString == false );

    // }

    // function testAddNestedSets () public {
    //     string memory emptyset = "{}";
    //     string memory one = "{{}}";
    //     string memory two = "{{{}}}";
    //     string memory three = "{{{{}}}}";
    //     string memory five  = "{{{{{{}}}}}}";
    //     // 2 = {{{}}}
    //     // 3 = {{{{}}}}
    //     // 5 = {{{{{{{}}}}}}}

    //     string memory ee = vno.addNestedSets(emptyset, emptyset);
    //     console.log("The string of ee is", ee);
    //     string memory eo = vno.addNestedSets(emptyset, one);
    //     string memory oe = vno.addNestedSets(one, emptyset);
    //     string memory oo = vno.addNestedSets(one, one);
    //     string memory twothree = vno.addNestedSets(two, three);
        
    //     console.log("The string of oo is", oo);
    //     assertTrue(keccak256(abi.encodePacked(ee))==keccak256(abi.encodePacked(emptyset)));
    //     assertTrue(keccak256(abi.encodePacked(eo))==keccak256(abi.encodePacked(one)));
    //     assertTrue(keccak256(abi.encodePacked(oe))==keccak256(abi.encodePacked(one)));
    //     assertTrue(keccak256(abi.encodePacked(oo))==keccak256(abi.encodePacked(two)));
    //     console.log("The string of twothree is", twothree);
    //     console.log("The string of five is", five);
    //     assertTrue(keccak256(abi.encodePacked(five))==keccak256(abi.encodePacked(twothree)));
    // }

    // function testMultiplyNestedSets () public {

    //     string memory exi       = vno.multiplyNestedSets(e, i);           // zero multiplied with anything should be 0 should be 0 
    //     string memory ixi       = vno.multiplyNestedSets(i, i);       // anything multiplied by 1 should be itself.
    //     string memory iixi      = vno.multiplyNestedSets(ii, i);       // anything multiplied by 1 should be itself.
    //     string memory iiixe     = vno.multiplyNestedSets(iii, e);       // multiplication by 1 should return self, commutativity test
    //     string memory exiii     = vno.multiplyNestedSets(e, iii);       // multiplication by 1 should return self, commutativity test
    //     string memory iixiii    = vno.multiplyNestedSets(ii, iii);     //  commutativity test
    //     string memory iiixii    = vno.multiplyNestedSets(iii, ii);      //  commutativity test 

    //     console.log("exi    should be", e,  exi   );
    //     console.log("ixi    should be", i,  ixi   );
    //     console.log("iixi   should be", ii, iixi  );
    //     console.log("iiixe  should be", e,  iiixe );
    //     console.log("exiii  should be", e,  exiii );
    //     console.log("iixiii should be", vi, iixiii);
    //     console.log("iiixii should be", iixiii, iiixii);

    //     assertTrue(keccak256(abi.encodePacked(exi   )) == keccak256(abi.encodePacked(e)));
    //     assertTrue(keccak256(abi.encodePacked(ixi )) == keccak256(abi.encodePacked(i)));
    //     assertTrue(keccak256(abi.encodePacked(iixi )) == keccak256(abi.encodePacked(ii)));
    //     assertTrue(keccak256(abi.encodePacked(iiixe )) == keccak256(abi.encodePacked(e)));
    //     assertTrue(keccak256(abi.encodePacked(exiii )) == keccak256(abi.encodePacked(e)));
    //     assertTrue(keccak256(abi.encodePacked(iixiii)) == keccak256(abi.encodePacked(vi))); 
    //     assertTrue(keccak256(abi.encodePacked(iiixii)) == keccak256(abi.encodePacked(iiixii)));

    // }

    // function testSubtractNestedSets () public {
    //     string memory v = vno.addNestedSets(iii, ii);
    //     string memory imi       = vno.subtractNestedSets(i, i);       // anything multiplied by 1 should be itself.
    //     string memory iimi      = vno.subtractNestedSets(ii, i);       // anything multiplied by 1 should be itself.
    //     string memory iiime     = vno.subtractNestedSets(iii, e);       // multiplication by 1 should return self, commutativity test
    //     string memory vmiii     = vno.subtractNestedSets(v, iii);       // multiplication by 1 should return self, commutativity test

    //     console.log("v should be", "{{{{{{}}}}}}", v);
    //     console.log("imi    should be", e   ,   imi  );
    //     console.log("iimi   should be", i   ,   iimi );
    //     console.log("iiime  should be", iii ,   iiime);
    //     console.log("vmiii  should be", ii  ,   vmiii);        
        
    //     assertTrue(keccak256(abi.encodePacked("{{{{{{}}}}}}"   ))   == keccak256(abi.encodePacked(v)));
    //     assertTrue(keccak256(abi.encodePacked(e    ))   == keccak256(abi.encodePacked(imi  )));
    //     assertTrue(keccak256(abi.encodePacked(i  ))     == keccak256(abi.encodePacked(iimi )));
    //     assertTrue(keccak256(abi.encodePacked(iii ))    == keccak256(abi.encodePacked(iiime)));
    //     assertTrue(keccak256(abi.encodePacked(ii  ))    == keccak256(abi.encodePacked(vmiii)));
    // }

    // // this is not written yet
    // function testExponentiateNestedSets () public {
        
    //     string memory iEiii                   = vno.exponentiateNestedSets(i, iii);         // one to the power of three is one
    //     string memory iiEi                    = vno.exponentiateNestedSets(ii, i);        // two the power of one is one
    //     string memory vEiii                   = vno.exponentiateNestedSets(v, iii);       // five to the power of three is 125
    //     string memory oneHundredAndTwentyFive = vno.multiplyNestedSets(vno.multiplyNestedSets(v, v), v);
    //     // string memory iiime     = vno.exponentiateNestedSets(iii, e);       // iiii expect revert

    //     console.log("iEiii                   should be", i      ,   iEiii);
    //     console.log("iiEi                    should be", ii     ,   iiEi);
    //     console.log("vEiii                   should be", vEiii  ,   oneHundredAndTwentyFive);
    //     // console.log("oneHundredAndTwentyFive should be", iii ,   iiime);
        
    //     assertTrue(keccak256(abi.encodePacked(i   ))   == keccak256(abi.encodePacked(iEiii)));
    //     assertTrue(keccak256(abi.encodePacked(ii    ))   == keccak256(abi.encodePacked(iiEi  )));
    //     assertTrue(keccak256(abi.encodePacked(vEiii  ))     == keccak256(abi.encodePacked(oneHundredAndTwentyFive )));

    // }
 
    function testMakeZero() public {
        uint256 early = 1900000000;
        uint256 later = 2000000000;
        
        cheats.warp(early);
        uint256 tokenId_before_mint = vno.getCurrentTokenId();
        console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);

        assertTrue(!vno.universalExists(0));
        vno.makeZero(alice);

        assertTrue(vno.universalExists(0));
     

        // console.log("The tokenId after Alice minting is:", vno.getCurrentTokenId());
        assertTrue(vno.ownerOf(tokenId_before_mint) == alice);
        
        string memory aliceNestedString = vno.getUniversalFromTokenId(tokenId_before_mint).nestedString;
        uint256 aliceNumber = vno.getUniversalFromTokenId(tokenId_before_mint).number;
        uint256 aliceInstances = vno.getUniversalFromTokenId(tokenId_before_mint).instances;
        (, uint256 aliceMintTime, uint256 aliceOrder) = vno.tokenId_to_metadata(tokenId_before_mint);
        

        
        assertTrue(keccak256(abi.encodePacked(aliceNestedString))==keccak256(abi.encodePacked(emptyset)));
        assertEq(aliceNumber, 0);
        assertEq(aliceInstances, 1);
        assertEq(aliceMintTime, early);
        assertEq(aliceOrder, 1);
        
        cheats.warp(later);   
        console.log("The time now is",block.timestamp);
        console.log("The owner of", tokenId_before_mint, "is", vno.ownerOf(tokenId_before_mint));
        console.log("And the address of Alice is", alice);
        console.log("The number minted is", aliceNumber);
        console.log("of which there are instances:", aliceInstances);
        console.log("it was minted at mint time:", aliceMintTime);
        console.log("the order was:", aliceOrder);
        console.log("The nested string of the token Alice owned is", aliceNestedString);

        console.log(vno.universalExists(0));
        
        uint256 bobTokenId = vno.getCurrentTokenId();
        
        vno.makeZero(bob);
        
        string memory bobNestedString = vno.getUniversalFromTokenId(bobTokenId).nestedString;
        uint256 bobNumber = vno.getUniversalFromTokenId(bobTokenId).number;
        uint256 bobInstance = vno.getUniversalFromTokenId(bobTokenId).instances;
        (, uint256 bobMintTime, uint256 bobOrder) = vno.tokenId_to_metadata(bobTokenId);

        assertTrue(keccak256(abi.encodePacked(bobNestedString))==keccak256(abi.encodePacked(emptyset)));
        assertEq(bobNumber, 0);
        assertEq(bobInstance, 2);
        assertEq(bobMintTime, later);
        assertEq(bobOrder, 2);

        console.log("The time now is",block.timestamp);
        console.log("The owner of", bobTokenId, "is", vno.ownerOf(bobTokenId));
        console.log("And the address of Bob is", bob);
        console.log("The number minted is", bobNumber);
        console.log("of which there are instances:", bobInstance);
        console.log("it was minted at mint time:", bobMintTime);
        console.log("the order was:", bobOrder);
        console.log("The nested string of the token Bob owned is", bobNestedString);
    }


    
    // function testMakeOne () public {
    //     string memory emptyset = "{}";
    //     string memory one = "{{}}";
    //     console.log("Number zero exists:", vno.universalExists(emptyset));
    //     assertTrue(vno.universalExists(emptyset)==false);
    //     vno.makeZero();
    //     console.log("Number zero exists:", vno.universalExists(emptyset));
    //     assertTrue(vno.universalExists(emptyset)==true);
        
    //     console.log("Number one exists:", vno.universalExists(one));
        
    //     vno.makeSuccessor(vno.getNum(emptyset));
        
    //     // assertTrue(vno.universalExists(vno.successorString(emptyset))==true);
    //     assertTrue(vno.universalExists(one)==true);
    //     console.log("Number one exists:", vno.universalExists(one));
    //     assertTrue(keccak256(abi.encodePacked(vno.successorString(emptyset)))==keccak256(abi.encodePacked(one)));

    //     console.log("The identity of the successor of zero is",vno.getNumIdentity(one));
    //     assertTrue(keccak256(abi.encodePacked(vno.getNumIdentity(one)))==keccak256(abi.encodePacked(one)));
    //     console.log("The identity of the predecessor of the successor of zero is",vno.getNumIdentity(one));
    //     assertTrue(keccak256(abi.encodePacked(vno.getNumPredecessor(one)))==keccak256(abi.encodePacked(emptyset)));
    // }

// //    function testAM() public {
// //         uint256 num = 7;
// //         uint256 tokenId_before_mint = vno.getCurrentTokenId();
// //         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
// //         vno.anotherMint(alice, num);
// //         uint256 tokenId_after_mint = vno.getCurrentTokenId();
// //         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
// //         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
// //         console.log("The owner of", tokenId_before_mint, "is", vno.ownerOf(tokenId_before_mint));
// //         console.log("And the address of Alice is", alice);
// //     }


// //     // to test whether you get Minttime from AnotherMint 
// //     function testAMGetMinttimeFromTokenId () public {
// //         uint256 time = 1641070800;
// //         cheats.warp(time);
// //         uint256 num = 10;
// //         uint256 tokenId_before_mint = vno.getCurrentTokenId();
// //         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
// //         vno.anotherMint(alice, num);
// //         uint256 tokenId_after_mint = vno.getCurrentTokenId();
// //         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
// //         console.log("The token was minted at time", vno.getMinttimeFromTokenId(tokenId_before_mint));
// //         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
// //         assertTrue(vno.getMinttimeFromTokenId(tokenId_before_mint)==time);
        
// //     }

// //     // to test whether you can return the number from the tokenId

// //     function testAMGetNumberFromTokenId() public {
// //         uint256 num = 10;
// //         uint256 tokenId_before_mint = vno.getCurrentTokenId();

// //         vno.anotherMint(alice, num);
        
// //         assertTrue(vno.ownerOf(tokenId_before_mint)==alice);
// //         assertTrue(vno.getNumFromTokenId(tokenId_before_mint)==num);
        
// //     }

// //     // to test whether the time is recorded in the metadata of anotherMint

// //     function testAMMintingSameNumAtDifferentTimes() public {
// //         uint256 early = 1900000000;
// //         uint256 later = 2000000000;
// //         uint256 num = 10;
        
// //         cheats.warp(early);
        
// //         uint256 alice_tokenId = vno.getCurrentTokenId();
// //         vno.anotherMint(alice, num);
// //         console.log("The tokenId Alice minted is:", alice_tokenId, "at time:", vno.getMinttimeFromTokenId(alice_tokenId));
        
// //         assertTrue(vno.getMinttimeFromTokenId(alice_tokenId)==early);

// //         cheats.warp(later);

// //         uint256 bob_tokenId = vno.getCurrentTokenId();
        
// //         vno.anotherMint(bob, num);
// //         console.log("The tokenId Bob minted is:", bob_tokenId, "at time:", vno.getMinttimeFromTokenId(bob_tokenId));
        
// //         assertTrue(vno.ownerOf(alice_tokenId)==alice);
// //         assertTrue(vno.getMinttimeFromTokenId(alice_tokenId) < vno.getMinttimeFromTokenId(bob_tokenId));
// //         assertTrue(vno.getNumFromTokenId(alice_tokenId) == vno.getNumFromTokenId(bob_tokenId));
// //     }

// //     function testFirstMintsShouldHaveHigherOrdersThanLaterMints() public {
// //         uint256 num = 7;
// //         uint256 mint1  = 1;
// //         uint256 mint2  = 2;
// //         uint256 mint3  = 3;
        
// //         cheats.warp(mint1);

// //         uint256 alice_tokenId = vno.getCurrentTokenId();
// //         vno.anotherMint(alice, num);
// //         uint256 alice_mint_time = vno.getMinttimeFromTokenId(    alice_tokenId);
// //         uint256 alice_token_num = vno.getNumFromTokenId(         alice_tokenId);
        
        
// //         console.log("alice has minted:",                  alice_tokenId);
// //         console.log("alice's token has number:",          alice_mint_time);
// //         console.log("alice's token was minted at time:",  alice_token_num);

// //         cheats.warp(mint2);

// //         uint256 bob_tokenId = vno.getCurrentTokenId();
// //         vno.anotherMint(bob, num);
// //         uint256 bob_mint_time = vno.getMinttimeFromTokenId(      bob_tokenId);
// //         uint256 bob_token_num = vno.getNumFromTokenId(           bob_tokenId);
// //         console.log("bob has minted:",                   bob_tokenId); 
// //         console.log("bob's token has number:",           bob_token_num); 
// //         console.log("bob's token was minted at time:",   bob_mint_time);

// //         cheats.warp(mint3);

// //         uint256 candice_tokenId = vno.getCurrentTokenId();
// //         vno.anotherMint(candice, num);
// //         uint256 candice_mint_time = vno.getMinttimeFromTokenId(  candice_tokenId);
// //         uint256 candice_token_num = vno.getNumFromTokenId(       candice_tokenId);
// //         console.log("candice has minted:",                   candice_tokenId);
// //         console.log("candice's token has number:",           candice_token_num);
// //         console.log("candice's token was minted at time:",   candice_mint_time);

// //         assertTrue(alice_token_num == num);
// //         assertTrue(bob_token_num == num);
// //         assertTrue(candice_token_num == num);
// //         assertTrue(alice_token_num == bob_token_num && bob_token_num == candice_token_num);
// //         assertTrue(alice_mint_time==mint1);
// //         assertTrue(bob_mint_time==mint2);
// //         assertTrue(candice_mint_time==mint3);
// //         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);
// //         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);

// //         uint256 alice_order = vno.getOrderFromTokenId(alice_tokenId);
// //         uint256 bob_order = vno.getOrderFromTokenId(bob_tokenId);
// //         uint256 candice_order = vno.getOrderFromTokenId(candice_tokenId);

// //         assertTrue(alice_order == 1);
// //         assertTrue(bob_order == 2);
// //         assertTrue(candice_order ==3);
// //     }   

}