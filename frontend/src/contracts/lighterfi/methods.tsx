import { useContractWrite } from "wagmi";
import { AllowedPolygonMumbaiTokens, allowedTokens, availableTokens, possibleNetworks } from "../tokens";
import { calculateTimeInterval } from "../utils";
import { abi, address } from "./constants";



const baseConfig = {
	address: address as any,
	abi,
}


export const useCreateStrategy = (timeRange: string, timeUnit: string | Number, stableToken: AllowedPolygonMumbaiTokens, riskyToken: AllowedPolygonMumbaiTokens, amount: string, limit: string | Number, isBuy = true) => {

	// prepare transaction 
	const network = { name: "polygonMumbai" }

	//token to swap
	// const tokento: string = availableTokens["polygonMumbai"][tokenToOption as "WETH" | "WBTC" | "LINK"]
	let tokenfrom: string
	let tokento: string
	if (isBuy) { //sempre true a parte quando è un limit sell
		tokenfrom = allowedTokens.polygonMumbai[stableToken] // USDC
		tokento = allowedTokens.polygonMumbai[riskyToken] // wrapped matic
	} else {
		tokento = allowedTokens.polygonMumbai[riskyToken] // wrapped matic
		tokenfrom = allowedTokens.polygonMumbai[stableToken] // USDC
	}
	console.log(allowedTokens.polygonMumbai[riskyToken], "allowedTokens.polygonMumbai[riskyToken]")

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
	console.log(tokenfrom, "tokenfrom")
	console.log(tokento, "tokento")
	console.log(interval, "interval")
	
	console.log(limitOrder, "limitOrder")

	const amountWithDecimals = Number(amount) * 1000000
	console.log(amountWithDecimals, "amountWithDecimals")
	const args: any[] = [tokenfrom, "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270", interval, amountWithDecimals, limitOrder]

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

	const tokenfrom = allowedTokens.polygonMumbai.USDC

	const amountWithDecimals = Number(amount) * 1000000
	const args: any[] = [index, tokenFrom, tokenTo, interval, amountWithDecimals, limitOrder]

	const { data: upgradeStrategyData, isLoading: isUpgradeStrategyLoading, isSuccess: isUpgradeStrategySuccess, write: upgradeStrategyWrite } = useContractWrite({
		...baseConfig,
		functionName: "upgradeStrategy",
		args
	})
	return {  upgradeStrategyData,  isUpgradeStrategyLoading,  isUpgradeStrategySuccess,  upgradeStrategyWrite }
}
