import { FC } from 'react'
import Button from '../common/button';

interface Props {
  timeRange: any,
  limit: any,
  limitOrderType: any,
  token1: any,
  token2: any,
  amount: any,
  confirm: () => void
}

const DataRecap: FC<Props> = ({
  timeRange,
  limit,
  limitOrderType,
  token1,
  token2,
  amount,
  confirm
}) => {
  
  let recapText = '';

  if (limit) {
    if (limitOrderType) {
      recapText = `You're creating a limit order strategy swapping ${amount} USDC for ${token2} when the price of ${token2} will be ${limit}`;
    } else if (!limitOrderType) {
      recapText = `You're creating a limit order strategy swapping ${amount} ${token2} for USDC when the price of ${token2} will be ${limit}`;
    }
  } else {
    recapText = `You're creating a DCA strategy swapping ${amount} USDC for ${token2} every ${timeRange}`;
  }

  return (
    <div className="flex flex-col items-center">
      <ul>
        <li>
          {recapText}
        </li>
      </ul>
      <br />
      <Button title="Create Strategy" color="accent" variant="wide" isActive onClick={() => confirm()} />
    </div>
  );
};

export default DataRecap;
