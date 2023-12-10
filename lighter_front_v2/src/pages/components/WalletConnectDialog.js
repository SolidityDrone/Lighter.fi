import React from 'react';
import './WalletConnectDialog.css';
import { Web3Button  } from "@web3modal/react";

const WalletConnectDialog = () => {
  return (
    <div className="wallet-dialog-overlay">
      <div className="wallet-dialog">
        <h2>Connect Your Wallet</h2>
        <p>To proceed, please connect your wallet.</p>
        
              <Web3Button  className="web3button"/>
    
      </div>
    </div>
  );
};

export default WalletConnectDialog;