import { useContractWrite } from "wagmi";
import { availableTokens, possibleNetworks } from "../tokens";
import { calculateTimeInterval } from "../utils";
import { abi, address } from "./constants";



const baseConfig = {
	address: address as any,
	abi,
}


export const useCreateStrategy = (timeRange: string, timeUnit: string | Number, tokenFrom: string, tokenToOption: any, amount: string, limit: string | Number) => {

	// prepare transaction 
	const network = { name: "polygonMumbai" }

	//token to swap
	const tokento: string = availableTokens["polygonMumbai"][tokenToOption as "WETH" | "WBTC" | "LINK"]

	// time interval or limit
	let interval
	let limitOrder
	if (timeUnit) {
		interval = calculateTimeInterval(Number(timeUnit), timeRange)
		limitOrder = 0
	} else {
		limitOrder = Number(limit) * 1000000
		interval = 0
	}

	const amountWithDecimals = Number(amount) * 1000000
	const args: any[] = [tokento, interval, amountWithDecimals, limitOrder]

	const { data: createStrategyData, isLoading: isCreateStrategyLoading, isSuccess: isCreateStrategySuccess, write: createStrategyWrite } = useContractWrite({
		...baseConfig,
		functionName: "createStrategy",
		args
	})
	return { createStrategyData, isCreateStrategyLoading, isCreateStrategySuccess, createStrategyWrite }
}

export const useRemoveStrategy = (index: Number) => {

	const { data: removeStrategyData, isLoading: isRemoveStrategyLoading, isSuccess: isRemoveStrategySuccess, write: removeStrategyWrite } = useContractWrite({
		...baseConfig,
		functionName: "removeStrategy",
		args: [index]
	})
	return { removeStrategyData, isRemoveStrategyLoading, isRemoveStrategySuccess, removeStrategyWrite }
}


// "inputs": [
// 			{
// 				"internalType": "uint256",
// 				"name": "index",
// 				"type": "uint256"
// 			},
// 			{
// 				"internalType": "address",
// 				"name": "tokenTo",
// 				"type": "address"
// 			},
// 			{
// 				"internalType": "uint256",
// 				"name": "timeInterval",
// 				"type": "uint256"
// 			},
// 			{
// 				"internalType": "uint256",
// 				"name": "amountTokenIn",
// 				"type": "uint256"
// 			},
// 			{
// 				"internalType": "uint256",
// 				"name": "limit",
// 				"type": "uint256"
// 			}
// 		]

export const useUpgradeStrategy = (index: Number, timeRange: string, timeUnit: string | Number, tokenFrom: string, tokenToOption: any, amount: string, limit: string | Number) => {

	// prepare transaction 
	const network = { name: "polygonMumbai" }

	//token to swap
	const tokenTo: string = availableTokens["polygonMumbai"][tokenToOption as "WETH" | "WBTC" | "LINK"]

	// time interval or limit
	let interval
	let limitOrder
	if (timeUnit) {
		interval = calculateTimeInterval(Number(timeUnit), timeRange)
		limitOrder = 0
	} else {
		limitOrder = Number(limit) * 1000000
		interval = 0
	}

	const amountWithDecimals = Number(amount) * 1000000
	const args: any[] = [index, tokenTo, interval, amountWithDecimals, limitOrder]

	const { data: upgradeStrategyData, isLoading: isUpgradeStrategyLoading, isSuccess: isUpgradeStrategySuccess, write: upgradeStrategyWrite } = useContractWrite({
		...baseConfig,
		functionName: "upgradeStrategy",
		args
	})
	return { data: upgradeStrategyData, isLoading: isUpgradeStrategyLoading, isSuccess: isUpgradeStrategySuccess, write: upgradeStrategyWrite }
}
