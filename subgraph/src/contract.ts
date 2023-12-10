import { BigInt, bigInt } from "@graphprotocol/graph-ts";
import {
  NewUserStrategy as NewUserStrategyEvent,
  RemovedUserStrategy as RemovedUserStrategyEvent,
  RequestReceived as RequestReceivedEvent,
  Response as ResponseEvent,
  SwapExecuted as SwapExecutedEvent, 
  UpdatedUserStrategy as UpdatedUserStrategyEvent
} from "../generated/Contract/Contract"
import {
  User,
  Strategy,
  Protocol
} from "../generated/schema"

const usdc = "0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664";

export function handleNewUserStrategy(event: NewUserStrategyEvent): void {
  let strategy = new Strategy(event.params.strategyIndex.toString());
  if (event.params.userStrategy.timeInterval.toString() == "0"){
      strategy.type = "Limit";
  } 
  if (event.params.userStrategy.limit.toString() == "0"){
    strategy.type = "DCA";
  } 

  strategy.user = event.params.userStrategy.user;
  strategy.tokenIn = event.params.userStrategy.tokenIn;
  strategy.tokenOut = event.params.userStrategy.tokenOut;
  strategy.timeInterval = event.params.userStrategy.timeInterval;
  strategy.nextExecution = event.params.userStrategy.nextExecution;
  strategy.amount = event.params.userStrategy.amount;
  strategy.limit = event.params.userStrategy.limit;
  strategy.strategyIndex = event.params.strategyIndex;
  strategy.blockTimestamp = event.block.timestamp;
  strategy.dcaVolume = BigInt.fromI32(0);
  strategy.triggers = BigInt.fromI32(0);
  strategy.save();

  let user = User.load(event.params.user.toHexString());
  if (!user) {
    user = new User(event.params.user.toHexString());
    user.strategies = [event.params.strategyIndex.toString()];
    user.totalVolume = BigInt.fromI32(0);
  } else {
    user.strategies = user.strategies!.concat([event.params.strategyIndex.toString()]);
  }
  user.save();
}
export function handleUpdatedUserStrategy(event: UpdatedUserStrategyEvent): void {
  let strategy = Strategy.load(event.params.strategyIndex.toString());
  if (event.params.userStrategy.timeInterval.toString() == "0"){
    strategy!.type = "Limit";
  } 
  if (event.params.userStrategy.limit.toString() == "0"){
    strategy!.type = "DCA";
  } 
  strategy!.tokenIn = event.params.userStrategy.tokenIn;
  strategy!.tokenOut = event.params.userStrategy.tokenOut;
  strategy!.timeInterval = event.params.userStrategy.timeInterval;
  strategy!.nextExecution = event.params.userStrategy.nextExecution;
  strategy!.amount = event.params.userStrategy.amount;
  strategy!.limit = event.params.userStrategy.limit;
  strategy!.save();
  
  let user = User.load(event.params.user.toHexString());
  
  user!.strategies = user!.strategies!.concat([event.params.strategyIndex.toString()]);


  user!.save();
}

export function handleRemovedUserStrategy(event: RemovedUserStrategyEvent): void {
  let strategy = Strategy.load(event.params.strategyIndex.toString());
  strategy!.type = "Deleted";
  strategy!.save();
}

export function handleRequestReceived(event: RequestReceivedEvent): void {

}
export function handleResponse(event: ResponseEvent): void {

}
export function handleSwapExecuted(event: SwapExecutedEvent): void {
  let protocol = Protocol.load(BigInt.fromI32(1).toString());
  if (!protocol){
    protocol =  new Protocol(BigInt.fromI32(1).toString());
    protocol.protocolTotalVolume = event.params.amountIn;
    protocol.protocolSwaps = BigInt.fromI32(1);
  } else {
    if (event.params.tokenIn.toHexString() == usdc){
      protocol!.protocolTotalVolume = protocol!.protocolTotalVolume.plus(event.params.amountIn);
    } else if (event.params.tokenOut.toHexString() == usdc){
      protocol!.protocolTotalVolume = protocol!.protocolTotalVolume.plus(event.params.amountOut);
    }
    
    protocol.protocolSwaps = protocol!.protocolSwaps.plus(BigInt.fromI32(1));
  }
  protocol.save();
  
  let user = User.load(event.params.user.toHexString());

  if (event.params.tokenIn.toHexString() == usdc){
    user!.totalVolume = user!.totalVolume!.plus(event.params.amountIn);
  } else if (event.params.tokenOut.toHexString() == usdc){
    user!.totalVolume = user!.totalVolume!.plus(event.params.amountOut);
  }
  user!.save();

  let strategy = Strategy.load(event.params.strategyIndex.toString());
  if (strategy){
    if (strategy!.type!.toString() == "Limit"){
      strategy!.type! = "Fulfilled";
      strategy!.limitAmountOut = event.params.amountOut;
    }
    if (strategy!.type!.toString() == "DCA"){
      strategy!.triggers! = strategy!.triggers!.plus(BigInt.fromI32(1));
      strategy!.dcaVolume! = strategy!.dcaVolume!.plus(event.params.amountIn);
    }
  }
  strategy!.save();
}
