// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "./FunctionsClientMock.sol";
import {ConfirmedOwner} from "@chainlink/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import "@chainlink/src/v0.8/automation/interfaces/ILogAutomation.sol";
import "./AutomationCompatibleInterfaceMock.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./DataConsumerV3.sol";
import "./SwapperMock.sol";
import "../interfaces/ILighterFi.sol";
import "./UtilsMock.sol";


contract LighterFi is FunctionsClient, ConfirmedOwner, ILighterFi, ILogAutomation, AutomationCompatibleInterface, DataConsumerV3, Swapper, Utils{
    
    using FunctionsRequest for FunctionsRequest.Request;

    uint256 public s_usersStrategiesLength;
    bytes32 public donID;
    uint32 public gasLimit;
    address public upkeepContract1;
    uint64 public subscriptionId;
    address public upkeepContract2;

    uint256 public strategyIndex;
    address public usdcAddress;
    bool public isPaused;
    bool public isInitialized;
    
    mapping(uint256=>UserStrategy) public s_usersStrategies;
    mapping(bytes32=>uint256) public requestsIds;

    /**@dev source string for Chainlink Function call*/
    string source = 
        "const fC= 'pol';"
        "const fT=args[0];"
        "const tT=args[1];"
        "const fAd=args[2];"
        "const fAm=args[3];"
        "const lRUrl = `https://staging.li.quest/v1/quote?fromChain=${fC}&toChain=${fC}&fromToken=${fT}&toToken=${tT}&fromAddress=${fAd}&fromAmount=${fAm}&denyExchange=all&allowExchange=pangolin&allowExchange=sushiswap`;"
        "const lR = await Functions.makeHttpRequest({"
            "url: lRUrl,"
            "method: 'GET',"
            "headers: {"
                "'accept': 'application/json',"
            "},"
        "});"
        "const data = lR.data.transactionRequest.data;"
        "const tD = lR.data.includedSteps[0].estimate.toolData;"
        "function parsebs(bs) {"
            "const ts = bs.slice(10);"
            "const txId = ts.slice(0, 64);"
            "const minOut = ts.slice(288, 320);"
            "const router = tD.routerAddress.slice(2);"
            "const selector = ts.slice(1664, 1672);"
            "let middleToken1 = '';"
            "let middleToken2 = '';"
            "if (tD.path.length === 3){"
                "middleToken1 = tD.path[1].slice(2);"
            "}"
            "if (tD.path.length === 4){"
                "middleToken1 = tD.path[1].slice(2);"
                "middleToken2 = tD.path[2].slice(2);"
            "}"
            "return txId+minOut+router+selector+middleToken1+middleToken2;"
        "}"
        "return (Functions.encodeString(parsebs(data)));";

    /**
    * @dev Constructor to initialize the contract with the specified router address.
    * @param _router Address of the router to use for function calls.
    */
    constructor(address _router) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        isInitialized = false;
        genericSwapFacet = IGenericSwapFacet(lifiDiamond);
    }

    /**
    * @dev Initialize the contract with various parameters.
    * @param _usdcAddress Address of the USDC token.
    * @param _gasLimit Gas limit to use for transactions.
    * @param _donID ID associated with the contract.
    * @param _subscriptionId ID of the subscription.
    * @param _upkeepContract1 Address of the first upkeep contract.
    * @param _upkeepContract2 Address of the second upkeep contract.
    */
    function init(address _usdcAddress, uint32 _gasLimit, bytes32 _donID, uint64 _subscriptionId, address _upkeepContract1, address _upkeepContract2) onlyOwner external {
        require(!isInitialized, "LighterFi: already initialized");
        usdcAddress = _usdcAddress;
        gasLimit = _gasLimit;
        donID = _donID;
        subscriptionId = _subscriptionId;
        upkeepContract1 = _upkeepContract1;
        upkeepContract2 = _upkeepContract2;
        isInitialized = true;
    }

    /**
     * @notice Reverts if called by anyone other than the contract owner or automation registry.
     */
    modifier onlyAllowed() {
        if (msg.sender != owner() && msg.sender != upkeepContract1 && msg.sender != upkeepContract2)
            revert NotAllowedCaller(msg.sender, owner(), upkeepContract1);
        _;
    }

    /**
    * @dev Set the addresses of the automation cron contracts.
    * @param _upkeepContract1 Address of the first automation cron contract.
    * @param _upkeepContract2 Address of the second automation log contract.
    * @notice Only the contract owner can call this function to update the addresses.
    */
    function setUpkeepForwarders(address _upkeepContract1, address _upkeepContract2) external onlyOwner {
        upkeepContract1 = _upkeepContract1;
        upkeepContract2 = _upkeepContract2;
    }

    /**
    * @dev Set or unset the pause status of the contract.
    * @param pause A boolean value to determine whether to pause or resume the contract.
    * @return The current pause status after the operation.
    * @notice Only the contract owner can call this function to toggle the pause status.
    */
    function setPause(bool pause) external onlyOwner returns(bool) {
        isPaused = pause;
        return (isPaused);
    }

    /**
    * @dev Create a new user strategy for automated actions.
    * @param tokenTo The address of the token to receive in the strategy.
    * @param timeInterval The time interval between strategy executions, in seconds.
    * @param tokenInAmount The amount of input tokens for the strategy.
    * @notice This function can only be called when the contract is not paused and with valid parameters.
    */
    function createStrategy(address tokenFrom, address tokenTo, uint256 timeInterval, uint256 tokenInAmount, uint256 limit) external {
        //parameters check
        require(!isPaused, "contract paused");
        require(tokenInAmount !=0, "invalid strategy param amount");
        require(tokenAllowed[tokenTo], "invalid strategy param tokenTo");
        require(tokenAllowed[tokenFrom], "invalid strategy param tokenFrom");
        require(timeInterval == 0 || limit == 0, "Either set a timeInterval or Limit");
        require(!(timeInterval == 0 && limit ==0), "Limit and TimeInterval are 0");
        require(tokenFrom == usdcAddress || tokenTo == usdcAddress, "Usdc must be in or out");
        uint nextExecution;
        if (timeInterval > 0) {
            nextExecution = block.timestamp + timeInterval; 
        } 

        //create new UserStrategy
        UserStrategy memory newStrategy = UserStrategy({
            user: msg.sender,
            tokenIn:  timeInterval > 0 ? usdcAddress : tokenFrom, //in case of Limit order the tokenIn can be different from USDC
            tokenOut: tokenTo, //in case of DCA the tokenOut can be different from USDC
            timeInterval: timeInterval,
            nextExecution: nextExecution,
            amount: tokenInAmount,
            limit: limit,
            lastResponse: hex'00'
        });

        require((newStrategy.tokenIn != newStrategy.tokenOut), "invalid strtagy param: tokens are equal");

        uint256 newstrategyIndex = strategyIndex;
        //save the strategy in the userStrategies mapping
        s_usersStrategies[newstrategyIndex] = newStrategy;
        //increment strategyIndex
        unchecked{
            strategyIndex += 1;
            //increment s_usersStrategiesLength variable
            s_usersStrategiesLength +=1;
            //emit NewUserStrategy event
        }
        emit NewUserStrategy(newStrategy.user, newStrategy, newstrategyIndex);
    }


    /**
    * @dev Remove a user strategy at a specified index.
    * @param index The index of the user strategy to be removed.
    * @notice Only the user who created the strategy can remove it.
    */
    function removeStrategy(uint256 index) external {
        //index check
        require(index <= s_usersStrategiesLength, "Index out of bounds"); 
        //load UserStrategy from mapping mapping
        UserStrategy memory strategyToRemove = s_usersStrategies[index];
        //user check
        require(strategyToRemove.user == msg.sender, "Unauthorized");
        //delete UserStrategy struct in s_usersStrategies mapping
        delete s_usersStrategies[index];
        s_usersStrategies[index].user = msg.sender;
        //emit RemovedUserStrategy event
        emit RemovedUserStrategy(msg.sender, index);
    }

    /**
    * @dev Upgrade an existing user strategy with new parameters.
    * @param index The index of the user strategy to be upgraded.
    * @param tokenTo The new address of the token to receive in the strategy.
    * @param timeInterval The new time interval between strategy executions, in seconds.
    * @param amountTokenIn The new amount of input tokens for the strategy.
    * @notice Only the user who created the strategy can upgrade it.
    */
    function upgradeStrategy(uint256 index, address tokenFrom, address tokenTo, uint256 timeInterval, uint256 amountTokenIn, uint256 limit) external  {
        //parameters check
        require(amountTokenIn !=0, "invalid strategy param amount");
        require(tokenAllowed[tokenTo], "invalid strategy param tokenTo");
        require(tokenAllowed[tokenFrom], "invalid strategy param tokenFrom");
        require(timeInterval == 0 || limit == 0, "Either set a timeInterval or Limit");
        require(tokenFrom != tokenTo, "invalid strtagy param: tokens are equal");
        require(!(timeInterval == 0 && limit ==0), "Limit and TimeInterval are 0");
        require(tokenFrom == usdcAddress || tokenTo == usdcAddress, "Usdc must be in or out");
        // Requirements for minimum timeInterval 
        // Requirements for minimum limit (in $)
        
        //index check
        require(index <= s_usersStrategiesLength, "Index out of bounds");
        //load UserStrategy from mapping mapping
        UserStrategy storage strategyToUpdate = s_usersStrategies[index];
        //user check
        require(strategyToUpdate.user == msg.sender, "Unauthorized");
        uint nextExecution;
        if (timeInterval > 0) {
            nextExecution = block.timestamp + timeInterval; 
        }
     
        // update strategyToRemove struct params
        strategyToUpdate.tokenIn = timeInterval > 0 ? usdcAddress : tokenFrom; //in case of Limit order the tokenIn can be different from USDC
        strategyToUpdate.tokenOut = tokenTo; //in case of DCA the tokenOut can be different from USDC
        require((strategyToUpdate.tokenIn != strategyToUpdate.tokenOut), "invalid strtagy param: tokens are equal");
        strategyToUpdate.timeInterval = timeInterval;
        strategyToUpdate.amount = amountTokenIn;
        strategyToUpdate.limit = limit;

        //emit UpdatedUserStrategy event
        emit UpdatedUserStrategy(strategyToUpdate.user, strategyToUpdate, index);
  
    }

    /**
    * @dev checkUpkeep function called off-chain by Chainlink Automation infrastructure
    * @dev It checks for any s_usersStrategies if they are executable (timeCondition, balanceCondition and allowanceCondition)
    * @return upkeepNeeded A boolean indicating whether upkeep is needed.
    * @return performData The performData parameter triggering the performUpkeep
    * @notice This function is external, view, and implements the Upkeep interface.
    */
    function checkUpkeep(bytes calldata, int fuzz) external view override returns (bool upkeepNeeded, bytes memory performData) {
        
        uint[] memory prices = _batchQuery(fuzz);
        bool balanceCondition;
        bool allowanceCondition;
        bool timeCondition;
        bool limitCondition;
        for (uint256 i = 0; i < s_usersStrategiesLength; i++) {
            //load UserStrategy
            UserStrategy memory strategy = s_usersStrategies[i];
            //Check if is valid strtagy 
            if (strategy.user != address(0)){

                // DCA 
                if (strategy.timeInterval != 0) {
                    timeCondition = block.timestamp >= strategy.nextExecution;
                    balanceCondition = IERC20(usdcAddress).balanceOf(strategy.user) >= strategy.amount;
                    allowanceCondition = IERC20(usdcAddress).allowance(strategy.user, address(this)) >= strategy.amount;
                    upkeepNeeded = timeCondition && balanceCondition && allowanceCondition;
                    performData = abi.encode(i, uint(0));
                 
                }  
                // Limit
                if (strategy.timeInterval == 0 && strategy.limit != 0) {
                    //buy only if the token price is <= the limit set
                    //sell only if the token price is >= the limit set
                    limitCondition = strategy.tokenIn == usdcAddress ? prices[tokenIndexes[strategy.tokenOut]] <= strategy.limit : prices[tokenIndexes[strategy.tokenIn]] >= strategy.limit;
                    balanceCondition = IERC20(strategy.tokenIn).balanceOf(strategy.user) >= strategy.amount;
                    allowanceCondition = IERC20(strategy.tokenIn).allowance(strategy.user, address(this)) >= strategy.amount;
                    upkeepNeeded = limitCondition && balanceCondition && allowanceCondition;
                    performData = abi.encode(i, uint(0));
                }   
                if (upkeepNeeded){
                    return (upkeepNeeded, performData);
                }
            }
        }
    }

    /**
    * @dev checkLog function called off-chain by Chainlink Automation infrastructure
    * @dev It checks if the Response event by fulfillRequest function is emitted in order to perform the actual swap
    * @return upkeepNeeded A boolean indicating whether upkeep is needed.
    * @return performData The performData parameter triggering the performUpkeep
    * @notice This function is external, view, and implements the Upkeep interface.
    */
    function checkLog(
        Log calldata log,
        bytes memory
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {
        //if the fulfill request function had an error the upkeep must not be triggered
        if(log.topics[2] != hex'') {
            upkeepNeeded = false;
        } else{
            upkeepNeeded = true;  
        }
        performData = abi.encode(log.topics[0], uint(1));
    }
    
    /**
    * @dev performUpkeep function called by Chainlink Automation infrastructure after checkUpkeep and checkLog off-chain checks
    * @param performData the data inputed by Chainlink Automation retrieved by checkUpkeep and checkLog output
    * @notice This function is external and it's used both to call the sendRequest (to call the LIFI API) and to perform the actual user swap (using the calldata retrieved by the fulfillRequest) 
    */
    function performUpkeep(bytes calldata performData) onlyAllowed external override(ILogAutomation, AutomationCompatibleInterface) {
        //retrieve the index
        (, uint operationId) = abi.decode(performData, (uint, uint));
        if (operationId == 0){
            (uint index, ) = abi.decode(performData, (uint, uint));
            //load UserStrategy
            UserStrategy storage strategy = s_usersStrategies[index];
            if(strategy.timeInterval != 0){
                strategy.nextExecution = block.timestamp + strategy.timeInterval;
            } else {
                strategy.limit = 0;
            }
            //perform sendRequest
            sendRequest(index);
            //update UserStrategy nextExecution
        } else {
            (bytes32 requestId, ) = abi.decode(performData, (bytes32, uint));
            uint index = requestsIds[requestId];
            UserStrategy storage strategy = s_usersStrategies[index];
            //if it's a limit order operation it must be deleted after its execution
            if(strategy.limit>0) {
                //delete UserStrategy struct in s_usersStrategies mapping
                s_usersStrategies[index].limit = 0;
            }
            uint startingBalance = IERC20(strategy.tokenOut).balanceOf(strategy.user);
            IERC20(strategy.tokenIn).transferFrom(strategy.user, address(this), strategy.amount);
            IERC20(strategy.tokenIn).approve(lifiDiamond, strategy.amount);
           
            readResponseAndSwap(strategy.lastResponse, strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
            uint finalBalance = IERC20(strategy.tokenOut).balanceOf(strategy.user) - startingBalance;
            emit SwapExecuted(requestId, index, strategy.amount, finalBalance, strategy.user, strategy.tokenIn, strategy.tokenOut);
        }
    }
        address usdcAvax = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;
        address wmatic = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    
    function performUpkeepMock() onlyAllowed public{
        UserStrategy memory strategy = s_usersStrategies[0];

        uint startingBalance = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).balanceOf(strategy.user);
        IERC20(usdcAvax).transferFrom(strategy.user, address(this), 100000);
        IERC20(usdcAvax).approve(lifiDiamond, 100000);
        readResponseAndSwap(hex'373539646165343839356266393464643637366639633031393432306666643633613935646537396363396537616464643036653133303362656531383763373030303030303030303030303030303030303061643239333163356366626264453534436138363533316531374566333631366432324361323862304434353862364338393130363635373563633139', strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
        uint finalBalance = IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).balanceOf(strategy.user) - startingBalance;
    }
    /**
     * @notice Sends an HTTP request using Chainlink Functions infrastructure
     * @param index the index of the user strategy containing the data to pass to the LIFI API call.
     */
    function sendRequest(uint256 index) public {
        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(source); 
        //load UserStrategy from mapping mapping
        UserStrategy memory strategy = s_usersStrategies[index];
        //retrieve args as string[] for chainLink function Request encoding
        string[] memory args = generateArgForRequest(strategy.tokenIn, strategy.tokenOut, strategy.user, strategy.amount);
        // Set the arguments for the request
        req.setArgs(args); 
        // Send the request and store the request ID
        bytes32 requestId = bytes32("requestId");
        requestsIds[requestId] = index;
        //emit RequestReceived event
        emit RequestReceived(requestId, index);
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) public override {
    
        // Update the contract's state variables with the response and any errors
        uint256 index = requestsIds[requestId];
        //load UserStrategy from mapping mapping
        s_usersStrategies[index].lastResponse = response;
        // Emit an event to log the response
        emit Response(requestId, response, err);
    }

    function mapAddresses(address[] calldata tokenAddresses) onlyOwner() public {
        _mapAddresses(tokenAddresses);
    }
}