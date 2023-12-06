
pragma solidity ^0.8.19;

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

    uint public addressMappinglength;
    mapping(address=>uint) public tokenIndexes;
    mapping(address=>bool) public tokenAllowed;

    /**
    * @dev Maps unique addresses to their respective indexes in the `tokenIndexes` mapping.
    * @param tokenAddresses An array of Ethereum addresses to be mapped.
    */
    function _mapAddresses(address[] calldata tokenAddresses) public {
        for (uint i; i < tokenAddresses.length; ){
            if (tokenAllowed[tokenAddresses[i]] == false){
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
    function _batchQuery(int fuzz) public view  returns (uint[] memory){
        uint length = feedList.length;
        uint[] memory prices = new uint[](length);

        for (uint i; i < length; ){
            prices[i] = reseizeDecimals(getChainlinkDataFeedLatestAnswer(feedList[i], fuzz));
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
    function reseizeDecimals(int price) public pure returns (uint){
        // reseize from 8 to 6 decimals
        return (uint(price) / 100);
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer(address feedAddress, int answer) public view returns (int) {
        return answer;
    }
}
