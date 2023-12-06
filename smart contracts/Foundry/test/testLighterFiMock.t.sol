// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "std/test.sol";
import "../src/mocks/LighterFiMock.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/mocks/ERC20Mock.sol";
contract Test_Sample is Test {
    address wmatic = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address any = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address any2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    ERC mockedToken1;
    ERC mockedToken2;
    LighterFi lighter;
    address[] mockedERC = [address(mockedToken1), address(mockedToken2)];
    address[] newAddresses = [usdc, wmatic, any]; 
    address[] secondAddressList = [usdc, any2];
    function setUp() public {
        // Deply LighterFi contract
        lighter = new LighterFi(address(this));  
    }
    
    function test_pause() public { 
        // set pause
        lighter.setPause(true);
        // assert paused
        assertTrue(lighter.isPaused(), "Expected to be true");
        // unset pause
        lighter.setPause(false);
        // assert unpaused
        assertTrue(!lighter.isPaused(), "Expected to be true");
        // test onlyOwner 
        vm.prank(address(address(any)));
        vm.expectRevert("Only callable by owner");
        lighter.setPause(false);
    }

    function test_init() public {
        // test revert of init from not owner
        vm.prank(address(any));
        vm.expectRevert();
        init();
        // test init from owner
        init();      
        assertTrue(lighter.isInitialized());
        // test revert on subsequent init()
        vm.expectRevert("LighterFi: already initialized");
        init();
    }

    function init() internal {
        // hardcoded values of polygon. Forwarders are any 
        lighter.init(usdc, 300_000, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, 1004, address(any), address(any));
    }
    
    function test_setUpkeepForwarders() public {
        // test setUpkeepForwarders
        vm.prank(address(any));
        vm.expectRevert();
        lighter.setUpkeepForwarders(address(any), address(any2));
        lighter.setUpkeepForwarders(address(any), address(any2));

        assertTrue(lighter.upkeepContract1() == any);
        assertTrue(lighter.upkeepContract2() == any2);
    }

    
    function test_mapAddress() public {
            //map addresses 
            _mapAddresses();
            //assert every address is allowed
            for (uint i; i<newAddresses.length; i++){
                assertTrue(lighter.tokenAllowed(newAddresses[i]));
            }
            //assert allowed address number is correct
            assertTrue(lighter.addressMappinglength() == 3);
            //map a second list of addresses containing a duplicate
            lighter.mapAddresses(secondAddressList);
            //assert the length increased only by the newely added address
            assertTrue((
                lighter.addressMappinglength() == newAddresses.length + 1)
                && lighter.tokenAllowed(any2));
            _mapAddresses();
            assertTrue(lighter.addressMappinglength() == newAddresses.length + 1);
        }

    function _mapAddresses() internal {
        // internal function map newAddresses array
        lighter.mapAddresses(newAddresses);
    }
    
    
    function testFuzz_batchQuery_V3Aggregator(int fuzz) public {
        // assume int fuzz > 0 
        vm.assume(fuzz > 0);
        lighter.mapAddresses(newAddresses);
        // assert that for each address we get a correct amount
        uint[] memory answers = lighter._batchQuery(fuzz);
        for (uint i; i < newAddresses.length; i++){
            assertTrue(answers[i] == uint(fuzz/100));
        }
    }

    function test_internal_reseizeDecimals(int fuzz) public {
        // assume int fuzz > 0 
        vm.assume(fuzz > 0);
        // assert reseizing of decimal works as intended
        uint reseized = lighter.reseizeDecimals(fuzz);
        assertTrue(uint(fuzz / 100) == lighter.reseizeDecimals(fuzz));
    }

    function test_getChainLinkDataFeedLatestAnswer(int fuzz) public {
        vm.assume(fuzz > 0);
        assert(lighter.getChainlinkDataFeedLatestAnswer(any, fuzz) == fuzz);
    }
    
    function test_internal_mapAddress() public {
            lighter._mapAddresses(newAddresses);
            for (uint i; i<newAddresses.length; i++){
                assertTrue(lighter.tokenAllowed(newAddresses[i]));
                
            }
            assertTrue(lighter.addressMappinglength() == 3);
            lighter._mapAddresses(secondAddressList);
            assertTrue((
                lighter.addressMappinglength() == newAddresses.length + 1)
                && lighter.tokenAllowed(any2));

            lighter._mapAddresses(newAddresses);
            assertTrue(lighter.addressMappinglength() == newAddresses.length + 1);
        }


    function test_createStrategy_DCA() public {
        // init contract thus usdc as .usdcAddress
        init();
        // test revert of createStrategy when contract is paused
        lighter.setPause(true);
        vm.expectRevert("contract paused");
        lighter.createStrategy(usdc, wmatic, 0, 1e18, 0);
        lighter.setPause(false);
        // test revert for non mapped tokenOut
        vm.expectRevert("invalid strategy param tokenTo");
        lighter.createStrategy(usdc, wmatic, 0, 1e18, 0);
        // map address
        _mapAddresses();
        //test revert for non mapped tokenIn
        vm.expectRevert("invalid strategy param tokenFrom");
        lighter.createStrategy(any2, wmatic, 1, 1e18, 0);
        // test revert when both limit and timeinterval are 0
        vm.expectRevert("Limit and TimeInterval are 0");
        lighter.createStrategy(usdc, wmatic, 0, 1e18, 0);
        // test revert for amount equal 0
        vm.expectRevert("invalid strategy param amount");
        lighter.createStrategy(usdc, wmatic, 1, 0, 1);
        // test revert when both limit and timeinterval are set
        vm.expectRevert("Either set a timeInterval or Limit");
        lighter.createStrategy(usdc, wmatic, 1, 1e18, 1);
        // test revert if after ternary operation token addresses are equal
        vm.expectRevert("invalid strtagy param: tokens are equal");
        lighter.createStrategy(usdc, usdc, 1, 1e18, 0);
        // finally create strategy correctly
        lighter.createStrategy(usdc, wmatic, 360, 1e18, 0);
        assertTrue(lighter.s_usersStrategiesLength() == 1);

        (address user,
        address tokenIn,
        address tokenOut,
        uint256 timeInterval,
        uint256 nextExecution,
        uint256 amount,
        uint256 limit,
        bytes memory lastResponse) = lighter.s_usersStrategies(0);
        // asserts of strategy struct
        assertTrue(user == address(this));
        assertTrue(tokenIn == usdc);
        assertTrue(tokenOut == wmatic);
        assertTrue(nextExecution == block.timestamp + timeInterval);
        assertTrue(amount == 1e18);
        assertTrue(limit == 0);
        assertEq(lastResponse, hex'00');

        // assert the counter is correctly increased
        lighter.createStrategy(usdc, wmatic, 0, 1e18, 1);
        assertTrue(lighter.s_usersStrategiesLength() == 2);
    }

    function test_removeStrategy() public {
        // create a strategy
        init();
        _mapAddresses();
        lighter.createStrategy(usdc, wmatic, 360, 1e18, 0);

        //assert revert due to index outbound
        vm.expectRevert("Index out of bounds");
        lighter.removeStrategy(2);
        //assert revert due to not being .user
        vm.prank(any);
        vm.expectRevert("Unauthorized");
        lighter.removeStrategy(0);
        //finally remove the strategy params
        lighter.removeStrategy(0);

        (address user,
        address tokenIn,
        address tokenOut,
                        ,
        uint256 nextExecution,
        uint256 amount,
        uint256 limit,
        bytes memory lastResponse) = lighter.s_usersStrategies(0);
        // assert deleted enrtries
        assertTrue(user == address(this));
        assertTrue(tokenIn == address(0));
        assertTrue(tokenOut == address(0));
        assertTrue(nextExecution ==  0);
        assertTrue(amount == 0);
        assertTrue(limit == 0);

    }
    
    function test_upgradeStrategy() public {
        init();
        _mapAddresses();
        lighter.createStrategy(usdc, wmatic, 360, 1e18, 0);
        
        vm.expectRevert("invalid strategy param tokenTo");
        lighter.upgradeStrategy(0, usdc, any2, 0, 1e18, 0);
        
        vm.expectRevert("invalid strategy param tokenFrom");
        lighter.upgradeStrategy(0, any2, wmatic, 1, 1e18, 0);
        
        vm.expectRevert("Limit and TimeInterval are 0");
        lighter.upgradeStrategy(0, usdc, wmatic, 0, 1e18, 0);

        vm.expectRevert("invalid strategy param amount");
        lighter.upgradeStrategy(0, usdc, wmatic, 1, 0, 1);

        vm.expectRevert("Either set a timeInterval or Limit");
        lighter.upgradeStrategy(0, usdc, wmatic, 1, 1e18, 1);

        vm.expectRevert("invalid strtagy param: tokens are equal");
        lighter.upgradeStrategy(0, usdc, usdc, 1, 1e18, 0);
        
        lighter.upgradeStrategy(0, usdc, wmatic, 1, 1e18, 0);

        lighter.createStrategy(usdc, wmatic, 0, 1e18, 1);
        lighter.upgradeStrategy(0, usdc, wmatic, 0, 1e18, 1e18);
    }

    bytes32[] topics = [bytes32("hello"), bytes32(abi.encode("")), hex'00'];
    bytes32[] topicsErr = [bytes32("hello"), bytes32(abi.encode("")), bytes32("any error")];
    function test_checkLog() public {
        Log memory log = Log({
            index: 0,
            timestamp: 0,
            txHash: bytes32(0),
            blockNumber: 0,
            blockHash: bytes32(0),
            source: address(0),
            topics: topics,
            data: abi.encode("")
        });
        // checkLog with error hex'00' and assert upkeep is needed
        (bool upkeepNeeded, bytes memory performData) = lighter.checkLog(log, abi.encode(""));
        assertTrue(upkeepNeeded);
        assertEq(performData, abi.encode(bytes32("hello"), uint(1)));

        Log memory logErr = Log({
            index: 0,
            timestamp: 0,
            txHash: bytes32(0),
            blockNumber: 0,
            blockHash: bytes32(0),
            source: address(0),
            topics: topicsErr,
            data: abi.encode("")
        });
        // checkLog with error non hex'00' and assert upkeep is NOT needed
        (upkeepNeeded, performData) = lighter.checkLog(logErr, abi.encode(""));
        assertTrue(!upkeepNeeded);
    }


    function test_checkUpkeep_DCA(int fuzz) public {
        vm.assume(fuzz > 100 && fuzz < 1e30);
 
        //set a dca interval
        uint timeInterval =360;
        uint fundAmounts = uint(fuzz);
        // deploy mocked tokens 
        mockedToken1 = new ERC("mockedToken1", "1");
        mockedToken1.mint(address(this), fundAmounts);
        mockedToken1.approve(address(lighter), fundAmounts);

        mockedToken2 = new ERC("mockedToken2", "2");
        mockedToken2.mint(address(this), fundAmounts);
        mockedToken2.approve(address(lighter), fundAmounts);

        mockedERC[0] =address(mockedToken1);
        mockedERC[1] =address(mockedToken2);
        // init with mockedToken1 as usdcaddress
        lighter.init(address(mockedToken1), 300_000, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, 1004, address(any), address(any));
        lighter.mapAddresses(mockedERC);
        //create strategy
        lighter.createStrategy(address(mockedToken1), address(mockedToken2), timeInterval, fundAmounts, 0);
        // assert upkeep NOT needed 
        (bool upkeepNeeded, bytes memory performData) = lighter.checkUpkeep(abi.encode(""), fuzz);
        assertTrue(!upkeepNeeded);
        
        // warp to nextExecution and assert upkeep is needed
        vm.warp(block.timestamp + timeInterval);
        (upkeepNeeded,  performData) = lighter.checkUpkeep(abi.encode(""), fuzz);
        assertTrue(upkeepNeeded);
       
    }

     function test_checkUpkeep_Limit() public {
        uint fundAmounts = uint(1e18);
        
        mockedToken1 = new ERC("mockedToken1", "1");
        mockedToken1.mint(address(this), fundAmounts);
        mockedToken1.approve(address(lighter), fundAmounts);

        mockedToken2 = new ERC("mockedToken2", "2");
        mockedToken2.mint(address(this), fundAmounts);
        mockedToken2.approve(address(lighter), fundAmounts);

        mockedERC[0] =address(mockedToken1);
        mockedERC[1] =address(mockedToken2);
        lighter.init(address(mockedToken1), 300_000, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, 1004, address(any), address(any));
        lighter.mapAddresses(mockedERC);

        // assert buy order upkeep not needed 
        lighter.createStrategy(address(mockedToken1), address(mockedToken2), 0, fundAmounts, 1);
        (bool upkeepNeeded, bytes memory performData) = lighter.checkUpkeep(abi.encode(""), int(1e16));
        assertTrue(!upkeepNeeded);
        // assert buy order upkeep is needed 
        lighter.upgradeStrategy(0, address(mockedToken1), address(mockedToken2), 0, fundAmounts, 1e18);
        (upkeepNeeded, performData) = lighter.checkUpkeep(abi.encode(""), int(1e16));
        assertTrue(upkeepNeeded);


        // assert sell order upkeep is needed 
        lighter.upgradeStrategy(0, address(mockedToken2), address(mockedToken1), 0, fundAmounts, 1);
        (upkeepNeeded, performData) = lighter.checkUpkeep(abi.encode(""), int(1e16));
        assertTrue(upkeepNeeded);
        // assert sell order upkeep not needed 
        lighter.upgradeStrategy(0, address(mockedToken2), address(mockedToken1), 0, fundAmounts, 1e18);
        (upkeepNeeded, performData) = lighter.checkUpkeep(abi.encode(""), int(1e16));
        assertTrue(!upkeepNeeded);
    }
    
    function test_fulfillRequest() public {
        // mock fulfillRequest 
        lighter.fulfillRequest(bytes32("requestId"), bytes("response"), bytes("err"));
         lighter.s_usersStrategies(0);
        (,
        ,
        ,
        ,
        ,
        ,
        ,
        bytes memory lastResponse) = lighter.s_usersStrategies(0);
        // assert response is stored correctly in s_userStrategies
        assertEq(lastResponse, bytes("response"));
    }

    function test_internal_sendRequest() public {
        lighter.sendRequest(0);
    }
    
    function test_performUpkeep() public {
        uint upkeepPerformData0 = 0;
        uint upkeepPerformData1 = 1;
        uint i = 0;
        uint fundAmounts = type(uint).max; 
        mockedToken1 = new ERC("mockedToken1", "1");
        mockedToken1.mint(address(this), fundAmounts);
        mockedToken1.approve(address(lighter), fundAmounts);
        
         mockedToken2 = new ERC("mockedToken2", "2");
        mockedToken2.mint(address(this), fundAmounts);
        mockedToken2.approve(address(lighter), fundAmounts);

        mockedERC[0] =address(mockedToken1);
        mockedERC[1] =address(mockedToken2);
        
        lighter.init(address(mockedToken1), 300_000, 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, 1004, address(any), address(any));
        lighter.mapAddresses(mockedERC);
        
        lighter.createStrategy(address(mockedToken1), address(mockedToken2), 360, 1e18, 0);
        lighter.performUpkeep(abi.encode(i, upkeepPerformData0));

        i++;
        lighter.createStrategy(address(mockedToken1), address(mockedToken2), 0, 1e18, 1e18);
        lighter.performUpkeep(abi.encode(i, upkeepPerformData0));

        lighter.performUpkeep(abi.encode(i, upkeepPerformData1));
    }

    function test_generateArgsForRequests() public {
        string[] memory strings;
        // assert string conversion is consistent for cl_functions args
        strings = lighter.generateArgForRequest(usdc, wmatic, any, 123456789);
        assertEq(strings[0], "0x2791bca1f2de4661ed88a30c99a7a9449aa84174");
        assertEq(strings[1], "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270");
        assertEq(strings[2], "0x5b38da6a701c568545dcfcb03fcb875f56beddc4");
        assertEq(strings[3], "123456789");
    }

    function test_uintToString() public {
        // assert string is working on any character
        assertEq(lighter.uintToString(0), "0");
        assertEq(lighter.uintToString(1234567890), "1234567890");
    }


    function test_addressToBytes32(address _address) public {
        assertEq(bytes32(uint256(uint160(_address))),lighter.addressToBytes32(_address));
    }

    function test_uintToBytes32(uint u) public {
        assertEq(bytes32(u), lighter.uintToBytes32(u));
    }

    function test_bytes32ToBytes4(bytes32 b32) public {
        assertEq(lighter.bytes32tobytes4(b32), bytes4(b32));
    }

    function test_unpackBytes_and_concatData() public{
        // test an example string returned by Functions
        bytes memory clFunctionExampleBytesReturn = hex'0a73e24538d154555f286ce69a790402221b64536c2e4deceee47a53ae5b2b1b00000000000000000000000000000051a5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff65701947831753dd7087cac61ab5644b308642cc1c33dc138f3cf7ad23cd3cadbd9735aff958023239c6a063';
        // unpack bytes 
        (
            bytes32[2] memory properties,
            bytes16[1] memory minAmount,
            address[] memory middleTokens,
            bytes4[1] memory routerSelector
        ) = lighter.unpackBytes(clFunctionExampleBytesReturn);
        // assert every data is unpacked correcty
        assertEq(properties[0], hex'0a73e24538d154555f286ce69a790402221b64536c2e4deceee47a53ae5b2b1b');
        assertEq(properties[1], hex'000000000000000000000000a5e0829caced8ffdd4de3c43696c57f7d7a678ff');
        assertEq(routerSelector[0], hex'65701947');
        // console log length of middle path tokens
        console.log("Middle tokens to compose path: ", middleTokens.length);
        // assert string min length
        vm.expectRevert("Data length must be >= 72!");
        lighter.unpackBytes(bytes("wrong length"));

        uint amountIn = 100000000000000;
        // concatenate data via ConcatCalldata
        bytes memory concatenatedData = lighter.ConcatCalldata(amountIn, minAmount[0], middleTokens, routerSelector[0]);
        
        bytes4 methodSig = 0x38ed1739; // lifi method signature for SwapGeneric
        bytes32 const = 0x00000000000000000000000000000000000000000000000000000000000000a0; 
        uint hops = 2; // hops in between in and out, provided in this example
        bytes memory path = abi.encodePacked(lighter.addressToBytes32(middleTokens[0]), lighter.addressToBytes32(middleTokens[1]), bytes28(0));
        assertEq(abi.encodePacked(methodSig, 
            bytes32(amountIn),
            bytes(abi.encodePacked(bytes16(0), bytes16(minAmount[0]))),
            const,
            lighter.addressToBytes32((lighter.lifiDiamond())),
            bytes32(abi.encodePacked(bytes28(0), routerSelector[0])),
            bytes32(hops), // this case has 2 mid tokens
            path
        ), concatenatedData);
        
    }

    function test_readResponseAndSwap() public {
        // This function is exected to revert, to test this out a new string must be provided
        // from playground for example. Remove the expect revert and run test against mainnet via
        // --fork-url <rpc-url>
        uint amountIn = 100000000000000;
        bytes memory clFunctionExampleBytesReturn = hex'0a73e24538d154555f286ce69a790402221b64536c2e4deceee47a53ae5b2b1b00000000000000000000000000000051a5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff65701947831753dd7087cac61ab5644b308642cc1c33dc138f3cf7ad23cd3cadbd9735aff958023239c6a063';
        vm.expectRevert(); // This will revert if not called via --fork-url || outdated data string
        lighter.readResponseAndSwap(clFunctionExampleBytesReturn, amountIn, address(this), usdc, wmatic);
    }
}
