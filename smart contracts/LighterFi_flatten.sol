// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


/// @title Library of types that are used for fulfillment of a Functions request
library FunctionsResponse {
  // Used to send request information from the Router to the Coordinator
  struct RequestMeta {
    bytes data; // ══════════════════╸ CBOR encoded Chainlink Functions request data, use FunctionsRequest library to encode a request
    bytes32 flags; // ═══════════════╸ Per-subscription flags
    address requestingContract; // ══╗ The client contract that is sending the request
    uint96 availableBalance; // ═════╝ Common LINK balance of the subscription that is controlled by the Router to be used for all consumer requests.
    uint72 adminFee; // ═════════════╗ Flat fee (in Juels of LINK) that will be paid to the Router Owner for operation of the network
    uint64 subscriptionId; //        ║ Identifier of the billing subscription that will be charged for the request
    uint64 initiatedRequests; //     ║ The number of requests that have been started
    uint32 callbackGasLimit; //      ║ The amount of gas that the callback to the consuming contract will be given
    uint16 dataVersion; // ══════════╝ The version of the structure of the CBOR encoded request data
    uint64 completedRequests; // ════╗ The number of requests that have successfully completed or timed out
    address subscriptionOwner; // ═══╝ The owner of the billing subscription
  }

  enum FulfillResult {
    FULFILLED, // 0
    USER_CALLBACK_ERROR, // 1
    INVALID_REQUEST_ID, // 2
    COST_EXCEEDS_COMMITMENT, // 3
    INSUFFICIENT_GAS_PROVIDED, // 4
    SUBSCRIPTION_BALANCE_INVARIANT_VIOLATION, // 5
    INVALID_COMMITMENT // 6
  }

  struct Commitment {
    bytes32 requestId; // ═════════════════╸ A unique identifier for a Chainlink Functions request
    address coordinator; // ═══════════════╗ The Coordinator contract that manages the DON that is servicing a request
    uint96 estimatedTotalCostJuels; // ════╝ The maximum cost in Juels (1e18) of LINK that will be charged to fulfill a request
    address client; // ════════════════════╗ The client contract that sent the request
    uint64 subscriptionId; //              ║ Identifier of the billing subscription that will be charged for the request
    uint32 callbackGasLimit; // ═══════════╝ The amount of gas that the callback to the consuming contract will be given
    uint72 adminFee; // ═══════════════════╗ Flat fee (in Juels of LINK) that will be paid to the Router Owner for operation of the network
    uint72 donFee; //                      ║ Fee (in Juels of LINK) that will be split between Node Operators for servicing a request
    uint40 gasOverheadBeforeCallback; //   ║ Represents the average gas execution cost before the fulfillment callback.
    uint40 gasOverheadAfterCallback; //    ║ Represents the average gas execution cost after the fulfillment callback.
    uint32 timeoutTimestamp; // ═══════════╝ The timestamp at which a request will be eligible to be timed out
  }
}

/// @title Chainlink Functions Router interface.
interface IFunctionsRouter {
  /// @notice The identifier of the route to retrieve the address of the access control contract
  /// The access control contract controls which accounts can manage subscriptions
  /// @return id - bytes32 id that can be passed to the "getContractById" of the Router
  function getAllowListId() external view returns (bytes32);

  /// @notice Set the identifier of the route to retrieve the address of the access control contract
  /// The access control contract controls which accounts can manage subscriptions
  function setAllowListId(bytes32 allowListId) external;

  /// @notice Get the flat fee (in Juels of LINK) that will be paid to the Router owner for operation of the network
  /// @return adminFee
  function getAdminFee() external view returns (uint72 adminFee);

