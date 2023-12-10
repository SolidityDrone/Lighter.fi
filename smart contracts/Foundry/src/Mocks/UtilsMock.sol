pragma solidity ^0.8.0;
import "./Math.sol";


contract Utils {

    uint private constant ADDRESS_LENGTH = 20;
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";


       /**
    * @dev Generates arguments for a request, converting token and user addresses, and amount to strings.
    * @param _tokenFrom The address of the tokenFrom.
    * @param _tokenTo The address of the tokenTo.
    * @param user The user's address.
    * @param amount The amount of the token as a uint256.
    * @return An array of strings representing the converted token address, user address, and amount.
    * @notice This function is internal and pure, meaning it does not modify state and can only be called within the contract.
    */
    function generateArgForRequest(address _tokenFrom, address _tokenTo, address user, uint256 amount) public pure returns(string[] memory) {
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
    function uintToString(uint256 value) public pure returns (string memory) {
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