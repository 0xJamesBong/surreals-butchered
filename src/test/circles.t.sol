// https://github.com/foundry-rs/forge-std

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/forge-std/src/Test.sol";
// import "../../lib/ds-test/src/test.sol";
// import "../../lib/ds-test/src/console.sol";
// import "../../lib/ds-test/src/cheats.sol";

import "forge-std/Test.sol";
import "../circle.sol";

interface CheatCodes {
    function startPrank(address) external;
    function prank(address) external;
    function deal(address who, uint256 newBalance) external;
    function addr(uint256 privateKey) external returns (address);
    function warp(uint256) external;    // Set block.timestamp
}

contract CircleTest is Test {
    
    Circle circle;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    // HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

    address alice = cheats.addr(1);
    address bob = cheats.addr(2);
    address candice = cheats.addr(3);
    address dominic = cheats.addr(4);

    function setUp() public {
        circle = new Circle();
    }
    
    function testRender() public {
        string memory svg = circle._render(0x30F0380203C0E83F0E00800C030F0380203C0F038020380);
        console.log(svg);
    }
}