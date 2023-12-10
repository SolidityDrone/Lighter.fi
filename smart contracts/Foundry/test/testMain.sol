// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "std/test.sol";
import "../src/mocks/LighterFiMock.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/mocks/ERC20Mock.sol";
contract Test_Sample is Test {
    address wavax = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address usdc = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;
    address user = 0x7785702C9B61782fa37521dF1eB0139EdDdA2f4E;
    address[] newAddresses = [usdc, wavax]; 
    
    LighterFi lighter;
    
    function setUp() public {
        lighter = LighterFi(0x0942A261Fb819D6Cf6E4b5F878338801e0ff0b9D);      

        vm.prank(user);
    }

    // function testPerformMockAvax() public {
      
      
        
    //     vm.prank(0xc44041F3724fC2612e20F011a176bF7624A4E5ea);
    //     lighter.performUpkeep(abi.encode(0x00fc6ecc10789568d9db2c4d73feb023cbc1255a728ffc2bb028b3bdb012b607, 1));
    //     console.log(IERC20(usdc).balanceOf(user));
    //     console.log(IERC20(wavax).balanceOf(user));

    //     console.log(address(this));
    // }

}   
