import React, { useState } from 'react';
import './TransactionDialog.css';
const TransactionDialog = ({ message }) => {
  


  return (
    <>
    
                <div className="alertTab">
                {message}
                   
                </div>
 
      
    </>
  );
};

export default TransactionDialog;