  /// @notice Sends a request using the provided subscriptionId
  /// @param subscriptionId - A unique subscription ID allocated by billing system,
  /// a client can make requests from different contracts referencing the same subscription
  /// @param data - CBOR encoded Chainlink Functions request data, use FunctionsClient API to encode a request
  /// @param dataVersion - Gas limit for the fulfillment callback
  /// @param callbackGasLimit - Gas limit for the fulfillment callback
  /// @param donId - An identifier used to determine which route to send the request along
  /// @return requestId - A unique request identifier
  function sendRequest(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external returns (bytes32);

  /// @notice Sends a request to the proposed contracts
  /// @param subscriptionId - A unique subscription ID allocated by billing system,
  /// a client can make requests from different contracts referencing the same subscription
  /// @param data - CBOR encoded Chainlink Functions request data, use FunctionsClient API to encode a request
  /// @param dataVersion - Gas limit for the fulfillment callback
  /// @param callbackGasLimit - Gas limit for the fulfillment callback
  /// @param donId - An identifier used to determine which route to send the request along
  /// @return requestId - A unique request identifier
  function sendRequestToProposed(
    uint64 subscriptionId,
    bytes calldata data,
    uint16 dataVersion,
    uint32 callbackGasLimit,
    bytes32 donId
  ) external returns (bytes32);

  /// @notice Fulfill the request by:
  /// - calling back the data that the Oracle returned to the client contract
  /// - pay the DON for processing the request
  /// @dev Only callable by the Coordinator contract that is saved in the commitment
  /// @param response response data from DON consensus
  /// @param err error from DON consensus
  /// @param juelsPerGas - current rate of juels/gas
  /// @param costWithoutFulfillment - The cost of processing the request (in Juels of LINK ), without fulfillment
  /// @param transmitter - The Node that transmitted the OCR report
  /// @param commitment - The parameters of the request that must be held consistent between request and response time
  /// @return fulfillResult -
  /// @return callbackGasCostJuels -
  function fulfill(
    bytes memory response,
    bytes memory err,
    uint96 juelsPerGas,
    uint96 costWithoutFulfillment,
    address transmitter,
    FunctionsResponse.Commitment memory commitment
  ) external returns (FunctionsResponse.FulfillResult, uint96);

  /// @notice Validate requested gas limit is below the subscription max.
  /// @param subscriptionId subscription ID
  /// @param callbackGasLimit desired callback gas limit
  function isValidCallbackGasLimit(uint64 subscriptionId, uint32 callbackGasLimit) external view;

  /// @notice Get the current contract given an ID
  /// @param id A bytes32 identifier for the route
  /// @return contract The current contract address
  function getContractById(bytes32 id) external view returns (address);

  /// @notice Get the proposed next contract given an ID
  /// @param id A bytes32 identifier for the route
  /// @return contract The current or proposed contract address
  function getProposedContractById(bytes32 id) external view returns (address);

  /// @notice Return the latest proprosal set
  /// @return ids The identifiers of the contracts to update
  /// @return to The addresses of the contracts that will be updated to
  function getProposedContractSet() external view returns (bytes32[] memory, address[] memory);

  /// @notice Proposes one or more updates to the contract routes
  /// @dev Only callable by owner
  function proposeContractsUpdate(bytes32[] memory proposalSetIds, address[] memory proposalSetAddresses) external;

  /// @notice Updates the current contract routes to the proposed contracts
  /// @dev Only callable by owner
  function updateContracts() external;

  /// @dev Puts the system into an emergency stopped state.
  /// @dev Only callable by owner
  function pause() external;

  /// @dev Takes the system out of an emergency stopped state.
  /// @dev Only callable by owner
  function unpause() external;
}

/// @title Chainlink Functions client interface.
interface IFunctionsClient {
  /// @notice Chainlink Functions response handler called by the Functions Router
  /// during fullilment from the designated transmitter node in an OCR round.
  /// @param requestId The requestId returned by FunctionsClient.sendRequest().
  /// @param response Aggregated response from the request's source code.
  /// @param err Aggregated error either from the request's source code or from the execution pipeline.
  /// @dev Either response or error parameter will be set, but never both.
  function handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err) external;
}

