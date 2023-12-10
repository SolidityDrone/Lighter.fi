import { Navbar, Container, Nav } from "react-bootstrap";
import githublogo from './assets/svg-github.png';
import { Link } from "react-router-dom";
import {
  EthereumClient,
  w3mConnectors,
  w3mProvider,
} from "@web3modal/ethereum";
import { Web3Button, Web3Modal } from "@web3modal/react";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import { avalancheFuji } from "wagmi/chains";
import { Route, Routes } from "react-router-dom";
import Home from "./pages/Home";

import Strategies from "./pages/Strategies.js";
import Create from "./pages/Create.js";

import { ApolloClient, ApolloProvider, InMemoryCache } from "@apollo/client";
import { useState, useEffect} from 'react';


// 1. Get projectID at https://cloud.walletconnect.com
if (!process.env.REACT_APP_PROJECT_ID) {
  throw new Error("You need to provide REACT_APP_PROJECT_ID env variable");
}
const projectId = process.env.REACT_APP_PROJECT_ID;

// 2. Configure wagmi client
const chains = [avalancheFuji];

const { provider } = configureChains(chains, [w3mProvider({ projectId })]);
const wagmiClient = createClient({
  autoConnect: true,
  connectors: w3mConnectors({ version: 1, chains, projectId }),
  provider,
});

// 3. Configure modal ethereum client
export const ethereumClient = new EthereumClient(wagmiClient, chains);



const lighterfi = new ApolloClient({
  uri: 'https://api.thegraph.com/subgraphs/name/soliditydrone/lighter-fi',
  cache: new InMemoryCache()
});


export default function App() {
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const checkNetwork = async () => {
      try {
        const networkId = await ethereumClient.getNetworkId();
        const isConnectedToAvalancheFuji = networkId === avalancheFuji.networkId;
        setIsConnected(isConnectedToAvalancheFuji);

        if (!isConnectedToAvalancheFuji) {
          // Automatically prompt user to switch network using Wagmi client
          const wagmiClientStatus = await wagmiClient.getStatus();
          if (wagmiClientStatus.connected && wagmiClientStatus.connectorId === 'walletconnect') {
            await wagmiClient.disconnect(); // Disconnect existing connection
          }
          await wagmiClient.connect(); // Connect to WalletConnect and prompt user to switch network
        }
      } catch (error) {
        console.error("Error checking network:", error);
      }
    };

    checkNetwork();
  }, []);
  return (
    <WagmiConfig client={wagmiClient}>
      <NavMain />
      <ApolloProvider client={lighterfi}>
  <Routes>
    <Route path="/" element={<Home />} />
    <Route path="/strategies" element={<Strategies />} />
    <Route path="/create" element={<Create />} />
  </Routes>
</ApolloProvider>

      <Web3Modal projectId={projectId} ethereumClient={ethereumClient} />
    </WagmiConfig>
  );
}


function NavMain() {
  const [expanded, setExpanded] = useState(false);
  const [fadeAnimation, setFadeAnimation] = useState('');

  const handleNavToggle = () => {
    setExpanded(!expanded);
    setFadeAnimation(expanded ? 'fade-out' : 'fade-in');
  };
  useEffect(() => {
    const wagmiBtnContainer = document.querySelector('.wagmi-btn-container');
    wagmiBtnContainer.classList.toggle('open', expanded);
    wagmiBtnContainer.classList.toggle('fade-out', fadeAnimation === 'fade-out');
    wagmiBtnContainer.classList.toggle('fade-in', fadeAnimation === 'fade-in');
    if (fadeAnimation) {
      const timeout = setTimeout(() => {
        setFadeAnimation('');
      }, 400);
      return () => clearTimeout(timeout);
    }
  }, [expanded, fadeAnimation]);



  const handleNavItemClick = () => {
    setExpanded(false);
  };

  return (
    <>
      <Navbar id="navbar" className="nav" variant="dark" fixed="top" expand="lg" expanded={expanded} z-index="2">
        <Container fluid>
          <Navbar.Brand href="#home">
            <Link onClick={handleNavItemClick} to="/"> 
              <img
                alt=""
                //src={logo}
                height="42"
                className="d-inline-block align-top"
              />
            </Link>
           
          </Navbar.Brand>
          <Navbar.Toggle
  aria-controls="basic-navbar-nav"
  onClick={handleNavToggle}
  style={{ fontSize: '0.8rem', padding: '0.25rem 0.5rem' }}
/>
          <Navbar.Collapse className="justify-content-end">
            <Nav className="me-auto">
              <Link onClick={handleNavItemClick} className="nav-links" to="/">Home</Link>
              <Link onClick={handleNavItemClick} className="nav-links" to="/Create">Create</Link>
              <Link onClick={handleNavItemClick} className="nav-links" to="/Strategies">Orders</Link>
            </Nav>
            <a
              className="github-button"
              href="https://github.com/SolidityDrone/onchain_dca/tree/main"
              target="_blank"
              rel="noopener noreferrer"
            >
              <img
                alt="GitHub"
                src={githublogo}
                height="30"
                className="social-logo"
              />
            </a>
            <div className="wagmi-btn-container">
  
              <Web3Button  className="web3button"/>
  
            </div>
          </Navbar.Collapse>
        </Container>
      </Navbar>
      <div className="navbar-distancer"></div>
    </>
  );
}