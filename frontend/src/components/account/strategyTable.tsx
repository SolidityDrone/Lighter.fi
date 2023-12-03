import React, { useState } from 'react';
import Table from '../common/table';
import Button from '../common/button';
import Modal from '../common/modal';
import StrategyRecap from './strategyRecap';
import { availableTokens } from '@/contracts/tokens';
import Logo from '../layout/logo';

const logo = (address: string) => {
    let el
    let addr
    switch (address) {
        case availableTokens.polygonMumbai.WBTC:
            el = <Logo title="" path='/wbtc-logo.jpeg' />
            addr = availableTokens.polygonMumbai.WBTC
            break;
        case availableTokens.polygonMumbai.LINK:
            el = <Logo title="" path='/chainlink-logo.svg' />
            addr = availableTokens.polygonMumbai.LINK

            break;
        case availableTokens.polygonMumbai.WETH:
            el = <Logo title="" path='/weth-logo.png' />
            addr = availableTokens.polygonMumbai.WETH

            break;

        default:
            break;
    }
    return {
        logo: <div className="w-10 h-10 rounded-full">{el}</div>,
        address: addr
    }


}
const StrategyTable = () => {
    // Sample data for the table
    const [selected, setSelected] = useState<Number>(0)

    const tableHeaders = ["ID", "type", "Token To", "N of Purchases"]
    const tableData = [
        { id: "1", type: "DCA", token: logo(availableTokens.polygonMumbai.WBTC), nswap: "2" },
        { id: "2", type: "limit Order", token: logo(availableTokens.polygonMumbai.LINK), nswap: "1" },
        { id: "3", type: "limit Order", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" },
        { id: "3", type: "limit Order", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" },
        { id: "4", type: "DCA", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" },
        { id: "5", type: "DCA", token: logo(availableTokens.polygonMumbai.LINK), nswap: "1" },
        { id: "6", type: "limit Order", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" },
        { id: "7", type: "limit Order", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" },
        { id: "8", type: "limit Order", token: logo(availableTokens.polygonMumbai.LINK), nswap: "1" },
        { id: "9", type: "DCA", token: logo(availableTokens.polygonMumbai.WBTC), nswap: "1" },
        { id: "10", type: "limit Order", token: logo(availableTokens.polygonMumbai.LINK), nswap: "1" },
        { id: "11", type: "limit Order", token: logo(availableTokens.polygonMumbai.LINK), nswap: "1" },
        { id: "12", type: "DCA", token: logo(availableTokens.polygonMumbai.WETH), nswap: "1" }
    ];



    //  const [tableData, setTableData] = useState(initialData);
    const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);

    return (
        <div className="mx-auto mt-8 p-6 bg-neutral rounded-md shadow-md">
            <h2>Your Strategies</h2>
            <Table headers={tableHeaders} data={tableData as any} />
        </div>
    );
};

export default StrategyTable;
