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
        lighter = new LighterFi(address(this));      
        init();
        _mapAddresses();
        vm.prank(user);
        lighter.createStrategy(usdc, wavax, 0, 100000, 1);
    }

    function init() internal {
        // hardcoded values of polygon. Forwarders are any 
        lighter.init(usdc, 300_000, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, 1004, address(0), address(0));
    }

    function _mapAddresses() internal {
        // internal function map newAddresses array
        lighter.mapAddresses(newAddresses);
    }


    // // // retrieve calldata using Chainlink Playground at https://functions.chain.link/playground
    // // // find the script in functionsJS folder
    // // // forge test --match-test testAvax -vvv --fork-url https://api.avax.network/ext/bc/C/rpc
    // function testAvax() public {
        
    //     deal(usdc, address(this), 1e10);
    //     IERC20(usdc).approve(address(lighter), 10e18);
        
    //     vm.prank(address(lighter));
    //     IERC20(usdc).transferFrom(address(this), address(lighter), 10000000);
    //     vm.prank(address(lighter));
    //     IERC20(usdc).approve(0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE, 10000000);
    //     vm.prank(address(lighter));
    //     lighter.readResponseAndSwap(hex'dee9b2e4c50b34dcd25889b6200243a768f3e49c655df28977ea60b5c137ddd20000000000000000008733df860182c51b02dA8Cb0d097eB8D57A175b88c7D8b47997506657242a549d5c2bdffac6ce2bfdb6640f4f80f226bc10bab', 10000000, address(this), usdc, wavax);
    //     console.log(IERC20(usdc).balanceOf(address(this)));
    //     console.log(IERC20(wavax).balanceOf(address(this)));
    // }
    
    // // // retrieve calldata using Chainlink Playground at https://functions.chain.link/playground
    // // // find the script in functionsJS folder
    // // // forge test --match-test testPerformMock -vvv --fork-url https://api.avax.network/ext/bc/C/rpc
    
    // function testPerformMock() public {
       
    //     vm.prank(user);
    //     IERC20(usdc).approve(address(lighter), 100000);
        
        
    //     lighter.performUpkeepMock();
    //     console.log(IERC20(usdc).balanceOf(user));
    //     console.log(IERC20(wavax).balanceOf(user));

    //     console.log(address(this));
    // }

    
}   
