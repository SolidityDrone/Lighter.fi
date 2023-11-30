import cx from "classnames";
import { FC, ReactNode } from "react";
import { twMerge } from "tailwind-merge";

interface Props {
  children: ReactNode;
  className?: string;
}

const boxStyle = {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '50vh', // Default height for larger screens
    width: '100%',
    border: '2px solid black',
    padding: '20px',
  };

  // Media query for smaller screens (adjust the max-width as needed)
  const smallerScreens = {
    '@media (max-width: 600px)': {
      height: '30vh', // Adjusted height for smaller screens
    },
  }; 
const Box: FC<Props> = ({ children, className }) => {
  return <div style={{ ...boxStyle, ...smallerScreens }}>{children}</div>;
};

export default Box;
