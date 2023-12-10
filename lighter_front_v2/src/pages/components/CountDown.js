import { useState, useEffect } from 'react';

function DealCountdown({ expirationDate }) {
  const [timeRemaining, setTimeRemaining] = useState(null);

  useEffect(() => {
    const expirationDateObj = new Date(expirationDate * 1000);
    const interval = setInterval(() => {
      const remaining = Math.floor((expirationDateObj.getTime() - Date.now()) / 1000);
      if (remaining <= 0) {
        clearInterval(interval);
        setTimeRemaining(null);
      } else {
        setTimeRemaining(remaining);
      }
    }, );

    return () => clearInterval(interval);
  }, [expirationDate]);

  if (timeRemaining === null) {
    return (
      <span>Expired</span>
    );
  }
  
  const seconds = timeRemaining % 60;
  const minutes = Math.floor(timeRemaining / 60) % 60;
  const hours = Math.floor(timeRemaining / (60 * 60)) % 24;
  const days = Math.floor(timeRemaining / (24 * 60 * 60));
  return (
    <span>{`${days.toString().padStart(2,'0')}:${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`}</span>
  );
}

export default DealCountdown;
