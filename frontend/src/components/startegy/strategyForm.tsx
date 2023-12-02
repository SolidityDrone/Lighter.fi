'use client'
import React, { FormEvent, useEffect, useState } from 'react';
import Button from '../common/button';
import Input from '../common/input';
import Select from '../common/select';
import Modal from '../common/modal';
import DataRecap from './dataRecap';
import { useCreateStrategy } from '@/contracts/LighterFI';
import { availableTokensType } from '@/contracts/tokens';
import Loading from '../common/loading';
import Link from 'next/link';

const TimeRangeStrategyForm = () => {

    const [timeRange, setTimeRange] = useState<string>('hours');
    const [timeUnit, setTimeUnit] = useState<number | string>(24);
    const [token1, setToken1] = useState('USDC');
    const [token2, setToken2] = useState('WBTC');
    const [amount, setAmount] = useState('');
    const [isRecapModalOpen, setIsRecapModalOpen] = useState(false);
    const [isLoadingModalOpen, setIsLoadingModalOpen] = useState(false);
    const [isSuccessModalOpen, setIsSuccessModalOpen] = useState(false);

    const { isCreateStrategyLoading, isCreateStrategySuccess, createStrategyData, createStrategyWrite } = useCreateStrategy(timeRange, timeUnit, token1, token2 as unknown as availableTokensType, amount)

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
    }, [timeUnit])

    return (
        <div className="max-w-xl mx-auto mt-8 p-6 bg-neutral rounded-md shadow-md">
            <Modal isOpen={isRecapModalOpen}
                title="Check Details And Create Strategy"
                closeModal={() => openCloseRecapModal()}
                children={<DataRecap
                    timeRange={`${timeUnit} ${timeRange}`}
                    amount={amount}
                    token1={token1}
                    token2={token2}
                    confirm={createStrategyWrite} />} />
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
            <form onSubmit={handleSubmit}>
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
                        placeholder='How much to swap?'
                    />

                </div>
                <div className="mb-4">
                    <Select
                        size='sm'
                        color='accent'
                        value={token1}
                        options={["USDC"]}
                        trLabel="Select the token you want to put"
                        onClick={handleToken1Change} />

                    <Select
                        size='sm'
                        color='accent'
                        value={token2}
                        options={["WETH", "WBTC", "LINK"]}
                        trLabel="Select the token you want to get"
                        onClick={handleToken2Change} />
                </div>
                <div className="flex items-center space-x-4 mb-4">
                    <Input type="text" value={amount} onChange={handleAmountChange}
                        color='accent'
                        size="sm"
                        placeholder='How much to swap?'
                        trLabel='Set the amount (in USDC)' />
                </div>
                <Button title="Proceed" color="warning" variant="block" isActive onClick={() => handleSubmit} />
            </form>
        </div>
    );
};

export default TimeRangeStrategyForm;
