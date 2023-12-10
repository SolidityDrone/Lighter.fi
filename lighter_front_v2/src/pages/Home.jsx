import React from 'react';
import backgroundImage from './Lighter.Fi.png'; // Import the image
import { Card, CardContent, Typography } from '@mui/material'; // Import Material-UI components
import './Home.css'; // Import a CSS file to define styles

const Home = () => {
  return (
    <div className="landing-page">
      {/* Uncomment this line to add a background image */}
      <img src={backgroundImage} alt="Background" className="background-image" />
      <div className="content">
        <h1 className="title" style={{ fontSize: '90px' }}>
          LighterFi
        </h1>
        <p className="subtitle" style={{ fontSize: '24px' }}>
          Decentralized DCA and Limit Order platform
        </p>
      </div>

      <div className="card-container">
        <Card className="transparent-card">
          <CardContent>
            <Typography variant="h6" className="card-title">Create your strategy</Typography>
            <Typography variant="subtitle1" className="card-subtitle">
              DCA: Set how often to buy a token<br />
              Limit: Set the buy/sell price powered by Chainlink price feed
            </Typography>
          </CardContent>
        </Card>
        <Card className="transparent-card">
          <CardContent>
            <Typography variant="h6" className="card-title">Enjoy the automatic execution of your strategy</Typography>
            <Typography variant="subtitle1" className="card-subtitle">
              Give token approvals to LighterFi and forget about it. Powered by Chainlink Automation
            </Typography>
          </CardContent>
        </Card>
        <Card className="transparent-card">
          <CardContent>
            <Typography variant="h6" className="card-title">Leverage the most efficient on-chain swap protocol</Typography>
            <Typography variant="subtitle1" className="card-subtitle">
            The automatic swap is powered by LIFI Aggregator using Chainlink Functions
            </Typography>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Home;