/**
* @dev A library for working with mutable byte buffers in Solidity.
*
* Byte buffers are mutable and expandable, and provide a variety of primitives
* for appending to them. At any time you can fetch a bytes object containing the
* current contents of the buffer. The bytes object should not be stored between
* operations, as it may change due to resizing of the buffer.
*/
library Buffer {
    /**
    * @dev Represents a mutable buffer. Buffers have a current value (buf) and
    *      a capacity. The capacity may be longer than the current value, in
    *      which case it can be extended without the need to allocate more memory.
    */
    struct buffer {
        bytes buf;
        uint capacity;
    }

    /**
    * @dev Initializes a buffer with an initial capacity.
    * @param buf The buffer to initialize.
    * @param capacity The number of bytes of space to allocate the buffer.
    * @return The buffer, for chaining.
    */
    function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            let fpm := add(32, add(ptr, capacity))
            if lt(fpm, ptr) {
                revert(0, 0)
            }
            mstore(0x40, fpm)
        }
        return buf;
    }

    /**
    * @dev Initializes a new buffer from an existing bytes object.
    *      Changes to the buffer may mutate the original value.
    * @param b The bytes object to initialize the buffer with.
    * @return A new buffer.
    */
    function fromBytes(bytes memory b) internal pure returns(buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    /**
    * @dev Sets buffer length to 0.
    * @param buf The buffer to truncate.
    * @return The original buffer, for chaining..
    */
    function truncate(buffer memory buf) internal pure returns (buffer memory) {
        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }

    /**
    * @dev Appends len bytes of a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to copy.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data, uint len) internal pure returns(buffer memory) {
        require(len <= data.length);

        uint off = buf.buf.length;
        uint newCapacity = off + len;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint dest;
        uint src;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + offset + sizeof(buffer length)
            dest := add(add(bufptr, 32), off)
            // Update buffer length if we're extending it
            if gt(newCapacity, buflen) {
                mstore(bufptr, newCapacity)
            }
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        unchecked {
            uint mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }

        return buf;
    }

    /**
    * @dev Appends a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
        return append(buf, data, data.length);
    }

    /**
    * @dev Appends a byte to the buffer. Resizes if doing so would exceed the
    *      capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint offPlusOne = off + 1;
        if (off >= buf.capacity) {
            resize(buf, offPlusOne * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + off
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            // Update buffer length if we extended it
            if gt(offPlusOne, mload(bufptr)) {
                mstore(bufptr, offPlusOne)
            }
        }

        return buf;
    }

    /**
    * @dev Appends len bytes of bytes32 to a buffer. Resizes if doing so would
    *      exceed the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to write (left-aligned).
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes32 data, uint len) private pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        unchecked {
            uint mask = (256 ** len) - 1;
            // Right-align data
            data = data >> (8 * (32 - len));
            assembly {
                // Memory address of the buffer data
                let bufptr := mload(buf)
                // Address = buffer address + sizeof(buffer length) + newCapacity
                let dest := add(bufptr, newCapacity)
                mstore(dest, or(and(mload(dest), not(mask)), data))
                // Update buffer length if we extended it
                if gt(newCapacity, mload(bufptr)) {
                    mstore(bufptr, newCapacity)
                }
            }
        }
        return buf;
    }

    /**
    * @dev Appends a bytes20 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chhaining.
    */
    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
        return append(buf, bytes32(data), 20);
    }

    /**
    * @dev Appends a bytes32 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
        return append(buf, data, 32);
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     *      exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @param len The number of bytes to write (right-aligned).
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint mask = (256 ** len) - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + newCapacity
            let dest := add(bufptr, newCapacity)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length if we extended it
            if gt(newCapacity, mload(bufptr)) {
                mstore(bufptr, newCapacity)
            }
        }
        return buf;
    }
}

/**
* @dev A library for populating CBOR encoded payload in Solidity.
*
* https://datatracker.ietf.org/doc/html/rfc7049
*
* The library offers various write* and start* methods to encode values of different types.
* The resulted buffer can be obtained with data() method.
* Encoding of primitive types is staightforward, whereas encoding of sequences can result
* in an invalid CBOR if start/write/end flow is violated.
* For the purpose of gas saving, the library does not verify start/write/end flow internally,
* except for nested start/end pairs.
*/

