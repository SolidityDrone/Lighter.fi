import React, { FormEvent, useEffect, useState } from 'react';
import Button from '../common/button';
import Input from '../common/input';
import Select from '../common/select';

const StrategyForm = () => {
    const [timeRange, setTimeRange] = useState<string>('hours');
    const [timeUnit, setTimeUnit] = useState<number | string>(24);
    const [token1, setToken1] = useState('USDC');
    const [token2, setToken2] = useState('WBTC');
    const [amount, setAmount] = useState('');

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
        console.log("e.target.value", e.target.value)
        console.log("token2", token2)
    };

    const handleAmountChange = (e: any) => {
        setAmount(e.target.value);
        console.log("amount", amount)
    };

    const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        // Handle form submission logic here
        console.log('Time Range:', timeRange);
        console.log('Token Pair:', `${token1}/${token2}`);
        console.log('Amount:', amount);
    };

    useEffect(() => {
        if (timeUnit == 0) setTimeUnit("")
    }, [timeUnit])

    return (
        <div className="max-w-xl mx-auto mt-8 p-6 bg-neutral rounded-md shadow-md">
            <form onSubmit={handleSubmit}>
                <div className="mb-4">
                    <Select
                        size='sm'
                        color='accent'
                        value={timeRange}
                        options={["Hours", "Days", "Weeks", "Months"]}
                        trLabel="Time Range"
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
                        trLabel="Token Getting Swapped From"
                        onClick={handleToken1Change} />

                    <Select
                        size='sm'
                        color='accent'
                        value={token2}
                        options={["WBTC", "LINK"]}
                        trLabel="Token Getting Swapped to"
                        onClick={handleToken2Change} />
                </div>
                <div className="flex items-center space-x-4 mb-4">
                    <Input type="text" value={amount} onChange={handleAmountChange}
                        color='accent'
                        size="sm"
                        placeholder='How much to swap?'
                        trLabel='Amount in USDC' />
                </div>
                <Button title="Proceed" color="warning" variant="block" isActive onClick={() => handleSubmit} />
            </form>
        </div>
    );
};

export default StrategyForm;
