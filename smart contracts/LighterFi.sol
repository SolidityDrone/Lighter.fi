// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Math.sol";

interface AggregatorV3Interface {
    function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract DataConsumerV3 {
    
    address[] feedList = 
        [
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada,     // matic Aggregator                       
            0x1C2252aeeD50e0c9B64bDfF2735Ee3C932F5C408,     // link  Aggregator              
            0x0715A7794a1dc8e42615F059dD6e406A6594651A      // eth   Aggregator   
        ];
    
    constructor() {}

    uint internal addressMappinglength;
    mapping(address=>uint) public tokenIndexes;
    mapping(address=>bool) public tokenAllowed;

    /**
    * @dev Maps unique addresses to their respective indexes in the `tokenIndexes` mapping.
    * @param tokenAddresses An array of Ethereum addresses to be mapped.
    */
    function mapAddresses(address[] calldata tokenAddresses) public {
        for (uint i; i < tokenAddresses.length; ){
            if (tokenIndexes[tokenAddresses[i]] == 0){
                tokenIndexes[tokenAddresses[i]] = addressMappinglength;
                tokenAllowed[tokenAddresses[i]] = true;
                unchecked{
                    ++addressMappinglength;
                } 
            }
            unchecked{
                ++i;
            }
        }
    } 

    /**
    * @dev Internal function to batch query price data from multiple data feeds.
    * @return prices An array of price values retrieved from data feeds.
    */
    function _batchQuery() internal  view  returns (uint[] memory){
        uint length = feedList.length;
        uint[] memory prices = new uint[](length);

        for (uint i; i < length; ){
            prices[i] = reseizeDecimals(getChainlinkDataFeedLatestAnswer(feedList[i]));
            unchecked{
                ++i;
            }
        }
        return (prices);
    }

    /**
    * @dev Internal function to resize price values from 8 to 6 decimals.
    * @param price The price value to be resized.
    * @return The resized price value.
    */
    function reseizeDecimals(int price) internal pure returns (uint){
        // reseize from 8 to 6 decimals
        return (uint(price) / 100);
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer(address feedAddress) public view returns (int) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(feedAddress).latestRoundData();
        return answer;
    }
}


interface IDCA {
    struct UserStrategy {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 timeInterval;
        uint256 nextExecution;
        uint256 amount;
        uint256 limit;
        bytes lastResponse;
    }
    
    error NotAllowedCaller(
        address caller,
        address owner,
        address automationRegistry
    );

    event NewUserStrategy(address indexed user, UserStrategy userStrategy, uint256 strategyIndex);
    event RemovedUserStrategy(address indexed user, uint256 strategyIndex);
    event UpdatedUserStrategy(address indexed user, UserStrategy userStrategy, uint256 strategyIndex);
    event RequestReceived(bytes32 indexed requestId , uint256 strategyIndex);
    event Response(bytes32 indexed requestId, bytes response, bytes err);
    event SwapExecuted(bytes32 indexed requestId, uint256 strategyIndex, uint256 amountIn, address user, address tokenIn, address tokenOut);
}

struct Log {
    uint256 index; // Index of the log in the block
    uint256 timestamp; // Timestamp of the block containing the log
    bytes32 txHash; // Hash of the transaction containing the log
    uint256 blockNumber; // Number of the block containing the log
    bytes32 blockHash; // Hash of the block containing the log
    address source; // Address of the contract that emitted the log
    bytes32[] topics; // Indexed topics of the log
    bytes data; // Data of the log
}

interface ILogAutomation {
    function checkLog(
        Log calldata log,
        bytes memory checkData
    ) external returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
}

interface IGenericSwapFacet  {
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }
    
    function swapTokensGeneric(
        bytes32 _transactionId,
        string calldata _integrator,
        string calldata _referrer,
        address payable _receiver,
        uint256 _minAmount,
        SwapData[] calldata _swapData
    ) external payable;
}

