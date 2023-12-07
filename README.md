# Lighter.Fi


# Run readAndSwap via foundry

Since LiFi dosen't support fuji testnet, nor mumbai. We commented out the lines executing the trade.
To test that it works properly you can follow these steps.
- Navigate to: https://functions.chain.link/playground
- Paste in https://github.com/SolidityDrone/onchain_dca/blob/main/smart%20contracts/Foundry/src/functionsJS/lifiapi_hardcoded 
- Get the return and replace <resultfromchainlinkfunctions> in LighterFiMock.sol

    `function performUpkeepMock() public{
        UserStrategy memory strategy = s_usersStrategies[0];
        IERC20(usdcAvax).transferFrom(msg.sender, address(this), 10000000);
        IERC20(usdcAvax).approve(lifiDiamond, 10000000);
        readResponseAndSwap(hex'<resultfromchainlinkfunctions>', strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
    }`


- Run `forge test --match-test testPerformMock -vvv --fork-url https://api.avax.network/ext/bc/C/rpc`

`function testPerformMock() public {
        deal(usdc, address(this), 10000000);
        IERC20(usdc).approve(address(lighter), 10000000);
        lighter.performUpkeepMock();
        console.log(IERC20(wavax).balanceOf(address(this)));
}`

If you did everything correctly yuou should be able to see the amount swapped USDC <> Wavax


# Test and Coverage 
  To run tests access foundry folder and run `forge test` can add `-vvv` for a deep stack trace
  Test that would fail in non mainnet fork environment are commented out. They'll revert if uncommented.

| File                              | % Lines           | % Statements      | % Branches      | % Funcs         |
|-----------------------------------|-------------------|-------------------|-----------------|-----------------|
| src/Mocks/DataConsumerV3.sol      | 100.00% (14/14)   | 100.00% (17/17)   | 50.00% (1/2)    | 100.00% (4/4)   |
| src/Mocks/ERC20Mock.sol           | 100.00% (1/1)     | 100.00% (1/1)     | 100.00% (0/0)   | 100.00% (1/1)   |
| src/Mocks/LighterFiMock.sol       | 98.13% (105/107)  | 98.26% (113/115)  | 93.10% (54/58)  | 100.00% (12/12) |
| src/Mocks/SwapperMock.sol         | 100.00% (54/54)   | 100.00% (63/63)   | 80.00% (8/10)   | 85.71% (6/7)    |
| src/Mocks/UtilsMock.sol           | 100.00% (26/26)   | 97.30% (36/37)    | 0.00% (0/2)     | 100.00% (3/3)   |

