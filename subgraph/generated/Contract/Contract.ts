// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt
} from "@graphprotocol/graph-ts";

export class NewUserStrategy extends ethereum.Event {
  get params(): NewUserStrategy__Params {
    return new NewUserStrategy__Params(this);
  }
}

export class NewUserStrategy__Params {
  _event: NewUserStrategy;

  constructor(event: NewUserStrategy) {
    this._event = event;
  }

  get user(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get userStrategy(): NewUserStrategyUserStrategyStruct {
    return changetype<NewUserStrategyUserStrategyStruct>(
      this._event.parameters[1].value.toTuple()
    );
  }

  get strategyIndex(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class NewUserStrategyUserStrategyStruct extends ethereum.Tuple {
  get user(): Address {
    return this[0].toAddress();
  }

  get tokenIn(): Address {
    return this[1].toAddress();
  }

  get tokenOut(): Address {
    return this[2].toAddress();
  }

  get timeInterval(): BigInt {
    return this[3].toBigInt();
  }

  get nextExecution(): BigInt {
    return this[4].toBigInt();
  }

  get amount(): BigInt {
    return this[5].toBigInt();
  }

  get limit(): BigInt {
    return this[6].toBigInt();
  }

  get lastResponse(): Bytes {
    return this[7].toBytes();
  }
}

export class OwnershipTransferRequested extends ethereum.Event {
  get params(): OwnershipTransferRequested__Params {
    return new OwnershipTransferRequested__Params(this);
  }
}

export class OwnershipTransferRequested__Params {
  _event: OwnershipTransferRequested;

  constructor(event: OwnershipTransferRequested) {
    this._event = event;
  }

  get from(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get to(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class OwnershipTransferred extends ethereum.Event {
  get params(): OwnershipTransferred__Params {
    return new OwnershipTransferred__Params(this);
  }
}

export class OwnershipTransferred__Params {
  _event: OwnershipTransferred;

  constructor(event: OwnershipTransferred) {
    this._event = event;
  }

  get from(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get to(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class RemovedUserStrategy extends ethereum.Event {
  get params(): RemovedUserStrategy__Params {
    return new RemovedUserStrategy__Params(this);
  }
}

export class RemovedUserStrategy__Params {
  _event: RemovedUserStrategy;

  constructor(event: RemovedUserStrategy) {
    this._event = event;
  }

  get user(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get strategyIndex(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }
}

export class RequestFulfilled extends ethereum.Event {
  get params(): RequestFulfilled__Params {
    return new RequestFulfilled__Params(this);
  }
}

export class RequestFulfilled__Params {
  _event: RequestFulfilled;

  constructor(event: RequestFulfilled) {
    this._event = event;
  }

  get id(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }
}

export class RequestReceived extends ethereum.Event {
  get params(): RequestReceived__Params {
    return new RequestReceived__Params(this);
  }
}

export class RequestReceived__Params {
  _event: RequestReceived;

  constructor(event: RequestReceived) {
    this._event = event;
  }

  get requestId(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get strategyIndex(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }
}

export class RequestSent extends ethereum.Event {
  get params(): RequestSent__Params {
    return new RequestSent__Params(this);
  }
}

export class RequestSent__Params {
  _event: RequestSent;

  constructor(event: RequestSent) {
    this._event = event;
  }

  get id(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }
}

export class Response extends ethereum.Event {
  get params(): Response__Params {
    return new Response__Params(this);
  }
}

export class Response__Params {
  _event: Response;

  constructor(event: Response) {
    this._event = event;
  }

  get requestId(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get response(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get err(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }
}

export class SwapExecuted extends ethereum.Event {
  get params(): SwapExecuted__Params {
    return new SwapExecuted__Params(this);
  }
}

export class SwapExecuted__Params {
  _event: SwapExecuted;

  constructor(event: SwapExecuted) {
    this._event = event;
  }

  get requestId(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get strategyIndex(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get amountIn(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }

  get amountOut(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get user(): Address {
    return this._event.parameters[4].value.toAddress();
  }

  get tokenIn(): Address {
    return this._event.parameters[5].value.toAddress();
  }

  get tokenOut(): Address {
    return this._event.parameters[6].value.toAddress();
  }
}

export class UpdatedUserStrategy extends ethereum.Event {
  get params(): UpdatedUserStrategy__Params {
    return new UpdatedUserStrategy__Params(this);
  }
}

export class UpdatedUserStrategy__Params {
  _event: UpdatedUserStrategy;

  constructor(event: UpdatedUserStrategy) {
    this._event = event;
  }

  get user(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get userStrategy(): UpdatedUserStrategyUserStrategyStruct {
    return changetype<UpdatedUserStrategyUserStrategyStruct>(
      this._event.parameters[1].value.toTuple()
    );
  }

  get strategyIndex(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class UpdatedUserStrategyUserStrategyStruct extends ethereum.Tuple {
  get user(): Address {
    return this[0].toAddress();
  }

  get tokenIn(): Address {
    return this[1].toAddress();
  }

  get tokenOut(): Address {
    return this[2].toAddress();
  }

  get timeInterval(): BigInt {
    return this[3].toBigInt();
  }

  get nextExecution(): BigInt {
    return this[4].toBigInt();
  }

  get amount(): BigInt {
    return this[5].toBigInt();
  }

  get limit(): BigInt {
    return this[6].toBigInt();
  }

  get lastResponse(): Bytes {
    return this[7].toBytes();
  }
}

export class Contract__checkLogResult {
  value0: boolean;
  value1: Bytes;

  constructor(value0: boolean, value1: Bytes) {
    this.value0 = value0;
    this.value1 = value1;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromBoolean(this.value0));
    map.set("value1", ethereum.Value.fromBytes(this.value1));
    return map;
  }

  getUpkeepNeeded(): boolean {
    return this.value0;
  }

  getPerformData(): Bytes {
    return this.value1;
  }
}

export class Contract__checkLogInputLogStruct extends ethereum.Tuple {
  get index(): BigInt {
    return this[0].toBigInt();
  }

  get timestamp(): BigInt {
    return this[1].toBigInt();
  }

  get txHash(): Bytes {
    return this[2].toBytes();
  }

  get blockNumber(): BigInt {
    return this[3].toBigInt();
  }

  get blockHash(): Bytes {
    return this[4].toBytes();
  }

  get source(): Address {
    return this[5].toAddress();
  }

  get topics(): Array<Bytes> {
    return this[6].toBytesArray();
  }

  get data(): Bytes {
    return this[7].toBytes();
  }
}

export class Contract__checkUpkeepResult {
  value0: boolean;
  value1: Bytes;

  constructor(value0: boolean, value1: Bytes) {
    this.value0 = value0;
    this.value1 = value1;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromBoolean(this.value0));
    map.set("value1", ethereum.Value.fromBytes(this.value1));
    return map;
  }

  getUpkeepNeeded(): boolean {
    return this.value0;
  }

  getPerformData(): Bytes {
    return this.value1;
  }
}

export class Contract__s_usersStrategiesResult {
  value0: Address;
  value1: Address;
  value2: Address;
  value3: BigInt;
  value4: BigInt;
  value5: BigInt;
  value6: BigInt;
  value7: Bytes;

  constructor(
    value0: Address,
    value1: Address,
    value2: Address,
    value3: BigInt,
    value4: BigInt,
    value5: BigInt,
    value6: BigInt,
    value7: Bytes
  ) {
    this.value0 = value0;
    this.value1 = value1;
    this.value2 = value2;
    this.value3 = value3;
    this.value4 = value4;
    this.value5 = value5;
    this.value6 = value6;
    this.value7 = value7;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromAddress(this.value0));
    map.set("value1", ethereum.Value.fromAddress(this.value1));
    map.set("value2", ethereum.Value.fromAddress(this.value2));
    map.set("value3", ethereum.Value.fromUnsignedBigInt(this.value3));
    map.set("value4", ethereum.Value.fromUnsignedBigInt(this.value4));
    map.set("value5", ethereum.Value.fromUnsignedBigInt(this.value5));
    map.set("value6", ethereum.Value.fromUnsignedBigInt(this.value6));
    map.set("value7", ethereum.Value.fromBytes(this.value7));
    return map;
  }

  getUser(): Address {
    return this.value0;
  }

  getTokenIn(): Address {
    return this.value1;
  }

  getTokenOut(): Address {
    return this.value2;
  }

  getTimeInterval(): BigInt {
    return this.value3;
  }

  getNextExecution(): BigInt {
    return this.value4;
  }

  getAmount(): BigInt {
    return this.value5;
  }

  getLimit(): BigInt {
    return this.value6;
  }

  getLastResponse(): Bytes {
    return this.value7;
  }
}

export class Contract extends ethereum.SmartContract {
  static bind(address: Address): Contract {
    return new Contract("Contract", address);
  }

  setPause(pause: boolean): boolean {
    let result = super.call("setPause", "setPause(bool):(bool)", [
      ethereum.Value.fromBoolean(pause)
    ]);

    return result[0].toBoolean();
  }

  try_setPause(pause: boolean): ethereum.CallResult<boolean> {
    let result = super.tryCall("setPause", "setPause(bool):(bool)", [
      ethereum.Value.fromBoolean(pause)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  _batchQuery(): Array<BigInt> {
    let result = super.call("_batchQuery", "_batchQuery():(uint256[])", []);

    return result[0].toBigIntArray();
  }

  try__batchQuery(): ethereum.CallResult<Array<BigInt>> {
    let result = super.tryCall("_batchQuery", "_batchQuery():(uint256[])", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigIntArray());
  }

  addressMappinglength(): BigInt {
    let result = super.call(
      "addressMappinglength",
      "addressMappinglength():(uint256)",
      []
    );

    return result[0].toBigInt();
  }

  try_addressMappinglength(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "addressMappinglength",
      "addressMappinglength():(uint256)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  checkLog(
    log: Contract__checkLogInputLogStruct,
    param1: Bytes
  ): Contract__checkLogResult {
    let result = super.call(
      "checkLog",
      "checkLog((uint256,uint256,bytes32,uint256,bytes32,address,bytes32[],bytes),bytes):(bool,bytes)",
      [ethereum.Value.fromTuple(log), ethereum.Value.fromBytes(param1)]
    );

    return new Contract__checkLogResult(
      result[0].toBoolean(),
      result[1].toBytes()
    );
  }

  try_checkLog(
    log: Contract__checkLogInputLogStruct,
    param1: Bytes
  ): ethereum.CallResult<Contract__checkLogResult> {
    let result = super.tryCall(
      "checkLog",
      "checkLog((uint256,uint256,bytes32,uint256,bytes32,address,bytes32[],bytes),bytes):(bool,bytes)",
      [ethereum.Value.fromTuple(log), ethereum.Value.fromBytes(param1)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new Contract__checkLogResult(value[0].toBoolean(), value[1].toBytes())
    );
  }

  checkUpkeep(param0: Bytes): Contract__checkUpkeepResult {
    let result = super.call("checkUpkeep", "checkUpkeep(bytes):(bool,bytes)", [
      ethereum.Value.fromBytes(param0)
    ]);

    return new Contract__checkUpkeepResult(
      result[0].toBoolean(),
      result[1].toBytes()
    );
  }

  try_checkUpkeep(
    param0: Bytes
  ): ethereum.CallResult<Contract__checkUpkeepResult> {
    let result = super.tryCall(
      "checkUpkeep",
      "checkUpkeep(bytes):(bool,bytes)",
      [ethereum.Value.fromBytes(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new Contract__checkUpkeepResult(value[0].toBoolean(), value[1].toBytes())
    );
  }

  donID(): Bytes {
    let result = super.call("donID", "donID():(bytes32)", []);

    return result[0].toBytes();
  }

  try_donID(): ethereum.CallResult<Bytes> {
    let result = super.tryCall("donID", "donID():(bytes32)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBytes());
  }

  getChainlinkDataFeedLatestAnswer(feedAddress: Address): BigInt {
    let result = super.call(
      "getChainlinkDataFeedLatestAnswer",
      "getChainlinkDataFeedLatestAnswer(address):(int256)",
      [ethereum.Value.fromAddress(feedAddress)]
    );

    return result[0].toBigInt();
  }

  try_getChainlinkDataFeedLatestAnswer(
    feedAddress: Address
  ): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "getChainlinkDataFeedLatestAnswer",
      "getChainlinkDataFeedLatestAnswer(address):(int256)",
      [ethereum.Value.fromAddress(feedAddress)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  isPaused(): boolean {
    let result = super.call("isPaused", "isPaused():(bool)", []);

    return result[0].toBoolean();
  }

  try_isPaused(): ethereum.CallResult<boolean> {
    let result = super.tryCall("isPaused", "isPaused():(bool)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  owner(): Address {
    let result = super.call("owner", "owner():(address)", []);

    return result[0].toAddress();
  }

  try_owner(): ethereum.CallResult<Address> {
    let result = super.tryCall("owner", "owner():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  requestsIds(param0: Bytes): BigInt {
    let result = super.call("requestsIds", "requestsIds(bytes32):(uint256)", [
      ethereum.Value.fromFixedBytes(param0)
    ]);

    return result[0].toBigInt();
  }

  try_requestsIds(param0: Bytes): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "requestsIds",
      "requestsIds(bytes32):(uint256)",
      [ethereum.Value.fromFixedBytes(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  s_usersStrategies(param0: BigInt): Contract__s_usersStrategiesResult {
    let result = super.call(
      "s_usersStrategies",
      "s_usersStrategies(uint256):(address,address,address,uint256,uint256,uint256,uint256,bytes)",
      [ethereum.Value.fromUnsignedBigInt(param0)]
    );

    return new Contract__s_usersStrategiesResult(
      result[0].toAddress(),
      result[1].toAddress(),
      result[2].toAddress(),
      result[3].toBigInt(),
      result[4].toBigInt(),
      result[5].toBigInt(),
      result[6].toBigInt(),
      result[7].toBytes()
    );
  }

  try_s_usersStrategies(
    param0: BigInt
  ): ethereum.CallResult<Contract__s_usersStrategiesResult> {
    let result = super.tryCall(
      "s_usersStrategies",
      "s_usersStrategies(uint256):(address,address,address,uint256,uint256,uint256,uint256,bytes)",
      [ethereum.Value.fromUnsignedBigInt(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new Contract__s_usersStrategiesResult(
        value[0].toAddress(),
        value[1].toAddress(),
        value[2].toAddress(),
        value[3].toBigInt(),
        value[4].toBigInt(),
        value[5].toBigInt(),
        value[6].toBigInt(),
        value[7].toBytes()
      )
    );
  }

  tokenAllowed(param0: Address): boolean {
    let result = super.call("tokenAllowed", "tokenAllowed(address):(bool)", [
      ethereum.Value.fromAddress(param0)
    ]);

    return result[0].toBoolean();
  }

  try_tokenAllowed(param0: Address): ethereum.CallResult<boolean> {
    let result = super.tryCall("tokenAllowed", "tokenAllowed(address):(bool)", [
      ethereum.Value.fromAddress(param0)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  tokenIndexes(param0: Address): BigInt {
    let result = super.call("tokenIndexes", "tokenIndexes(address):(uint256)", [
      ethereum.Value.fromAddress(param0)
    ]);

    return result[0].toBigInt();
  }

  try_tokenIndexes(param0: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "tokenIndexes",
      "tokenIndexes(address):(uint256)",
      [ethereum.Value.fromAddress(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  upkeepContract1(): Address {
    let result = super.call(
      "upkeepContract1",
      "upkeepContract1():(address)",
      []
    );

    return result[0].toAddress();
  }

  try_upkeepContract1(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "upkeepContract1",
      "upkeepContract1():(address)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  upkeepContract2(): Address {
    let result = super.call(
      "upkeepContract2",
      "upkeepContract2():(address)",
      []
    );

    return result[0].toAddress();
  }

  try_upkeepContract2(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "upkeepContract2",
      "upkeepContract2():(address)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }
}

export class AcceptOwnershipCall extends ethereum.Call {
  get inputs(): AcceptOwnershipCall__Inputs {
    return new AcceptOwnershipCall__Inputs(this);
  }

  get outputs(): AcceptOwnershipCall__Outputs {
    return new AcceptOwnershipCall__Outputs(this);
  }
}

export class AcceptOwnershipCall__Inputs {
  _call: AcceptOwnershipCall;

  constructor(call: AcceptOwnershipCall) {
    this._call = call;
  }
}

export class AcceptOwnershipCall__Outputs {
  _call: AcceptOwnershipCall;

  constructor(call: AcceptOwnershipCall) {
    this._call = call;
  }
}

export class CreateStrategyCall extends ethereum.Call {
  get inputs(): CreateStrategyCall__Inputs {
    return new CreateStrategyCall__Inputs(this);
  }

  get outputs(): CreateStrategyCall__Outputs {
    return new CreateStrategyCall__Outputs(this);
  }
}

export class CreateStrategyCall__Inputs {
  _call: CreateStrategyCall;

  constructor(call: CreateStrategyCall) {
    this._call = call;
  }

  get tokenFrom(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get tokenTo(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get timeInterval(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }

  get tokenInAmount(): BigInt {
    return this._call.inputValues[3].value.toBigInt();
  }

  get limit(): BigInt {
    return this._call.inputValues[4].value.toBigInt();
  }
}

export class CreateStrategyCall__Outputs {
  _call: CreateStrategyCall;

  constructor(call: CreateStrategyCall) {
    this._call = call;
  }
}

export class ConstructorCall extends ethereum.Call {
  get inputs(): ConstructorCall__Inputs {
    return new ConstructorCall__Inputs(this);
  }

  get outputs(): ConstructorCall__Outputs {
    return new ConstructorCall__Outputs(this);
  }
}

export class ConstructorCall__Inputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }

  get _router(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class ConstructorCall__Outputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }
}

export class HandleOracleFulfillmentCall extends ethereum.Call {
  get inputs(): HandleOracleFulfillmentCall__Inputs {
    return new HandleOracleFulfillmentCall__Inputs(this);
  }

  get outputs(): HandleOracleFulfillmentCall__Outputs {
    return new HandleOracleFulfillmentCall__Outputs(this);
  }
}

export class HandleOracleFulfillmentCall__Inputs {
  _call: HandleOracleFulfillmentCall;

  constructor(call: HandleOracleFulfillmentCall) {
    this._call = call;
  }

  get requestId(): Bytes {
    return this._call.inputValues[0].value.toBytes();
  }

  get response(): Bytes {
    return this._call.inputValues[1].value.toBytes();
  }

  get err(): Bytes {
    return this._call.inputValues[2].value.toBytes();
  }
}

export class HandleOracleFulfillmentCall__Outputs {
  _call: HandleOracleFulfillmentCall;

  constructor(call: HandleOracleFulfillmentCall) {
    this._call = call;
  }
}

export class InitCall extends ethereum.Call {
  get inputs(): InitCall__Inputs {
    return new InitCall__Inputs(this);
  }

  get outputs(): InitCall__Outputs {
    return new InitCall__Outputs(this);
  }
}

export class InitCall__Inputs {
  _call: InitCall;

  constructor(call: InitCall) {
    this._call = call;
  }

  get _usdcAddress(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _gasLimit(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get _donID(): Bytes {
    return this._call.inputValues[2].value.toBytes();
  }

  get _subscriptionId(): BigInt {
    return this._call.inputValues[3].value.toBigInt();
  }

  get _upkeepContract1(): Address {
    return this._call.inputValues[4].value.toAddress();
  }

  get _upkeepContract2(): Address {
    return this._call.inputValues[5].value.toAddress();
  }
}

export class InitCall__Outputs {
  _call: InitCall;

  constructor(call: InitCall) {
    this._call = call;
  }
}

export class MapAddressesCall extends ethereum.Call {
  get inputs(): MapAddressesCall__Inputs {
    return new MapAddressesCall__Inputs(this);
  }

  get outputs(): MapAddressesCall__Outputs {
    return new MapAddressesCall__Outputs(this);
  }
}

export class MapAddressesCall__Inputs {
  _call: MapAddressesCall;

  constructor(call: MapAddressesCall) {
    this._call = call;
  }

  get tokenAddresses(): Array<Address> {
    return this._call.inputValues[0].value.toAddressArray();
  }
}

export class MapAddressesCall__Outputs {
  _call: MapAddressesCall;

  constructor(call: MapAddressesCall) {
    this._call = call;
  }
}

export class PerformUpkeepCall extends ethereum.Call {
  get inputs(): PerformUpkeepCall__Inputs {
    return new PerformUpkeepCall__Inputs(this);
  }

  get outputs(): PerformUpkeepCall__Outputs {
    return new PerformUpkeepCall__Outputs(this);
  }
}

export class PerformUpkeepCall__Inputs {
  _call: PerformUpkeepCall;

  constructor(call: PerformUpkeepCall) {
    this._call = call;
  }

  get performData(): Bytes {
    return this._call.inputValues[0].value.toBytes();
  }
}

export class PerformUpkeepCall__Outputs {
  _call: PerformUpkeepCall;

  constructor(call: PerformUpkeepCall) {
    this._call = call;
  }
}

export class RemoveStrategyCall extends ethereum.Call {
  get inputs(): RemoveStrategyCall__Inputs {
    return new RemoveStrategyCall__Inputs(this);
  }

  get outputs(): RemoveStrategyCall__Outputs {
    return new RemoveStrategyCall__Outputs(this);
  }
}

export class RemoveStrategyCall__Inputs {
  _call: RemoveStrategyCall;

  constructor(call: RemoveStrategyCall) {
    this._call = call;
  }

  get index(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class RemoveStrategyCall__Outputs {
  _call: RemoveStrategyCall;

  constructor(call: RemoveStrategyCall) {
    this._call = call;
  }
}

export class SetPauseCall extends ethereum.Call {
  get inputs(): SetPauseCall__Inputs {
    return new SetPauseCall__Inputs(this);
  }

  get outputs(): SetPauseCall__Outputs {
    return new SetPauseCall__Outputs(this);
  }
}

export class SetPauseCall__Inputs {
  _call: SetPauseCall;

  constructor(call: SetPauseCall) {
    this._call = call;
  }

  get pause(): boolean {
    return this._call.inputValues[0].value.toBoolean();
  }
}

export class SetPauseCall__Outputs {
  _call: SetPauseCall;

  constructor(call: SetPauseCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class SetUpkeepForwardersCall extends ethereum.Call {
  get inputs(): SetUpkeepForwardersCall__Inputs {
    return new SetUpkeepForwardersCall__Inputs(this);
  }

  get outputs(): SetUpkeepForwardersCall__Outputs {
    return new SetUpkeepForwardersCall__Outputs(this);
  }
}

export class SetUpkeepForwardersCall__Inputs {
  _call: SetUpkeepForwardersCall;

  constructor(call: SetUpkeepForwardersCall) {
    this._call = call;
  }

  get _upkeepContract1(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _upkeepContract2(): Address {
    return this._call.inputValues[1].value.toAddress();
  }
}

export class SetUpkeepForwardersCall__Outputs {
  _call: SetUpkeepForwardersCall;

  constructor(call: SetUpkeepForwardersCall) {
    this._call = call;
  }
}

export class TransferOwnershipCall extends ethereum.Call {
  get inputs(): TransferOwnershipCall__Inputs {
    return new TransferOwnershipCall__Inputs(this);
  }

  get outputs(): TransferOwnershipCall__Outputs {
    return new TransferOwnershipCall__Outputs(this);
  }
}

export class TransferOwnershipCall__Inputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }

  get to(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class TransferOwnershipCall__Outputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }
}

export class UpgradeStrategyCall extends ethereum.Call {
  get inputs(): UpgradeStrategyCall__Inputs {
    return new UpgradeStrategyCall__Inputs(this);
  }

  get outputs(): UpgradeStrategyCall__Outputs {
    return new UpgradeStrategyCall__Outputs(this);
  }
}

export class UpgradeStrategyCall__Inputs {
  _call: UpgradeStrategyCall;

  constructor(call: UpgradeStrategyCall) {
    this._call = call;
  }

  get index(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get tokenFrom(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get tokenTo(): Address {
    return this._call.inputValues[2].value.toAddress();
  }

  get timeInterval(): BigInt {
    return this._call.inputValues[3].value.toBigInt();
  }

  get amountTokenIn(): BigInt {
    return this._call.inputValues[4].value.toBigInt();
  }

  get limit(): BigInt {
    return this._call.inputValues[5].value.toBigInt();
  }
}

export class UpgradeStrategyCall__Outputs {
  _call: UpgradeStrategyCall;

  constructor(call: UpgradeStrategyCall) {
    this._call = call;
  }
}
