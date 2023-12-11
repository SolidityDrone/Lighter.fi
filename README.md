# Lighter.Fi

## Contracts
Avalanche mainnet contract address:          0xaeAC25ae4C6C6808a8d701C6560CA72498De40D5

Avalanche fuji testnet contract address:     0xf79d99e640d5e66486831fd0bc3e36a29d3148c0

## Run readAndSwap via foundry

Since LiFi dosen't support fuji testnet, nor mumbai. Even tho the contract is live on mainnet, we reccomend testing the integration via foundry
To test that it works properly you can follow these steps.
- Navigate to: https://functions.chain.link/playground
- Paste in https://github.com/SolidityDrone/onchain_dca/blob/main/smart%20contracts/Foundry/src/functionsJS/lifiapi_hardcoded 
- Get the return AS BYTES and replace <resultfromPlayground> in LighterFiMock.sol

```
    function performUpkeepMock() public{
        UserStrategy memory strategy = s_usersStrategies[0];
        IERC20(usdcAvax).transferFrom(msg.sender, address(this), 10000000);
        IERC20(usdcAvax).approve(lifiDiamond, 10000000);
        readResponseAndSwap(hex'<resultfromPlayground>', strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
    }
```

- Run `forge test --match-test testPerformMock -vvv --fork-url https://api.avax.network/ext/bc/C/rpc`
```
function testPerformMock() public {
        deal(usdc, address(this), 10000000);
        IERC20(usdc).approve(address(lighter), 10000000);
        lighter.performUpkeepMock();
        console.log(IERC20(wavax).balanceOf(address(this)));
}
```

If you did everything correctly yuou should be able to see the amount swapped in the console.


## Test and Coverage 
  To run tests access foundry folder and run `forge test` can add `-vvv` for a deep stack trace
  Test that would fail in non mainnet fork environment are commented out. They'll revert if uncommented.

| File                              | % Lines           | % Statements      | % Branches      | % Funcs         |
|-----------------------------------|-------------------|-------------------|-----------------|-----------------|
| src/Mocks/DataConsumerV3.sol      | 100.00% (14/14)   | 100.00% (17/17)   | 50.00% (1/2)    | 100.00% (4/4)   |
| src/Mocks/ERC20Mock.sol           | 100.00% (1/1)     | 100.00% (1/1)     | 100.00% (0/0)   | 100.00% (1/1)   |
| src/Mocks/LighterFiMock.sol       | 98.13% (105/107)  | 98.26% (113/115)  | 93.10% (54/58)  | 100.00% (12/12) |
| src/Mocks/SwapperMock.sol         | 100.00% (54/54)   | 100.00% (63/63)   | 80.00% (8/10)   | 85.71% (6/7)    |
| src/Mocks/UtilsMock.sol           | 100.00% (26/26)   | 97.30% (36/37)    | 0.00% (0/2)     | 100.00% (3/3)   |

