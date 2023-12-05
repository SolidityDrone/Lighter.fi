'use client'
import React, { FC, FormEvent, useEffect, useState } from 'react';
import Button from '../common/button';
import Input from '../common/input';
import Select from '../common/select';
import Modal from '../common/modal';
import DataRecap from './dataRecap';
import { useCreateStrategy } from '@/contracts/lighterfi/methods';
import { availableTokensType } from '@/contracts/tokens';
import Loading from '../common/loading';
import Link from 'next/link';
import { useWaitForTransaction } from 'wagmi';
import { useApproveERC20 } from '@/contracts/ERC20/methods';

type Props = {
    isUpdate?: boolean
    data?: {
        type: string,
        interval: Number,
        limit: Number,
        token: string
        amount: Number
    }
}

const StrategyForm: FC<Props> = ({ isUpdate, data }) => {

    const [timeRange, setTimeRange] = useState<string>('hours');
    const [timeUnit, setTimeUnit] = useState<number | string>();
    const [limitOrder, setLimitOrder] = useState<number | string>();
    const [limitOrderType, setLimitOrderType] = useState("buy"); 
    const [token1, setToken1] = useState('USDC');
    const [token2, setToken2] = useState('AVAX');
    const [amount, setAmount] = useState<Number | string>('');
    const [isRecapModalOpen, setIsRecapModalOpen] = useState(false);
    const [isLoadingModalOpen, setIsLoadingModalOpen] = useState(false);
    const [isSuccessModalOpen, setIsSuccessModalOpen] = useState(false);
    const [selectedTab, setSelectedTab] = useState(1);


    const { approveERC20Write } = useApproveERC20(Number(amount));

    const { isCreateStrategyLoading, isCreateStrategySuccess, createStrategyData, createStrategyWrite } = useCreateStrategy(timeRange, timeUnit as Number, token1, token2 as unknown as availableTokensType, amount as string, limitOrder as Number)

    const { isSuccess } = useWaitForTransaction({
        hash: createStrategyData?.hash,
    })

    const handleTimeRangeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const selectedTimeRange = e.target.value;
        setTimeRange(selectedTimeRange);

        // Set default time unit based on selected time range
        switch (selectedTimeRange) {
            case 'Hours':
                setTimeUnit(24);
                break;
            case 'Days':
                setTimeUnit(6);
                break;
            case 'Weeks':
                setTimeUnit(4);
                break;
            case 'Months':
                setTimeUnit(12);
                break;
            default:
                setTimeUnit(24);
        }
    };

    const handleToken1Change = (e: React.ChangeEvent<HTMLSelectElement>) => {
        setToken1(e.target.value);
    };

    const handleToken2Change = (e: React.ChangeEvent<HTMLSelectElement>) => {
        setToken2(e.target.value);
    };

    const handleAmountChange = (e: any) => {
        setAmount(e.target.value);
    };

    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        openCloseRecapModal()
    };

    const openCloseRecapModal = () => {
        if (isRecapModalOpen) {
            setIsRecapModalOpen(false)
        } else {
            setIsRecapModalOpen(true)
        }
    }
    const openCloseLoadingModal = () => {
        if (isLoadingModalOpen) {
            setIsLoadingModalOpen(false)
        } else {
            setIsLoadingModalOpen(true)
        }
    }
    const openCloseSuccessModal = () => {
        if (isSuccessModalOpen) {
            setIsSuccessModalOpen(false)
        } else {
            setIsSuccessModalOpen(true)
        }
    }

    const handleApproveAndCreate = () => {
        approveERC20Write()
        createStrategyWrite()
    }

    useEffect(() => {
        if (isCreateStrategySuccess) {
            setIsSuccessModalOpen(isCreateStrategySuccess)
        }
    }, [isCreateStrategySuccess])

    useEffect(() => {
        console.log("createStrategyData", createStrategyData)
    }, [createStrategyData])

    useEffect(() => {
        if (timeUnit == 0) setTimeUnit("")
        if (limitOrder == 0) setLimitOrder("")
    }, [timeUnit, limitOrder])

    useEffect(() => {
        if (isUpdate && data) {
            setLimitOrder(Number(data.limit) / 1000000)
            setAmount(Number(data.amount) / 1000000)
            setToken2(data.token)
        }
    }, [isUpdate, data])



    return (
        <div className="max-w-xl p-10 bg-neutral rounded-md shadow-md">


            <Modal isOpen={isRecapModalOpen}
                title="Check Details And Create Strategy"
                closeModal={() => openCloseRecapModal()}
                children={<DataRecap
                    timeRange={`${timeUnit} ${timeRange}`}
                    limit={limitOrder}
                    limitOrderType={limitOrderType}
                    amount={amount}
                    token1={token1}
                    token2={token2}
                    confirm={handleApproveAndCreate} />} />
            <Modal isOpen={isCreateStrategyLoading}
                title="Please, Wait for the transaction.."
                children={<Loading />}
                closeModal={() => openCloseLoadingModal()} />
            <Modal isOpen={isSuccessModalOpen}
                title="Transaction landing onchain..."
                children={<div className="flex-column">
                    <a target="_blank" href={`https://mumbai.polygonscan.com/tx/${createStrategyData?.hash}`}>
                        Click here to check your transaction
                    </a>
                </div>}
                closeModal={openCloseSuccessModal} />
            {
                isSuccess &&
                <Modal isOpen={isSuccessModalOpen}
                    title="Transaction Is successful!🎉🍾🎊🎸☄️"
                    children={<div className="flex-column">
                        <a target="_blank" href={`https://mumbai.polygonscan.com/tx/${createStrategyData?.hash}`}>
                            Click here to view the transaction
                        </a>
                    </div>}
                    closeModal={openCloseSuccessModal} />

            }


            <div className="flex mb-4">
                <div
                    className={`cursor-pointer mr-4 ${selectedTab === 1 ? ' text-xs text-accent border-b-2' : 'text-xs hover:text-warning'}`}
                    onClick={() => setSelectedTab(1)}
                >
                    DCA
                </div>
                <div
                    className={`cursor-pointer  ${selectedTab === 2 ? 'text-xs text-accent border-b-2' : 'text-xs hover:text-warning'}`}
                    onClick={() => setSelectedTab(2)}
                >
                    Limit Order
                </div>
            </div>
            <form onSubmit={handleSubmit}>

               
                {
                    selectedTab === 1 &&
                    
                    <>
                     <div className="mb-4">
                    <Select
                        size='sm'
                        color='accent'
                        value={token1}
                        options={["USDC"]}
                        trLabel="Select the token you want to sell"
                        onClick={handleToken1Change} />

                    <Select
                        size='sm'
                        color='accent'
                        value={token2}
                        options={["AAVE" , "AVAX", "FXS", "JOE", "LINK", "MATIC", "MAKER", "SNX", "UNI", "WBTC", "WETH"]}
                        trLabel="Select the token you want to buy"
                        onClick={handleToken2Change} />
                </div>
                <div className="flex items-center space-x-4 mb-4">
                    <Input type="text" value={amount as string | number} onChange={handleAmountChange}
                        color='accent'
                        size="sm"
                        placeholder='How much to swap?'
                        trLabel='Set the amount (in USDC)' />
                </div>
                        <div className="mb-4">
                            <Select
                                size='sm'
                                color='accent'
                                value={timeRange}
                                options={["Hours", "Days", "Weeks", "Months"]}
                                trLabel="Select the swap interval"
                                onClick={handleTimeRangeChange} />

                        </div>
                        <div className="mb-4">
                            <Input type="number" value={timeUnit} onChange={(e) => setTimeUnit(Number(e.target.value))}
                                color='accent'
                                size="sm"
                                placeholder='How many?'
                            />

                        </div>
                    </>
                }
                {selectedTab === 2 && (
                <div>
                    <div className="mb-4">
                    <label className="block text-xs font-semibold text-accent">Action:</label>
                    <div className="flex items-center space-x-4">
                        <label className="flex items-center cursor-pointer">
                        <input
                            type="radio"
                            value="buy"
                            checked={limitOrderType === 'buy'}
                            onChange={() => setLimitOrderType('buy')}
                        />
                        <span className="ml-1">Buy</span>
                        </label>
                        <label className="flex items-center cursor-pointer">
                        <input
                            type="radio"
                            value="sell"
                            checked={limitOrderType === 'sell'}
                            onChange={() => setLimitOrderType('sell')}
                        />
                        <span className="ml-1">Sell</span>
                        </label>
                    </div>
                    </div>

                    {limitOrderType === 'buy' ? (
                    <div>
                        <div className="mb-4">
                        <label className="block text-xs font-semibold text-accent">Token to Sell:</label>
                        <Select
                            size="sm"
                            color="accent"
                            value={token1}
                            options={["USDC"]}
                            trLabel="Token to sell"
                            onClick={handleToken1Change}
                        />
                        </div>
                        <div className="mb-4">
                        <label className="block text-xs font-semibold text-accent">Token to Buy:</label>
                        <Select
                            size="sm"
                            color="accent"
                            value={token2}
                            options={["AAVE", "AVAX", "FXS", "JOE", "LINK", "MATIC", "MAKER", "SNX", "UNI", "WBTC", "WETH"]}
                            trLabel="Select the token you want to buy"
                            onClick={handleToken2Change}
                        />
                        </div>
                        <div className="mb-4">
                        <Input
                            type="text"
                            value={amount as string | number}
                            onChange={handleAmountChange}
                            color="accent"
                            size="sm"
                            placeholder={`How much USDC to swap?`}
                            trLabel={`Set the amount (in USDC)`}
                        />
                        </div>

                        <div className="mb-4">
                        <Input
                            type="number"
                            value={limitOrder}
                            onChange={(e) => setLimitOrder(Number(e.target.value))}
                            color="accent"
                            size="sm"
                            placeholder={`Set ${token2} price limit to buy`}
                            trLabel="At which price the swap will be executed"
                        />
                        </div>
                    </div>
                    ) : (
                    <div>
                        <div className="mb-4">
                        <label className="block text-xs font-semibold text-accent">Token to Sell:</label>
                        <Select
                            size="sm"
                            color="accent"
                            value={token1}
                            options={["AAVE", "AVAX", "FXS", "JOE", "LINK", "MATIC", "MAKER", "SNX", "UNI", "WBTC", "WETH"]}
                            trLabel="Select the token you want to sell"
                            onClick={handleToken1Change}
                        />
                        </div>
                        <div className="mb-4">
                        <label className="block text-xs font-semibold text-accent">Token to Buy:</label>
                        <Select
                            size="sm"
                            color="accent"
                            value={token2}
                            options={["USDC"]}
                            trLabel="Token to buy"
                            onClick={handleToken2Change}
                        />
                        </div>
                        <div className="mb-4">
                        <Input
                            type="text"
                            value={amount as string | number}
                            onChange={handleAmountChange}
                            color="accent"
                            size="sm"
                            placeholder={`How much ${token1} to swap?`}
                            trLabel={`Set the amount (in ${token1})`}
                        />
                        </div>

                        <div className="mb-4">
                        <Input
                            type="number"
                            value={limitOrder}
                            onChange={(e) => setLimitOrder(Number(e.target.value))}
                            color="accent"
                            size="sm"
                            placeholder={`Set ${token1} price limit to sell`}
                            trLabel="At which price the swap will be executed"
                            
                        />
                        </div>
                    </div>
                    )}

                    
                </div>
                )}



                <Button title="Proceed" color="warning" variant="block" isActive onClick={() => handleSubmit} />
            </form>
        </div>
    );
};

export default StrategyForm;
