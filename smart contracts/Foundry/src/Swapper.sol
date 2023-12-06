// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



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


contract Swapper {
    /**@dev Interface for generic_swap function in LiFi's diamond facet*/
    IGenericSwapFacet internal genericSwapFacet; 
    /**@dev Hardcoded address to LiFi Diamond contract*/
    address internal immutable lifiDiamond = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE;
    
    /**@dev Integrator string using lifi-api*/
    string internal  integrator = "lifi-api";
    /**@dev referrer string using lifi-api*/
    string internal  referrer = "0x0000000000000000000000000000000000000000";

    constructor(){
        genericSwapFacet = IGenericSwapFacet(lifiDiamond);
 
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
    function readResponseAndSwap(bytes memory data, uint amountIn, address receiver,  address tokenFrom, address tokenTo) internal {
        
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
}
