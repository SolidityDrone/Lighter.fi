// Strategies.js
import React, { useEffect, useState } from 'react';
import { useQuery, gql } from '@apollo/client';
import { useAccount } from 'wagmi';
import { Table, Container, Button, Form } from 'react-bootstrap';
import WalletConnectDialog from './components/WalletConnectDialog';
import TransactionDialog from './components/TransactionDialog';
import LoadingWheel from './components/LoadingWheel';
import TokenData from '../Tokens.json'; // Adjust the path accordingly
import { lighterfiContract } from '..';
import LighterFiABI from '../LighterFi_ABI.json';
import { web3 } from '..';
// Function to map addresses to names
const getAddressNameMap = () => {
  const addressNameMap = {};
  TokenData.tokens.forEach((token) => {
    addressNameMap[token.address.toLowerCase()] = token.name;
  });
  return addressNameMap;
};

function Strategies() {
  const { address } = useAccount();
  const [strategiesData, setStrategiesData] = useState([]);
  const [filteredData, setFilteredData] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [processingTransaction, setProcessingTransaction] = useState(false);
  
  const [transactionMessage, setTransactionMessage] = useState('');
  const [selectedOffers, setSelectedOffers] = useState(null);
  const addressNameMap = getAddressNameMap(); // Map addresses to names

  const GET_STRATEGIES = gql`
    query GetStrategies($user: String!) {
      strategies(
        where: { type_not: "Deleted", user: $user }
        orderBy: type
        
      ) {
        limit
        limitAmountOut
        dcaVolume
        nextExecution
        strategyIndex
        timeInterval
        tokenIn
        tokenOut
        type
        amount
      }
    }
  `;
  
  useEffect(() => {
    if (transactionMessage) {
      const timeout = setTimeout(() => {
        setTransactionMessage('');
      }, 3500);

      return () => clearTimeout(timeout);
    }
  }, [transactionMessage]);


  const { loading, error, data } = useQuery(GET_STRATEGIES, {
    variables: { user: address },
    pollInterval: 5000,
    fetchPolicy: 'no-cache',
  });

  useEffect(() => {
    if (data) {
      setStrategiesData(data.strategies);
    }
  }, [data]);

  useEffect(() => {
    const filtered = strategiesData.filter((strategy) => {
      const tokenInName = addressNameMap[strategy.tokenIn?.toLowerCase()];
      const tokenOutName = addressNameMap[strategy.tokenOut?.toLowerCase()];
  
      return (
        (tokenInName && tokenInName.includes(searchTerm.toLowerCase())) ||
        (tokenOutName && tokenOutName.includes(searchTerm.toLowerCase()))
      );
    });
  
    setFilteredData(filtered);
  }, [searchTerm, strategiesData]);

  const formatTime = (timeInSeconds) => {
    const days = Math.floor(timeInSeconds / (24 * 60 * 60));
    const hours = Math.floor((timeInSeconds % (24 * 60 * 60)) / (60 * 60));
    const minutes = Math.floor((timeInSeconds % (60 * 60)) / 60);
    const seconds = Math.floor(timeInSeconds % 60);
  
    const formatValue = (value) => (value < 10 ? `0${value}` : value);
  
    return `${days}d ${formatValue(hours)}h ${formatValue(minutes)}m ${formatValue(seconds)}s`;
  };
  
  // Countdown component
  const Countdown = ({ targetTimestamp }) => {
    const [remainingTime, setRemainingTime] = useState(0);
  
    useEffect(() => {
      const interval = setInterval(() => {
        const now = Math.floor(Date.now() / 1000);
        const timeDifference = targetTimestamp - now;
        setRemainingTime(timeDifference > 0 ? timeDifference : 0);
      }, 1000);
  
      return () => clearInterval(interval);
    }, [targetTimestamp]);
  
    return <span>{formatTime(remainingTime)}</span>;
  };
  
  const handleUpdate = (strategyIndex) => {
    // Add logic for updating the strategy
    console.log(`Update strategy with index ${strategyIndex}`);
  };


  const handleDelete = async (strategyIndex) => {
    setProcessingTransaction(true);
  
    try {
      const lighterFiAddress = "0xf79D99E640d5E66486831FD0BC3e36a29d3148C0";
      const lighterfiContract = new web3.eth.Contract(LighterFiABI, lighterFiAddress);
      const tx = await lighterfiContract.methods.removeStrategy(strategyIndex).send({ from: address });
      setTransactionMessage('Transaction confirmed');
    } catch (error) {
      console.log(error);
      setTransactionMessage('Transaction failed');
    }
    setProcessingTransaction(false);
  };

  return (
    <>  {processingTransaction && (
  <LoadingWheel text="Waiting for confirmation..." />
)}
      {address ? (
        <Container>
          <div>
            <h2>Your strategies</h2>
            <div className="table-container">
              <Table striped bordered hover>
                <thead>
                  <tr>
                   
                    <th>
                      Type
                    </th>
                    <th onClick={() => handleSort('nextExecution')}>
                      Pair
                    </th>
                    <th>
                      Amount $
                    </th>
                    <th>
                      Time Interval
                    </th>
                    <th>
                      Next Execution
                    </th>
                    <th>
                      DCA Volume
                    </th>
                    <th>
                      Limit
                    </th>
                    <th>
                      Amount Out
                    </th>
       
                    <th>
          
                    </th>
             
                  </tr>
                </thead>
                <tbody>
                  {filteredData &&
                    filteredData.map((strategy) => (
                      <tr key={strategy.strategyIndex}>
                      
                        <td>
                          {strategy.type === 'Fulfilled' ? 'Limit' : strategy.type}
                        </td>
                        <td>
                          {addressNameMap[strategy.tokenIn?.toLowerCase()]} ➔ {addressNameMap[strategy.tokenOut?.toLowerCase()]}
                        </td>
                        <td>
                        {strategy.tokenIn !== '0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664'.toLowerCase() ? `Ξ${web3.utils.fromWei(strategy.amount, 'ether')}` : `$${(web3.utils.fromWei(strategy.amount, 'ether') * 1e12).toFixed(2)}` }
                        </td>
                        <td>
                          {strategy.type === 'Fulfilled' || strategy.type === 'Limit' ? '-' : formatTime(strategy.timeInterval)}
                        </td>
                        <td>
                          {strategy.type === 'Fulfilled' || strategy.type === 'Limit' ? '-' : <Countdown targetTimestamp={strategy.nextExecution} />}
                        </td>
                        <td>
                          {strategy.type === 'Limit' || strategy.type === 'Fulfilled' ? '-' : `$${strategy.dcaVolume}`}
                        </td>
                        <td>
                        {strategy.type === 'DCA' ? '-' : `$${(web3.utils.fromWei(strategy.limit, 'ether') * 1e12).toFixed(6)}`}

                        </td>
                        <td>
                          {strategy.type === 'Limit' ? '-' : strategy.limitAmountOut}
                        </td>
                        {/* Update Column */}
                        <td>
                          <Button variant="primary" onClick={() => handleUpdate(strategy.strategyIndex)}>Update</Button>
                        </td>
                        {/* Delete Column */}
                        <td>
                          <Button variant="danger" onClick={() => handleDelete(strategy.strategyIndex)}>Delete</Button>
                        </td>
                      </tr>
                    ))}
                </tbody>
              </Table>
            </div>
          </div>
        </Container>
      ) : (
        <WalletConnectDialog />
      )}
       {transactionMessage && <TransactionDialog message={transactionMessage} />} 
      {loading && (
        <LoadingWheel text="Loading strategies..." />
      )}
    </>
  );
}


export default Strategies;
