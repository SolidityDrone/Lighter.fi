import { FC, useEffect, useState } from 'react'
import ReactPaginate from 'react-paginate'
import Modal from './modal'
import StrategyRecap from '../account/strategyRecap'
import { useRemoveStrategy } from '@/contracts/lighterfi/methods'
import { Strategy, useQueryHook } from '../account/theGraphHook'
import { allowedTokens, availableTokens } from '@/contracts/tokens'
import Logo from '../layout/logo'

interface Props {
  headers: string[]
}



const  formatTimestamp = (timestamp: string): string  => {
  const date = new Date(parseInt(timestamp, 10) * 1000); // Assuming the timestamp is in seconds, multiply by 1000 for milliseconds

  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');

  return `${day}/${month}/${year}`;
}

const formatTimeInterval = (intervalInSeconds: number): string => {
  const minutes = intervalInSeconds / 60;
  const hours = minutes / 60;
  const days = hours / 24;
  const weeks = days / 7;
  const months = days / 30;

  if (months >= 1) {
    return `${Math.floor(months)} months`;
  } else if (weeks >= 1) {
    return `${Math.floor(weeks)} weeks`;
  } else if (days >= 1) {
    return `${Math.floor(days)} days`;
  } else if (hours >= 1) {
    return `${Math.floor(hours)} hours`;
  } else {
    return `${Math.floor(minutes)} minutes`;
  }
};


  const getLogo = (address: string) => {
    let el
    let addr
    switch (address) {
      case allowedTokens.polygonMumbai.WMATIC: 
        el = <Logo title="" path='/polygon-matic-logo.svg' />
        addr = allowedTokens.polygonMumbai.WMATIC
        break;
      case allowedTokens.polygonMumbai.USDC:
        el = <Logo title="" path='/usdc-logo.png' />
        addr = allowedTokens.polygonMumbai.USDC

        break;
     

      default:
        break;
    }
    return {
      logo: <div className="w-10 h-10 rounded-full">{el}</div>,
      address: addr
    }


  }

const Table: FC<Props> = ({ headers }) => {
  const itemsPerPage = 5;
  const [currentPage, setCurrentPage] = useState(0);
  const [pagesNumber, setPagesNumber] = useState(0);
  const [strategyIndex, setStrategyIndex] = useState<Number>(0);
  const [strategyType, setStrategyType] = useState<string>("");
  const [interval, setInterval] = useState<string>("");
  const [tokenAddress, setTokenAddress] = useState<string>("");
  const [logo, setLogo] = useState<any>();
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [displayedData, setDisplayedData] = useState<Strategy[]>
    ([]);
  const { strategies } = useQueryHook()

  const handlePageClick = (selected: any) => {
    setCurrentPage(selected);
  };
  useEffect(() => {
    if (strategies) {
      const s = strategies as any
      const dd = s?.slice(
        currentPage * itemsPerPage,
        (currentPage + 1) * itemsPerPage
      );

      setDisplayedData(dd)

    }
  }, [strategies, currentPage])

  const handleOpenModal = (id: Number, type: string, interval: string, addr: string, tokenLogo: any) => {
    setStrategyIndex(id)
    setStrategyType(type)
    setTokenAddress(addr)
    setLogo(tokenLogo)
    setIsDetailModalOpen(true)
    setInterval(interval)
  }



  useEffect(() => {
    if (strategies) {
      const s = strategies as any
      setPagesNumber(Math.ceil(s?.length / 5))
    }
  }, [strategies])





const  formatTimestamp = (timestamp: string): string  => {
  const date = new Date(parseInt(timestamp, 10) * 1000); // Assuming the timestamp is in seconds, multiply by 1000 for milliseconds

  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');

  return `${day}/${month}/${year}`;
}

const formatTimeInterval = (intervalInSeconds: number): string => {
  const minutes = intervalInSeconds / 60;
  const hours = minutes / 60;
  const days = hours / 24;
  const weeks = days / 7;
  const months = days / 30;

  if (months >= 1) {
    return `${Math.floor(months)} months`;
  } else if (weeks >= 1) {
    return `${Math.floor(weeks)} weeks`;
  } else if (days >= 1) {
    return `${Math.floor(days)} days`;
  } else if (hours >= 1) {
    return `${Math.floor(hours)} hours`;
  } else {
    return `${Math.floor(minutes)} minutes`;
  }
};





  return (
    <div className="overflow-x-auto">
      <Modal isOpen={isDetailModalOpen}
        title="Strategy Recap"
        children={<StrategyRecap
          id={strategyIndex.toString()}
          interval={Number(interval)}
          tokenAddress={tokenAddress}
          tokenLogo={logo}
          type={strategyType}
          limit={2000}
          amount={100}
        />}
        closeModal={() => setIsDetailModalOpen(false)} />

      <table className="table">
        <thead>
          <tr>
            {headers.map((header, index) => (
              <th key={index}>{header}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {displayedData?.map((rowData, rowIndex) => (
            <tr key={rowIndex}
              className="hover cursor-pointer"
              onClick={() => handleOpenModal(Number(rowData.id), rowData.type, rowData.amount,rowData.tokenIn,getLogo( rowData.tokenIn).logo)}>
              <td key={1}>{rowData.id}</td>
              <td key={4}>{rowData.type}</td>
              <td key={2}>{formatTimestamp(rowData.blockTimestamp)}</td>
              <td key={2}>{formatTimestamp(rowData.nextExecution)}</td>
              <td key={2}>{formatTimeInterval(Number(rowData.timeInterval))}</td>
              <td key={3}>{
                getLogo( rowData.tokenIn).logo
                // rowData.tokenIn
             }</td>
              <td key={3}>{
                getLogo(rowData.tokenOut).logo
              //  rowData.tokenOut
              }</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex items-center justify-center mt-4">
        {
          Array.from({ length: pagesNumber }, (_, index) => (
            <div
              key={index}
              className={`cursor-pointer mx-2 px-3 py-1 rounded-full ${currentPage === index ? 'bg-gray-500 text-white' : 'bg-gray-200'
                }`}
              onClick={() => handlePageClick(index)}
            >
              {index + 1}
            </div>
          ))}
      </div>
    </div>
  )
}

export default Table