library CBOR {
    using Buffer for Buffer.buffer;

    struct CBORBuffer {
        Buffer.buffer buf;
        uint256 depth;
    }

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    uint8 private constant CBOR_FALSE = 20;
    uint8 private constant CBOR_TRUE = 21;
    uint8 private constant CBOR_NULL = 22;
    uint8 private constant CBOR_UNDEFINED = 23;

    function create(uint256 capacity) internal pure returns(CBORBuffer memory cbor) {
        Buffer.init(cbor.buf, capacity);
        cbor.depth = 0;
        return cbor;
    }

    function data(CBORBuffer memory buf) internal pure returns(bytes memory) {
        require(buf.depth == 0, "Invalid CBOR");
        return buf.buf.buf;
    }

    function writeUInt256(CBORBuffer memory buf, uint256 value) internal pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
        writeBytes(buf, abi.encode(value));
    }

    function writeInt256(CBORBuffer memory buf, int256 value) internal pure {
        if (value < 0) {
            buf.buf.appendUint8(
                uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM)
            );
            writeBytes(buf, abi.encode(uint256(-1 - value)));
        } else {
            writeUInt256(buf, uint256(value));
        }
    }

    function writeUInt64(CBORBuffer memory buf, uint64 value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_INT, value);
    }

    function writeInt64(CBORBuffer memory buf, int64 value) internal pure {
        if(value >= 0) {
            writeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
        } else{
            writeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(-1 - value));
        }
    }

    function writeBytes(CBORBuffer memory buf, bytes memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
        buf.buf.append(value);
    }

    function writeString(CBORBuffer memory buf, string memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
        buf.buf.append(bytes(value));
    }

    function writeBool(CBORBuffer memory buf, bool value) internal pure {
        writeContentFree(buf, value ? CBOR_TRUE : CBOR_FALSE);
    }

    function writeNull(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_NULL);
    }

    function writeUndefined(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_UNDEFINED);
    }

    function startArray(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
        buf.depth += 1;
    }

    function startFixedArray(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_ARRAY, length);
    }

    function startMap(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
        buf.depth += 1;
    }

    function startFixedMap(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_MAP, length);
    }

    function endSequence(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
        buf.depth -= 1;
    }

    function writeKVString(CBORBuffer memory buf, string memory key, string memory value) internal pure {
        writeString(buf, key);
        writeString(buf, value);
    }

    function writeKVBytes(CBORBuffer memory buf, string memory key, bytes memory value) internal pure {
        writeString(buf, key);
        writeBytes(buf, value);
    }

    function writeKVUInt256(CBORBuffer memory buf, string memory key, uint256 value) internal pure {
        writeString(buf, key);
        writeUInt256(buf, value);
    }

    function writeKVInt256(CBORBuffer memory buf, string memory key, int256 value) internal pure {
        writeString(buf, key);
        writeInt256(buf, value);
    }

    function writeKVUInt64(CBORBuffer memory buf, string memory key, uint64 value) internal pure {
        writeString(buf, key);
        writeUInt64(buf, value);
    }

    function writeKVInt64(CBORBuffer memory buf, string memory key, int64 value) internal pure {
        writeString(buf, key);
        writeInt64(buf, value);
    }

    function writeKVBool(CBORBuffer memory buf, string memory key, bool value) internal pure {
        writeString(buf, key);
        writeBool(buf, value);
    }

    function writeKVNull(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeNull(buf);
    }

    function writeKVUndefined(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeUndefined(buf);
    }

    function writeKVMap(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startMap(buf);
    }

    function writeKVArray(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startArray(buf);
    }

    function writeFixedNumeric(
        CBORBuffer memory buf,
        uint8 major,
        uint64 value
    ) private pure {
        if (value <= 23) {
            buf.buf.appendUint8(uint8((major << 5) | value));
        } else if (value <= 0xFF) {
            buf.buf.appendUint8(uint8((major << 5) | 24));
            buf.buf.appendInt(value, 1);
        } else if (value <= 0xFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 25));
            buf.buf.appendInt(value, 2);
        } else if (value <= 0xFFFFFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 26));
            buf.buf.appendInt(value, 4);
        } else {
            buf.buf.appendUint8(uint8((major << 5) | 27));
            buf.buf.appendInt(value, 8);
        }
    }

    function writeIndefiniteLengthType(CBORBuffer memory buf, uint8 major)
        private
        pure
    {
        buf.buf.appendUint8(uint8((major << 5) | 31));
    }

    function writeDefiniteLengthType(CBORBuffer memory buf, uint8 major, uint64 length)
        private
        pure
    {
        writeFixedNumeric(buf, major, length);
    }

    function writeContentFree(CBORBuffer memory buf, uint8 value) private pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_CONTENT_FREE << 5) | value));
    }
}

