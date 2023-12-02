'use client'

import { FC } from 'react'
import Button from '../common/button';
import { useCreateStrategy } from '@/contracts/LighterFI';

interface Props {
  timeRange: any,
  token1: any,
  token2: any,
  amount: any,
  confirm: () => void
}

const DataRecap: FC<Props> = ({
  timeRange,
  token1,
  token2,
  amount,
  confirm
}) => {
  
  return (
    <div className="flex flex-col items-center">
      <p>The swap will happen every {timeRange}.</p>
      <ul>
        <li>
          <strong>You're swapping </strong> {amount} {token1} <strong>To</strong> {token2}
        </li>
      </ul>
      <br/>
       <Button title="Create Strategy" color="accent" variant="wide" isActive onClick={() => confirm()} />
    </div>
  );
};

export default DataRecap;
