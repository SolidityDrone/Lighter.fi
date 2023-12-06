// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "std/test.sol";
import "../src/Swapper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Test_Sample is Test {
    address wmatic = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    Swapper lifiSwapper;
    // function setUp() public {
    //     lifiSwapper = new Swapper();
    //     IERC20(usdc).approve(address(lifiSwapper.lifiDiamond()), 10e18);
    // }
    function test()public{
        
    }
        // function testReadResponseAndSwap() public {
        //     deal(usdc, address(lifiSwapper), 100000000);
        //     lifiSwapper.readResponseAndSwap(hex'f2712fa14443e607783257244a1e1425e96a694343721b67df3c7a8431a067d00000000000000006fe2b48d2b2e169931b02dA8Cb0d097eB8D57A175b88c7D8b479975066568b0de', 100000000, address(lifiSwapper), usdc, wmatic);
        //     console.log("", IERC20(wmatic).balanceOf(address(lifiSwapper)));
        // }
}
