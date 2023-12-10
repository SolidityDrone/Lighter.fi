import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { BrowserRouter } from "react-router-dom";
import LighterFi_ABI from "../src/LighterFi_ABI.json";
import 'bootstrap/dist/css/bootstrap.css';
import "./App.css"
import Web3 from 'web3';
const { Network, Alchemy } = require("alchemy-sdk");

// Optional Config object, but defaults to demo api-key and eth-mainnet.
const settings = {
  apiKey: process.env.REACT_APP_ALCHEMY_ID, // Replace with your Alchemy API Key.
  network: Network.MATIC_MUMBAI, // Replace with your network.
};

export const alchemy = new Alchemy(settings);


export const web3 = new Web3(Web3.givenProvider);
export const lighterfiAddress = "0xf79D99E640d5E66486831FD0BC3e36a29d3148C0";
const contract = new web3.eth.Contract(LighterFi_ABI, lighterfiAddress);


const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <div className='bg' >
      <BrowserRouter>

        <App />

      </BrowserRouter>
    </div>
  </React.StrictMode>
);