/// @title Library for encoding the input data of a Functions request into CBOR
library FunctionsRequest {
  using CBOR for CBOR.CBORBuffer;

  uint16 public constant REQUEST_DATA_VERSION = 1;
  uint256 internal constant DEFAULT_BUFFER_SIZE = 256;

  enum Location {
    Inline, // Provided within the Request
    Remote, // Hosted through remote location that can be accessed through a provided URL
    DONHosted // Hosted on the DON's storage
  }

  enum CodeLanguage {
    JavaScript
    // In future version we may add other languages
  }

  struct Request {
    Location codeLocation; // ════════════╸ The location of the source code that will be executed on each node in the DON
    Location secretsLocation; // ═════════╸ The location of secrets that will be passed into the source code. *Only Remote secrets are supported
    CodeLanguage language; // ════════════╸ The coding language that the source code is written in
    string source; // ════════════════════╸ Raw source code for Request.codeLocation of Location.Inline, URL for Request.codeLocation of Location.Remote, or slot decimal number for Request.codeLocation of Location.DONHosted
    bytes encryptedSecretsReference; // ══╸ Encrypted URLs for Request.secretsLocation of Location.Remote (use addSecretsReference()), or CBOR encoded slotid+version for Request.secretsLocation of Location.DONHosted (use addDONHostedSecrets())
    string[] args; // ════════════════════╸ String arguments that will be passed into the source code
    bytes[] bytesArgs; // ════════════════╸ Bytes arguments that will be passed into the source code
  }

  error EmptySource();
  error EmptySecrets();
  error EmptyArgs();
  error NoInlineSecrets();

  /// @notice Encodes a Request to CBOR encoded bytes
  /// @param self The request to encode
  /// @return CBOR encoded bytes
  function encodeCBOR(Request memory self) internal pure returns (bytes memory) {
    CBOR.CBORBuffer memory buffer = CBOR.create(DEFAULT_BUFFER_SIZE);

    buffer.writeString("codeLocation");
    buffer.writeUInt256(uint256(self.codeLocation));

    buffer.writeString("language");
    buffer.writeUInt256(uint256(self.language));

    buffer.writeString("source");
    buffer.writeString(self.source);

    if (self.args.length > 0) {
      buffer.writeString("args");
      buffer.startArray();
      for (uint256 i = 0; i < self.args.length; ++i) {
        buffer.writeString(self.args[i]);
      }
      buffer.endSequence();
    }

    if (self.encryptedSecretsReference.length > 0) {
      if (self.secretsLocation == Location.Inline) {
        revert NoInlineSecrets();
      }
      buffer.writeString("secretsLocation");
      buffer.writeUInt256(uint256(self.secretsLocation));
      buffer.writeString("secrets");
      buffer.writeBytes(self.encryptedSecretsReference);
    }

    if (self.bytesArgs.length > 0) {
      buffer.writeString("bytesArgs");
      buffer.startArray();
      for (uint256 i = 0; i < self.bytesArgs.length; ++i) {
        buffer.writeBytes(self.bytesArgs[i]);
      }
      buffer.endSequence();
    }

    return buffer.buf.buf;
  }

  /// @notice Initializes a Chainlink Functions Request
  /// @dev Sets the codeLocation and code on the request
  /// @param self The uninitialized request
  /// @param codeLocation The user provided source code location
  /// @param language The programming language of the user code
  /// @param source The user provided source code or a url
  function initializeRequest(
    Request memory self,
    Location codeLocation,
    CodeLanguage language,
    string memory source
  ) internal pure {
    if (bytes(source).length == 0) revert EmptySource();

    self.codeLocation = codeLocation;
    self.language = language;
    self.source = source;
  }

  /// @notice Initializes a Chainlink Functions Request
  /// @dev Simplified version of initializeRequest for PoC
  /// @param self The uninitialized request
  /// @param javaScriptSource The user provided JS code (must not be empty)
  function initializeRequestForInlineJavaScript(Request memory self, string memory javaScriptSource) internal pure {
    initializeRequest(self, Location.Inline, CodeLanguage.JavaScript, javaScriptSource);
  }

  /// @notice Adds Remote user encrypted secrets to a Request
  /// @param self The initialized request
  /// @param encryptedSecretsReference Encrypted comma-separated string of URLs pointing to off-chain secrets
  function addSecretsReference(Request memory self, bytes memory encryptedSecretsReference) internal pure {
    if (encryptedSecretsReference.length == 0) revert EmptySecrets();

    self.secretsLocation = Location.Remote;
    self.encryptedSecretsReference = encryptedSecretsReference;
  }

  /// @notice Adds DON-hosted secrets reference to a Request
  /// @param self The initialized request
  /// @param slotID Slot ID of the user's secrets hosted on DON
  /// @param version User data version (for the slotID)
  function addDONHostedSecrets(Request memory self, uint8 slotID, uint64 version) internal pure {
    CBOR.CBORBuffer memory buffer = CBOR.create(DEFAULT_BUFFER_SIZE);

    buffer.writeString("slotID");
    buffer.writeUInt64(slotID);
    buffer.writeString("version");
    buffer.writeUInt64(version);

    self.secretsLocation = Location.DONHosted;
    self.encryptedSecretsReference = buffer.buf.buf;
  }

  /// @notice Sets args for the user run function
  /// @param self The initialized request
  /// @param args The array of string args (must not be empty)
  function setArgs(Request memory self, string[] memory args) internal pure {
    if (args.length == 0) revert EmptyArgs();

    self.args = args;
  }

  /// @notice Sets bytes args for the user run function
  /// @param self The initialized request
  /// @param args The array of bytes args (must not be empty)
  function setBytesArgs(Request memory self, bytes[] memory args) internal pure {
    if (args.length == 0) revert EmptyArgs();

    self.bytesArgs = args;
  }
}

