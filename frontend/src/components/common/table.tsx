import { FC, useEffect, useState } from 'react'
import ReactPaginate from 'react-paginate'
import Modal from './modal'
import StrategyRecap from '../account/strategyRecap'
import { useRemoveStrategy } from '@/contracts/lighterfi/methods'

interface Props {
  headers: string[]
  data: tableData[]
}

type tableData = {
  id: string,
  type: string,
  token: {logo:React.JSX.Element,address:string},
  nswap: string
}

const Table: FC<Props> = ({ headers, data }) => {
  const itemsPerPage = 5;
  const [currentPage, setCurrentPage] = useState(0);
  const [pagesNumber, setPagesNumber] = useState(0);
  const [strategyIndex, setStrategyIndex] = useState<Number>(0);
  const [strategyType, setStrategyType] = useState<string>("");
  const [nswap, setNswap] = useState<string>("");
  const [tokenAddress, setTokenAddress] = useState<string>("");
  const [logo, setLogo] = useState<any>();
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);


  const handlePageClick = (selected: any) => {
    setCurrentPage(selected);
  };
  const displayedData = data.slice(
    currentPage * itemsPerPage,
    (currentPage + 1) * itemsPerPage
  );

  const handleOpenModal = (id: Number, type: string, swap: string, addr: string,tokenLogo:any) => {
    setStrategyIndex(id)
    setStrategyType(type)
    setNswap(swap)
    setTokenAddress(addr)
    setLogo(tokenLogo)
    setIsDetailModalOpen(true)
  }



  useEffect(() => {
    setPagesNumber(Math.ceil(data.length / 5))
  })





  return (
    <div className="overflow-x-auto">
      <Modal isOpen={isDetailModalOpen}
        title="Strategy Recap"
        children={<StrategyRecap
          id={strategyIndex.toString()}
          nSwap={nswap}
          tokenAddress={tokenAddress}
          tokenLogo={logo}
          type={strategyType}
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
          {displayedData.map((rowData, rowIndex) => (
            <tr key={rowIndex}
              className="hover cursor-pointer"
              //id: Number, type: string, swap: string, addr: string,tokenLogo:any
              onClick={()=> handleOpenModal(Number(rowData.id),rowData.type,rowData.nswap, rowData.token.address,rowData.token.logo)}>
              <td key={1}>{rowData.id}</td>
              <td key={2}>{rowData.token.logo}</td>
              <td key={3}>{rowData.nswap}</td>
              <td key={4}>{rowData.type}</td>
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