contract LighterFi is FunctionsClient, ConfirmedOwner, IDCA, ILogAutomation, AutomationCompatibleInterface, DataConsumerV3 {
    
    using FunctionsRequest for FunctionsRequest.Request;

    uint256 public s_usersStrategiesLength;
    bytes32 public donID;
    uint32 public gasLimit;
    uint private constant ADDRESS_LENGTH = 20;
    address public upkeepContract1;
    uint64 public subscriptionId;
    address public upkeepContract2;
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint256 public strategyIndex;
    address public usdcAddress;
    bool public isPaused;
    bool public isInitialized;
    
    mapping(uint256=>UserStrategy) public s_usersStrategies;
    mapping(bytes32=>uint256) public requestsIds;
    /**@dev Interface for generic_swap function in LiFi's diamond facet*/
    IGenericSwapFacet public genericSwapFacet; 
    /**@dev Hardcoded address to LiFi Diamond contract*/
    address public immutable lifiDiamond = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE;
    
    /**@dev Integrator string using lifi-api*/
    string public  integrator = 'lifi-api';
    /**@dev referrer string using lifi-api*/
    string public  referrer = '0x0000000000000000000000000000000000000000';

    /**@dev source string for Chainlink Function call*/
    string source = 
        "const fC= 'pol';"
        "const fT=args[0];"
        "const tT=args[1];"
        "const fAd=args[2];"
        "const fAm=args[3];"
        "const lRUrl = `https://li.quest/v1/quote?fromChain=${fC}&toChain=${fC}&fromToken=${fT}&toToken=${tT}&fromAddress=${fAd}&fromAmount=${fAm}`;"
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
        usdcAddress = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
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
        require(!isInitialized, "already initialized");
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
    function setAutomationCronContract(address _upkeepContract1, address _upkeepContract2) external onlyOwner {
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
        
        // Requirements for minimum timeInterval 
        // Requirements for minimum limit (in $)
        uint nextExecution;
        if (timeInterval > 0) {
            nextExecution = block.timestamp + timeInterval; 
        } else {
            require(tokenAllowed[tokenFrom]);
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
    * @return The index of the removed strategy.
    * @notice Only the user who created the strategy can remove it.
    */
    function removeStrategy(uint256 index) external returns (uint256) {
        //index check
        require(index <= s_usersStrategiesLength, "Index out of bounds"); 
        //load UserStrategy from mapping mapping
        UserStrategy memory strategyToRemove = s_usersStrategies[index];
        //user check
        require(strategyToRemove.user == msg.sender, "Unauthorized");
        //delete UserStrategy struct in s_usersStrategies mapping
        delete s_usersStrategies[index];
        //emit RemovedUserStrategy event
        emit RemovedUserStrategy(msg.sender, index);
        //return index
        return(index);
    }

    /**
    * @dev Upgrade an existing user strategy with new parameters.
    * @param index The index of the user strategy to be upgraded.
    * @param tokenTo The new address of the token to receive in the strategy.
    * @param timeInterval The new time interval between strategy executions, in seconds.
    * @param amountTokenIn The new amount of input tokens for the strategy.
    * @return The index of the upgraded strategy.
    * @notice Only the user who created the strategy can upgrade it.
    */
    function upgradeStrategy(uint256 index, address tokenFrom, address tokenTo, uint256 timeInterval, uint256 amountTokenIn, uint256 limit) external returns (uint256) {
        //parameters check
        require(amountTokenIn !=0, "invalid strategy params");
        require(tokenAllowed[tokenTo], "invalid strategy param tokenTo");
        require(timeInterval == 0 || limit == 0, "Either set a timeInterval or Limit");
        require(tokenFrom != tokenTo, "invalid strtagy param: tokens are equal");
        //index check
        require(index <= s_usersStrategiesLength, "Index out of bounds");
        //load UserStrategy from mapping mapping
        UserStrategy storage strategyToUpdate = s_usersStrategies[index];
        //user check
        require(strategyToUpdate.user == msg.sender, "Unauthorized");
        uint nextExecution;
        if (timeInterval > 0) {
            nextExecution = block.timestamp + timeInterval; 
        } else if (limit > 0) {
            require(tokenAllowed[tokenFrom]);
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
        //return index
        return(index);
    }

    /**
    * @dev checkUpkeep function called off-chain by Chainlink Automation infrastructure
    * @dev It checks for any s_usersStrategies if they are executable (timeCondition, balanceCondition and allowanceCondition)
    * @return upkeepNeeded A boolean indicating whether upkeep is needed.
    * @return performData The performData parameter triggering the performUpkeep
    * @notice This function is external, view, and implements the Upkeep interface.
    */
    function checkUpkeep(bytes calldata ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        
        uint[] memory prices = _batchQuery();
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
                    // balanceCondition = IERC20(usdcAddress).balanceOf(strategy.user) >= strategy.amount;
                    // allowanceCondition = IERC20(usdcAddress).allowance(strategy.user, address(this)) >= strategy.amount;
                    upkeepNeeded = timeCondition/* && balanceCondition && allowanceCondition*/;
                    performData = abi.encode(i, uint(0));
                 
                }  
                // Limit
                if (strategy.timeInterval == 0 && strategy.limit != 0) {
                    //buy only if the token price is <= the limit set
                    //sell only if the token price is >= the limit set
                    limitCondition = strategy.tokenIn == usdcAddress ? prices[tokenIndexes[strategy.tokenOut]] <= strategy.limit : prices[tokenIndexes[strategy.tokenIn]] >= strategy.limit;
                    // balanceCondition = IERC20(strategy.tokenIn).balanceOf(strategy.user) >= strategy.amount;
                    // allowanceCondition = IERC20(strategy.tokenIn).allowance(strategy.user, address(this)) >= strategy.amount;
                    upkeepNeeded = limitCondition /*&& balanceCondition && allowanceCondition*/;
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
        if(log.topics[2] != hex'00') {
            upkeepNeeded = false;
        }

        upkeepNeeded = true;
        performData = abi.encode(log.topics[0], uint(1));
    }

    function emitLog() public {
        emit Response(bytes32(0), hex'00', hex'00');
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
            //readResponseAndSwap(strategy.lastResponse, strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut); //(bytes memory data, uint amountIn, address receiver,  address tokenFrom, address tokenTo)
            //if it's a limit order operation it must be deleted after its execution
            if(strategy.limit>0) {
                //delete UserStrategy struct in s_usersStrategies mapping
                delete s_usersStrategies[index];
                //emit RemovedUserStrategy event
                emit RemovedUserStrategy(msg.sender, index);
            }
            emit SwapExecuted(requestId, index, strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
        }
    }

    /**
     * @notice Sends an HTTP request using Chainlink Functions infrastructure
     * @param index the index of the user strategy containing the data to pass to the LIFI API call.
     */
    function sendRequest(uint256 index) internal {
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
        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
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
    ) internal override {
    
        // Update the contract's state variables with the response and any errors
        uint256 index = requestsIds[requestId];
        //load UserStrategy from mapping mapping
        s_usersStrategies[index].lastResponse = response;
        // Emit an event to log the response
        emit Response(requestId, response, err);
    }

    /**
    * @dev Reads the response data and initiates a token swap operation.
    * @param data The response data containing information about the swap.
    * @param amountIn The amount of tokens to be sent in the swap.
    * @param receiver The address to receive the swapped tokens.
    * @param tokenFrom The address of the asset to be sent in the swap.
    * @param tokenTo The address of the asset to be received in the swap.
    *
    * This function unpacks the provided response data using the internal `unpackBytes` function.
    * It constructs the path array for the swap operation, including tokenFrom, middleTokens, and tokenTo.
    * The calldata for the swap is then generated using the internal `ConcatCalldata` function.
    * Finally, the swap operation is initiated using the internal `swap` function, passing relevant parameters.
    */
    function readResponseAndSwap(bytes memory data, uint amountIn, address receiver,  address tokenFrom, address tokenTo) public {
        // require(msg.sender == upkeep), "Only Chainlink Upkeep");
        (   
            bytes32[2] memory properties,
            bytes16[1] memory minOut,
            address[] memory middleTokens, 
            bytes4[1] memory routerSelector
        ) = unpackBytes(data);
        
        address[] memory path = new address[](2+middleTokens.length);
        path[0] = tokenFrom;
     
        for (uint i; i < middleTokens.length; ){
            unchecked{
                path[i+1] = middleTokens[i];
                ++i;
            }
        }
        path[path.length-1] = tokenTo;        
        bytes memory concatCalldata = ConcatCalldata(amountIn, minOut[0], path, routerSelector[0]);
        address routerAddress = address(uint160(uint256(properties[1])));
        uint amountInAntiStack = amountIn;
        swap(properties[0], payable(receiver), uint256(uint128(minOut[0])), routerAddress, routerAddress, tokenFrom, tokenTo, amountInAntiStack, concatCalldata);
    }

    /**
    * @dev Executes LiFI's token swap operation based on provided parameters.
    * @param _transactionId The unique identifier for the swap transaction.
    * @param _receiver The address to receive the swapped tokens.
    * @param _minAmount The minimum amount expected to be received from the swap.
    * @param _callTo The target contract to call for the swap.
    * @param _approveTo The address to approve token spending (if necessary) before the swap.
    * @param _sendingAssetId The address of the asset to be sent in the swap.
    * @param _receivingAssetId The address of the asset to be received in the swap.
    * @param _fromAmount The amount of tokens to be sent in the swap.
    * @param _calldata The calldata to be used in the swap function call.
    */
    function swap(
        bytes32 _transactionId,
        address payable _receiver,
        uint256 _minAmount,
        address _callTo,
        address _approveTo,
        address _sendingAssetId, 
        address _receivingAssetId,
        uint256 _fromAmount,
        bytes memory _calldata
        ) internal {
        IGenericSwapFacet.SwapData[] memory _swapData = new IGenericSwapFacet.SwapData[](1);
        _swapData[0].callTo = _callTo;
        _swapData[0].approveTo = _approveTo;
        _swapData[0].sendingAssetId = _sendingAssetId;
        _swapData[0].receivingAssetId = _receivingAssetId;
        _swapData[0].fromAmount = _fromAmount;
        _swapData[0].callData = _calldata;
        _swapData[0].requiresDeposit = true;

        genericSwapFacet.swapTokensGeneric(
            _transactionId,
            integrator,
            referrer, 
            _receiver,
            _minAmount,
            _swapData
            );
    }

    /**
    * @dev Unpacks the provided LiFi byte data from the Chainlink functions call into structured variables.
    * @param data The byte data to be unpacked.
    * @return properties An array of two 32-byte properties extracted from the input data.
    * @return minAmount A single 16-byte minAmount extracted from the input data.
    * @return middleTokenDynamic An array of non-zero Ethereum addresses extracted from the input data.
    * @return routerSelector A 4-byte router function selector extracted from the input data.
    *
    * The input data must be at least 72 bytes in length. The function extracts information such as
    * transaction ID, minimum amount, router address, router selector, and optional middle path tokens.
    * The extracted middle tokens are dynamically sized based on the number of non-zero addresses present.
    */
    function unpackBytes(bytes memory data) internal pure returns (bytes32[2] memory, bytes16[1] memory, address[] memory, bytes4[1] memory) {
        require(data.length >= 72, "Data length must be >= 72!");

        bytes32[2] memory properties;
        bytes16[1] memory minAmount;
        address[2] memory middleTokens;
        bytes4[1] memory routerSelector;
        assembly {
            // Store transactionID
            mstore(properties, mload(add(data, 32)))
            // Store minAmount
            mstore(minAmount, mload(add(data, 64)))
            // Store router address
            let addressRouter := mload(add(data, 80))
            mstore(add(properties, 32), shr(96, addressRouter))
            // Store router selector 
            mstore(routerSelector, mload(add(data, 100)))
        }
        if (data.length == 92) {
            assembly{
                mstore(middleTokens, mload(add(data,92)))
            }
        }
        if (data.length == 112) {
            assembly{
                mstore(middleTokens, mload(add(data,92)))
                mstore(add(middleTokens, 32), mload(add(data,112)))
            }
        }
        uint length;
        for (uint i; i<2; ){
            if (middleTokens[i] != (address(0))){
                ++length;
            }
            unchecked{
                ++i;
            }
        }
        address[] memory middleTokenDynamic = new address[](length);
        for (uint i; i<length; ){
            middleTokenDynamic[i] = middleTokens[i];
            unchecked{
                ++i;
            }
        }
        return (properties, minAmount, middleTokenDynamic, routerSelector);
    }
    
    /**
    * @dev Concatenates the input parameters into a calldata structure to input into Swapdata.callData
    * @param amountIn The amount to be processed in the function.
    * @param minAmount The minimum amount specified in the function.
    * @param path An array of addresses representing the token path.
    * @param routerSelector The 4-byte router selector for the function.
    * @return bytes array containing the concatenated calldata structure.
    *
    * This function combines the provided parameters into a calldata structure suitable for lifi
    * Swapdata.callData. The calldata structure includes the method signature, amountIn, minAmount, constant,
    * contract address, router selector, hops counter, and the dynamically sized path array.
    * The path array is structured as tokenFrom, middleToken1, middleToken2, tokenTo.
    * 
    */
    function ConcatCalldata(
            uint amountIn,
            bytes16 minAmount,
            address[] memory path,
            bytes4 routerSelector
        ) internal view returns (bytes memory){
        bytes4 methodSig = 0x38ed1739;
        bytes32 const = 0x00000000000000000000000000000000000000000000000000000000000000a0;
        uint   hopsCounter;
        bytes memory pathBytes;
        // need to structure array in  tokenFrom, middletoken1, middletoken2, tokenTo
        for (uint i; i<path.length; ){
            if (path[i] != address(0)){
                pathBytes = abi.encodePacked(pathBytes, addressToBytes32(path[i]));
                ++hopsCounter;
            }
            ++i;
        } pathBytes = abi.encodePacked(pathBytes, bytes28(0));
        return abi.encodePacked(
            methodSig,
            bytes32(amountIn),
            bytes32(abi.encodePacked(bytes16(0), bytes16(minAmount))), 
            const,
            addressToBytes32(lifiDiamond), 
            bytes32(abi.encodePacked(bytes28(0), routerSelector)),
            bytes32(hopsCounter),
            pathBytes
            );
    }


    /**
    * @dev Generates arguments for a request, converting token and user addresses, and amount to strings.
    * @param _tokenFrom The address of the tokenFrom.
    * @param _tokenTo The address of the tokenTo.
    * @param user The user's address.
    * @param amount The amount of the token as a uint256.
    * @return An array of strings representing the converted token address, user address, and amount.
    * @notice This function is internal and pure, meaning it does not modify state and can only be called within the contract.
    */
    function generateArgForRequest(address _tokenFrom, address _tokenTo, address user, uint256 amount) internal pure returns(string[] memory) {
        string memory tokenFrom = addressToString(abi.encodePacked(_tokenFrom));
        string memory tokenTo = addressToString(abi.encodePacked(_tokenTo));
        string memory fromAddress = addressToString(abi.encodePacked(user));
        string memory fromAmount = uintToString(amount);

        string[] memory result = new string[](4);
        result[0] = tokenFrom;
        result[1] = tokenTo;
        result[2] = fromAddress;
        result[3] = fromAmount;
        return result;
    }

    /**
    * @dev Converts an Ethereum address to a bytes32 representation.
    * @param addr The Ethereum address to be converted.
    * @return bytes32 representation of the input Ethereum address.
    */
    function addressToBytes32(address addr) internal pure returns (bytes32){
        return bytes32(uint256(uint160(addr)));
    }

    /**
    * @dev Converts a uint256 value to a bytes32 representation.
    * @param u256 The uint256 value to be converted.
    * @return bytes32 representation of the input uint256 value.
    */
    function uintToBytes32(uint256 u256) internal pure returns (bytes32) {
        // Convert uint256 to bytes32
        bytes32 properties;
        assembly {
            properties := u256
        }
        return properties;
    }
    
    /**
    * @dev Converts a uint256 value to a bytes32 representation.
    * @param b32 The uint256 value to be converted.
    * @return bytes32 representation of the input uint256 value.
    */
    function bytes32tobytes4(bytes32 b32) internal pure returns(bytes4){
        return (bytes4(b32));
    }


    /**
    * @dev Converts a bytes representation of an address to a string.
    * @param data The bytes representation of an address.
    * @return The address as a hexadecimal string.
    * @notice This function is internal and pure, meaning it does not modify state and can only be called within the contract.
    */
    function addressToString(bytes memory data) internal pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }


    /**
    * @dev Converts a uint256 value to a string.
    * @param value The uint256 value to be converted.
    * @return The uint256 value as a string.
    * @notice This function is internal and pure, meaning it does not modify state and can only be called within the contract.
    */
    function uintToString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
}
