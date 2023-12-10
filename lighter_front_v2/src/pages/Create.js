import { useQuery, gql } from '@apollo/client';
import { useAccount } from 'wagmi';
import {  Table, Container, Button, Row, Col, Form } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import { web3 } from '../index';
import { lighterfiAddress } from '../index';
import DealCountdown from './components/CountDown';
import AmountFromWei from './components/AmountFromWei';
import polygonLogo from '../../src/assets/polygon-logo.svg';
import LoadingWheel from './components/LoadingWheel';
import TransactionDialog from './components/TransactionDialog';
import WalletConnectDialog from './components/WalletConnectDialog';
import TokenData from '../Tokens.json'; // Adjust the path accordingly
import LighterFiABI from '../LighterFi_ABI.json';
import ERC20_ABI from '../IERC20_ABI.json';



function Create() {

  const { address } = useAccount();
  const [strategyType, setStrategyType] = useState('');
  const [tokenIn, setTokenIn] = useState('');
  const [tokenOut, setTokenOut] = useState('');
  const [amount, setAmount] = useState('');
  const [timeInterval, setTimeInterval] = useState('');
  const [limitPrice, setLimitPrice] = useState('');
  const [transactionMessage, setTransactionMessage] = useState('');
  const [processingTransaction, setProcessingTransaction] = useState(false);
  const [originalTokenIn, setOriginalTokenIn] = useState('');
  const [prices, setPrices] = useState([]);
  const tokens = ['AVAX', 'LINK', 'WETH', 'WBTC', 'AAVE', 'SUSHI'];

  const getPrices = async () => {
    try {
      const lighterFiAddress = "0xf79D99E640d5E66486831FD0BC3e36a29d3148C0";
      const lighterfiContract = new web3.eth.Contract(LighterFiABI, lighterFiAddress);
      const newPrices = await lighterfiContract.methods._batchQuery().call();
     
      setPrices(newPrices);
      console.log('Prices updated:', newPrices);
    } catch (error) {
      console.error('Error fetching prices:', error);
    }
  };
  
  
  const renderTokenPrices = () => {
    if (strategyType === 'Limit') { // Only render if strategyType is 'Limit'
      const halfLength = Math.ceil(prices.length / 2);

      const leftColumn = prices.slice(0, halfLength);
      const rightColumn = prices.slice(halfLength);

      const renderColumn = (column) => {
        return (
          <ul style={{ listStyleType: 'none', marginTop: '14px' }}>
            {column.map((number, index) => (
              <li key={index} style={{ marginBottom: '-2px', fontSize: '12px' }}>
                {`${tokens[index]}: $${(Number(web3.utils.fromWei(number.toString(), 'ether')) * 1e12).toFixed(2)}`}
              </li>
            ))}
          </ul>
        );
      };

      return (
        <div style={{ display: 'flex', gap: '1px' }}>
          <div style={{ flex: '1' }}>{renderColumn(leftColumn)}</div>
          <div style={{ flex: '1' }}>{renderColumn(rightColumn)}</div>
        </div>
      );
    }

    return null;
  };
  
  useEffect(() => {
    // Define a function to call getPrices every 15 seconds
    const fetchData = async () => {
      await getPrices();
    };

    // Call fetchData initially
    fetchData();

    // Set up an interval to call fetchData every 15 seconds
    const intervalId = setInterval(fetchData, 15000);

    // Clean up the interval on component unmount
    return () => clearInterval(intervalId);
  }, []); // The empty dependency array ensures that useEffect runs only once after the initial render




  const handleSubmit = async (e) => {
    e.preventDefault();
    setProcessingTransaction(true);

    
    try {

      
      const lighterFiAddress = "0xf79D99E640d5E66486831FD0BC3e36a29d3148C0";
      const lighterfiContract = new web3.eth.Contract(LighterFiABI, lighterFiAddress);
      const tokenContract = new web3.eth.Contract(ERC20_ABI, '0xd8b917cf32022e35E09Bac2c6F16a64fa7D1DEC9');

      const allowance = await tokenContract.methods.allowance(address, lighterFiAddress).call();
      if (web3.utils.toBN(allowance).lt(web3.utils.toBN(web3.utils.toWei(amount)))) {
       await tokenContract.methods.approve(lighterFiAddress, amount).send({ from: address });
      }
      
      
      

      if (strategyType === 'DCA') {
        const tokenFrom = '0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664';
        const tokenTo = tokenOut;
        const timeIntervalValue = web3.utils.toBN((timeInterval.toString()));
        const tokenInAmount = (web3.utils.toBN(web3.utils.toWei(amount.toString(), 'ether'))).toString().slice(0, -12);
        const limit = web3.utils.toBN(0);

        await lighterfiContract.methods.createStrategy(tokenFrom, tokenTo, timeIntervalValue, tokenInAmount, limit)
          .send({ from: address });

        setTransactionMessage('Transaction confirmed');
      } else if (strategyType === 'Limit') {
        const tokenFrom = tokenIn;
        const tokenTo = tokenOut;
        const timeIntervalValue = web3.utils.toBN(0);
        let tokenInAmount = web3.utils.toBN(web3.utils.toWei(amount.toString(), 'ether')).toString();
        const limit = web3.utils.toBN(web3.utils.toWei(limitPrice.toString(), 'ether')).toString().slice(0, -12);
        
        if (tokenIn === '0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664' ){
          tokenInAmount = tokenInAmount.slice(0, -12);
        }

        await lighterfiContract.methods.createStrategy(tokenFrom, tokenTo, timeIntervalValue, tokenInAmount, limit)
          .send({ from: address });

        setTransactionMessage('Transaction confirmed');
      }
    } catch (error) {
      console.log(error);
      setTransactionMessage('Transaction failed');
    }

    setProcessingTransaction(false);
  };



  useEffect(() => {
    if (transactionMessage) {
      const timeout = setTimeout(() => {
        setTransactionMessage('');
      }, 6500);

    }
  }, [transactionMessage]);

  useEffect(() => {
    // If DCA is selected, set tokenIn to the address of USDC
    if (strategyType === 'DCA') {
      setTokenIn('0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664');
    } else if (strategyType === 'Limit') {
      // Listen to changes in tokenIn and tokenOut
      if (tokenIn !== '0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664' && tokenOut !== '0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664') {
        // If tokenIn is different from USDC, set tokenOut to USDC
        setTokenIn('0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664');
      } 
    }
  }, [strategyType, tokenIn, tokenOut]);



  const renderStrategyFields = () => {
    
    if (strategyType === 'DCA') {
      return (
     
        <>
          
          {processingTransaction && (
          <LoadingWheel text="Waiting for confirmation..." />
        )}
    
          <Form.Group className="mb-3" controlId="amount">
            <Form.Label>Amount</Form.Label>
            <Form.Control
              type="number"
              placeholder="Enter amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              required
            />
          </Form.Group>

          <Form.Group className="mb-3" controlId="timeInterval">
            <Form.Label>Time Interval (in seconds)</Form.Label>
            <Form.Control
              type="number"
              placeholder="Enter time interval"
              value={timeInterval}
              onChange={(e) => setTimeInterval(e.target.value)}
              required
            />
          </Form.Group>
        </>
      );
    } else if (strategyType === 'Limit') {
      return (
        <>
         {processingTransaction && (
          <LoadingWheel text="Waiting for confirmation..." />
        )}
          <Form.Group className="mb-3" controlId="amount">
            <Form.Label>Amount</Form.Label>
            <Form.Control
              type="number"
              placeholder="Enter amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              required
            />
          </Form.Group>

          <Form.Group className="mb-3" controlId="limitPrice">
            <Form.Label>Limit Price (in dollars)</Form.Label>
            <Form.Control
              type="number"
              placeholder="Enter limit price"
              value={limitPrice}
              onChange={(e) => setLimitPrice(e.target.value)}
              required
            />
          </Form.Group>
        </>
      );
    }

    return null;
  };

  return (
    <>
      <Container>
        <div className="formBox">
          <div className="formInner">
            <h2>Create a Strategy</h2>

            <Form onSubmit={handleSubmit}>
              <Form.Group className="mb-3" controlId="strategyType">
                <Form.Label>Strategy Type</Form.Label>
                <Form.Control
                  as="select"
                  value={strategyType}
                  onChange={(e) => setStrategyType(e.target.value)}
                  required
                >
                  <option value="" disabled>Select Strategy Type</option>
                  <option value="DCA">DCA</option>
                  <option value="Limit">Limit Order</option>
                </Form.Control>
              </Form.Group>

              <Row className="mb-3">
                <Col>
                  <Form.Group controlId="tokenIn">
                    <Form.Label>Token In</Form.Label>
                    <Form.Control
                      as="select"
                      value={tokenIn}
                      onChange={(e) => setTokenIn(e.target.value)}
                      required
                      disabled={strategyType === 'DCA'}
                    >
                      <option value="" disabled>Select Token In</option>
                      {TokenData.tokens.map((token) => (
                        <option key={token.address} value={token.address}>
                          {token.name}
                        </option>
                      ))}
                    </Form.Control>
                  </Form.Group>
                </Col>
                <Col>
                  <Form.Group controlId="tokenOut">
                    <Form.Label>Token Out</Form.Label>
                    <Form.Control
                      as="select"
                      value={tokenOut}
                      onChange={(e) => setTokenOut(e.target.value)}
                      required
                    >
                      <option value="" disabled>Select Token Out</option>
                      {TokenData.tokens.map((token) => (
                        <option key={token.address} value={token.address}>
                          {token.name}
                        </option>
                      ))}
                    </Form.Control>
                  </Form.Group>
                </Col>
              </Row>

              {strategyType === 'Limit' && renderTokenPrices()} {/* Display token prices only if strategyType is 'Limit' */}
              {renderStrategyFields()}

              <Button variant="primary" type="submit" disabled={processingTransaction || !address}>
                {processingTransaction ? 'Processing...' : 'Create Strategy'}
              </Button>
            </Form>
          </div>
        </div>
      </Container>

      {transactionMessage && <TransactionDialog message={transactionMessage} />} 
    </>
  );
}


export default Create;