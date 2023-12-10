import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import {
  NewUserStrategy,
  RemovedUserStrategy,
  RequestReceived,
  Response,
  SwapExecuted,
  UpdatedUserStrategy
} from "../generated/Contract/Contract"

export function createNewUserStrategyEvent(
  user: Address,
  userStrategy: ethereum.Tuple,
  strategyIndex: BigInt
): NewUserStrategy {
  let newUserStrategyEvent = changetype<NewUserStrategy>(newMockEvent())

  newUserStrategyEvent.parameters = new Array()

  newUserStrategyEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  newUserStrategyEvent.parameters.push(
    new ethereum.EventParam(
      "userStrategy",
      ethereum.Value.fromTuple(userStrategy)
    )
  )
  newUserStrategyEvent.parameters.push(
    new ethereum.EventParam(
      "strategyIndex",
      ethereum.Value.fromUnsignedBigInt(strategyIndex)
    )
  )

  return newUserStrategyEvent
}

export function createRemovedUserStrategyEvent(
  user: Address,
  strategyIndex: BigInt
): RemovedUserStrategy {
  let removedUserStrategyEvent = changetype<RemovedUserStrategy>(newMockEvent())

  removedUserStrategyEvent.parameters = new Array()

  removedUserStrategyEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  removedUserStrategyEvent.parameters.push(
    new ethereum.EventParam(
      "strategyIndex",
      ethereum.Value.fromUnsignedBigInt(strategyIndex)
    )
  )

  return removedUserStrategyEvent
}

export function createRequestReceivedEvent(
  requestId: Bytes,
  strategyIndex: BigInt
): RequestReceived {
  let requestReceivedEvent = changetype<RequestReceived>(newMockEvent())

  requestReceivedEvent.parameters = new Array()

  requestReceivedEvent.parameters.push(
    new ethereum.EventParam(
      "requestId",
      ethereum.Value.fromFixedBytes(requestId)
    )
  )
  requestReceivedEvent.parameters.push(
    new ethereum.EventParam(
      "strategyIndex",
      ethereum.Value.fromUnsignedBigInt(strategyIndex)
    )
  )

  return requestReceivedEvent
}

export function createResponseEvent(
  requestId: Bytes,
  response: Bytes,
  err: Bytes
): Response {
  let responseEvent = changetype<Response>(newMockEvent())

  responseEvent.parameters = new Array()

  responseEvent.parameters.push(
    new ethereum.EventParam(
      "requestId",
      ethereum.Value.fromFixedBytes(requestId)
    )
  )
  responseEvent.parameters.push(
    new ethereum.EventParam("response", ethereum.Value.fromBytes(response))
  )
  responseEvent.parameters.push(
    new ethereum.EventParam("err", ethereum.Value.fromBytes(err))
  )

  return responseEvent
}

export function createSwapExecutedEvent(
  requestId: Bytes,
  strategyIndex: BigInt,
  amountIn: BigInt,
  user: Address,
  tokenIn: Address,
  tokenOut: Address
): SwapExecuted {
  let swapExecutedEvent = changetype<SwapExecuted>(newMockEvent())

  swapExecutedEvent.parameters = new Array()

  swapExecutedEvent.parameters.push(
    new ethereum.EventParam(
      "requestId",
      ethereum.Value.fromFixedBytes(requestId)
    )
  )
  swapExecutedEvent.parameters.push(
    new ethereum.EventParam(
      "strategyIndex",
      ethereum.Value.fromUnsignedBigInt(strategyIndex)
    )
  )
  swapExecutedEvent.parameters.push(
    new ethereum.EventParam(
      "amountIn",
      ethereum.Value.fromUnsignedBigInt(amountIn)
    )
  )
  swapExecutedEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  swapExecutedEvent.parameters.push(
    new ethereum.EventParam("tokenIn", ethereum.Value.fromAddress(tokenIn))
  )
  swapExecutedEvent.parameters.push(
    new ethereum.EventParam("tokenOut", ethereum.Value.fromAddress(tokenOut))
  )

  return swapExecutedEvent
}

export function createUpdatedUserStrategyEvent(
  user: Address,
  userStrategy: ethereum.Tuple,
  strategyIndex: BigInt
): UpdatedUserStrategy {
  let updatedUserStrategyEvent = changetype<UpdatedUserStrategy>(newMockEvent())

  updatedUserStrategyEvent.parameters = new Array()

  updatedUserStrategyEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  updatedUserStrategyEvent.parameters.push(
    new ethereum.EventParam(
      "userStrategy",
      ethereum.Value.fromTuple(userStrategy)
    )
  )
  updatedUserStrategyEvent.parameters.push(
    new ethereum.EventParam(
      "strategyIndex",
      ethereum.Value.fromUnsignedBigInt(strategyIndex)
    )
  )

  return updatedUserStrategyEvent
}
