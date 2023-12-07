import { FC, useState } from 'react'
import Button from '../common/button';
import { useRemoveStrategy } from '@/contracts/lighterfi/methods';
import { useWaitForTransaction } from 'wagmi';
import Modal from '../common/modal';
import Loading from '../common/loading';
import StrategyForm from '../startegy/strategyForm';

interface Props {
  id: string,
  interval: Number,
  limit: Number
  tokenAddress: string,
  tokenLogo: any,
  type: string,
  amount: Number,
  // updateStrategy: () => void
  // deleteStrategy: () => void
}

const StrategyRecap: FC<Props> = ({
  interval,
  id,
  limit,
  tokenAddress,
  tokenLogo,
  type,
  amount,
  // updateStrategy,
  // deleteStrategy
}) => {

  const { removeStrategyData, isRemoveStrategyLoading, removeStrategyWrite } = useRemoveStrategy(Number(id))
  const [isLoadingModalOpen, setIsLoadingModalOpen] = useState(false);
  const [isSuccessModalOpen, setIsSuccessModalOpen] = useState(false);
  const [isUpgradeModalOpen, setIsUpgradeModalOpen] = useState(false)


  const { isSuccess } = useWaitForTransaction({
    hash: removeStrategyData?.hash,
  })

  const openCloseLoadingModal = () => {
    if (isLoadingModalOpen) {
      setIsLoadingModalOpen(false)
    } else {
      setIsLoadingModalOpen(true)
    }
  }

  const openCloseSuccessModal = () => {
    if (isSuccessModalOpen) {
      setIsSuccessModalOpen(false)
    } else {
      setIsSuccessModalOpen(true)
    }
  }

  const openCloseUpgradeModal = () => {
    if (isUpgradeModalOpen) {
      setIsUpgradeModalOpen(false)
    } else {
      setIsUpgradeModalOpen(true)
    }
  }

  return (

    <div className="flex flex-col items-center">
      <Modal isOpen={isRemoveStrategyLoading}
        title="Please, Wait for the transaction.."
        children={<Loading />}
        closeModal={() => openCloseLoadingModal()} />
      <Modal isOpen={isUpgradeModalOpen}
        title="Update your strategy"
        children={<StrategyForm isUpdate={true}
          data={{
            amount,
            type: type,
            interval,
            limit,
            token: tokenAddress,
          }
          }

        />}
        closeModal={() => openCloseUpgradeModal()} />
      {
        isSuccess &&
        <Modal isOpen={isSuccessModalOpen}
          title="Strategyh has been deleted!🎉☄️"
          children={<div className="flex-column">
            <a target="_blank" href={`https://mumbai.polygonscan.com/tx/${removeStrategyData?.hash}`}>
              Click here to view the transaction
            </a>
          </div>}
          closeModal={openCloseSuccessModal} />

      }
      <p><strong>Strategy ID: {id}</strong></p>
      <ul>
        <li>
          <strong>Type</strong>: {type}
        </li>
        <li>
          Token:  {tokenLogo}
        </li>
      </ul>
      <br />
      <p><strong>You can choose to delete or update it</strong></p>
      <br />
      <div className="flex items-center justify-between ">
        <div className='pr-10'>

          <Button title="Update" color="accent" variant="block" isActive onClick={openCloseUpgradeModal} />
        </div>
        <div className='pl-10'>
          <Button title="Delete" color="error" variant="block" isActive onClick={() => removeStrategyWrite()} />
        </div>
      </div>
    </div>
  );
};

export default StrategyRecap;
