"use client"
import React, { FC, ReactNode, useRef, useEffect, useState } from 'react';

interface Props {
  children: ReactNode;
  className?: string;
}

const Box: FC<Props> = ({ children, className }) => {
  const boxRef = useRef<HTMLDivElement>(null);
  const [boxStyle, setBoxStyle] = useState({
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '70%', // Adjust the width as needed
    border: '2px solid black',
    borderRadius: '10px',
    paddingTop: '30px',
    paddingBottom: '50px',
    marginBottom: '50px',
    margin: 'auto'
  });


  return (
      <div ref={boxRef} style={boxStyle} className={className}>
        {children}
      </div>
  );
};

export default Box;