/// @title The Chainlink Functions client contract
/// @notice Contract developers can inherit this contract in order to make Chainlink Functions requests
abstract contract FunctionsClient is IFunctionsClient {
  using FunctionsRequest for FunctionsRequest.Request;

  IFunctionsRouter internal immutable i_router;

  event RequestSent(bytes32 indexed id);
  event RequestFulfilled(bytes32 indexed id);

  error OnlyRouterCanFulfill();

  constructor(address router) {
    i_router = IFunctionsRouter(router);
  }

  /// @notice Sends a Chainlink Functions request
  /// @param data The CBOR encoded bytes data for a Functions request
  /// @param subscriptionId The subscription ID that will be charged to service the request
  /// @param callbackGasLimit the amount of gas that will be available for the fulfillment callback
  /// @return requestId The generated request ID for this request
  function _sendRequest(
    bytes memory data,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    bytes32 donId
  ) internal returns (bytes32) {
    bytes32 requestId = i_router.sendRequest(
      subscriptionId,
      data,
      FunctionsRequest.REQUEST_DATA_VERSION,
      callbackGasLimit,
      donId
    );
    emit RequestSent(requestId);
    return requestId;
  }

  /// @notice User defined function to handle a response from the DON
  /// @param requestId The request ID, returned by sendRequest()
  /// @param response Aggregated response from the execution of the user's source code
  /// @param err Aggregated error from the execution of the user code or from the execution pipeline
  /// @dev Either response or error parameter will be set, but never both
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal virtual;

  /// @inheritdoc IFunctionsClient
  function handleOracleFulfillment(bytes32 requestId, bytes memory response, bytes memory err) external override {
    if (msg.sender != address(i_router)) {
      revert OnlyRouterCanFulfill();
    }
    fulfillRequest(requestId, response, err);
    emit RequestFulfilled(requestId);
  }
}


interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    // solhint-disable-next-line custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}



/**
 * @member index the index of the log in the block. 0 for the first log
 * @member timestamp the timestamp of the block containing the log
 * @member txHash the hash of the transaction containing the log
 * @member blockNumber the number of the block containing the log
 * @member blockHash the hash of the block containing the log
 * @member source the address of the contract that emitted the log
 * @member topics the indexed topics of the log
 * @member data the data of the log
 */
struct Log {
  uint256 index;
  uint256 timestamp;
  bytes32 txHash;
  uint256 blockNumber;
  bytes32 blockHash;
  address source;
  bytes32[] topics;
  bytes data;
}

