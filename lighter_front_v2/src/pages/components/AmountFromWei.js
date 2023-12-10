import React from 'react';

const AmountFromWei = ({ amount }) => {
  const result = amount.slice(0, amount.indexOf('.') + 5);

  return <>{result}</>;
};

export default AmountFromWei;