"use client"
import React, { useEffect, useState } from 'react';
import Table from '../common/table';
import Button from '../common/button';
import Modal from '../common/modal';
import StrategyRecap from './strategyRecap';
import { availableTokens } from '@/contracts/tokens';
import Logo from '../layout/logo';
import { ApolloClient, InMemoryCache, gql } from '@apollo/client'
import { useQueryHook } from './theGraphHook';
import { useAccount } from 'wagmi';


const StrategyTable = () => {
    // Sample data for the table
    const [selected, setSelected] = useState<Number>(0)


    const tableHeaders = ["ID", "Type","Start Date", "Next Execution","Interval","tokenIn","tokenOut"]





    return (
        <div className="mx-auto mt-8 p-6 bg-neutral rounded-md shadow-md">
            <h2> My Strategies</h2>
            <Table headers={tableHeaders} />
        </div>
    );
};

export default StrategyTable;