interface ILogAutomation {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param log the raw log data matching the filter that this contract has
   * registered as a trigger
   * @param checkData user-specified extra data to provide context to this upkeep
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkLog(
    Log calldata log,
    bytes memory checkData
  ) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}


contract AutomationBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}





interface AggregatorV3Interface {
    function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract DataConsumerV3 {
    
    address[] feedList = 
        [
            0x0A77230d17318075983913bC2145DB16C7366156, //Avax
            0x49ccd9ca821EfEab2b98c60dC60F518E765EDe9a, //Link
            0x976B3D034E162d8bD72D6b9C989d545b839003b0, //Weth
            0x86442E3a98558357d46E6182F4b262f76c4fa26F, //Wbtc
            0x3CA13391E9fb38a75330fb28f8cc2eB3D9ceceED, //Aave
            0x449A373A090d8A1e5F74c63Ef831Ceff39E94563  //Sushi              
        ];
    
    constructor() {}

    uint internal addressMappinglength;
    mapping(address=>uint) public tokenIndexes;
    mapping(address=>bool) public tokenAllowed;

    /**
    * @dev Maps unique addresses to their respective indexes in the `tokenIndexes` mapping.
    * @param tokenAddresses An array of Ethereum addresses to be mapped.
    */
    function _mapAddresses(address[] calldata tokenAddresses) internal {
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
    function _batchQuery() public view  returns (uint[] memory){
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



interface ILighterFi {
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
    event SwapExecuted(bytes32 indexed requestId, uint256 strategyIndex, uint256 amountIn, uint256 amountOut, address user, address tokenIn, address tokenOut);
}



// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)



/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return a == 0 ? 0 : (a - 1) / b + 1;
        }
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}


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


contract LighterFi is FunctionsClient, ConfirmedOwner, ILighterFi, ILogAutomation, AutomationCompatibleInterface, DataConsumerV3, Swapper, Utils{
    
    using FunctionsRequest for FunctionsRequest.Request;

    uint256 internal s_usersStrategiesLength;
    bytes32 public donID;
    uint32  internal gasLimit;
    address public upkeepContract1;
    uint64  internal subscriptionId;
    address public upkeepContract2;

    uint256 internal strategyIndex;
    address internal usdcAddress;
    bool public isPaused;
    bool internal isInitialized;
    
    mapping(uint256=>UserStrategy) public s_usersStrategies;
    mapping(bytes32=>uint256) public requestsIds;
    
    /**@dev source string for Chainlink Function call*/
    string source = 
        "const fC= '43114';"
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
        // Requirements for minimum timeInterval 
        require(!(timeInterval == 0 && limit ==0), "Limit and TimeInterval are 0");
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
    function removeStrategy(uint256 index) external  {
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
    function upgradeStrategy(uint256 index, address tokenFrom, address tokenTo, uint256 timeInterval, uint256 amountTokenIn, uint256 limit) external {
        //parameters check
        require(amountTokenIn !=0, "invalid strategy param amount");
        require(tokenAllowed[tokenTo], "invalid strategy param tokenTo");
        require(tokenAllowed[tokenFrom], "invalid strategy param tokenFrom");
        require(timeInterval == 0 || limit == 0, "Either set a timeInterval or Limit");
        require(tokenFrom != tokenTo, "invalid strtagy param: tokens are equal");
        require(!(timeInterval == 0 && limit ==0), "Limit and TimeInterval are 0");
        
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
      
        upkeepNeeded = true;  
        performData = abi.encode(log.topics[1], uint(1));
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
            // approve LIFI contract to execute the swap
            IERC20(strategy.tokenIn).approve(lifiDiamond, strategy.amount);
            readResponseAndSwap(strategy.lastResponse, strategy.amount, strategy.user, strategy.tokenIn, strategy.tokenOut);
            // check token balance after swap execution
            uint finalBalance = IERC20(strategy.tokenOut).balanceOf(strategy.user) - startingBalance;
            emit SwapExecuted(requestId, index, strategy.amount, finalBalance, strategy.user, strategy.tokenIn, strategy.tokenOut);
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
        UserStrategy storage strategy = s_usersStrategies[index];
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

    function mapAddresses(address[] calldata tokenAddresses) onlyOwner() public {
        _mapAddresses(tokenAddresses);
    }
}
