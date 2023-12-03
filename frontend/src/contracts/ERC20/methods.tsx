import { useAccount, useContractWrite } from "wagmi";
import { availableTokens, possibleNetworks } from "../tokens";
import { calculateTimeInterval } from "../utils";
import { abi, address } from "./constants";



const baseConfig = {
	address: address as any,
	abi,
}



export const useApproveERC20 = (amount: Number) => {
	const {address} = useAccount()
	// prepare transaction 
	const network = { name: "polygonMumbai" }

	const amountWithDecimals = Number(amount) * 1000000
	const args: any[] = [address,amountWithDecimals]

	const { data: approveERC20Data, isLoading: isApproveERC20Loading, isSuccess: isApproveERC20Success, write: approveERC20Write } = useContractWrite({
		...baseConfig,
		functionName: "approve",
		args
	})
	return { approveERC20Data, isApproveERC20Loading, isApproveERC20Success, approveERC20Write }
}

