import React, { useEffect } from 'react';
import { Container, Row, Col } from 'react-bootstrap';

const Homepage = () => {
  useEffect(() => {
    document.title = 'Lending Protocol on Polygon Network | Borrow & Lend NFTs Instantly';

    const descriptionMeta = document.createElement('meta');
    descriptionMeta.name = 'description';
    descriptionMeta.content = 'Unlock the value of your NFTs on the Polygon network. Borrow and lend against your NFT assets instantly with our lending protocol. Start leveraging your digital collectibles now!';
    document.head.appendChild(descriptionMeta);

    const keywordsMeta = document.createElement('meta');
    keywordsMeta.name = 'keywords';
    keywordsMeta.content = 'lending protocol, Polygon network, borrow NFTs, lend NFTs, instant loans, digital collectibles';
    document.head.appendChild(keywordsMeta);

    return () => {
      // Clean up the added meta tags if necessary
      document.head.removeChild(descriptionMeta);
      document.head.removeChild(keywordsMeta);
    };
  }, []);


  return (
    <>    <div className='bg-container-home'>
    </div>
 
      <Container>
        <header>



          <Row style={{ marginTop: '8%' }}>
            <Col className='col-lg-7 home-card'>
              <h1 className='hide-on-mobile' style={{ textAlign: 'left', fontSize: '2.5rem', display: 'block', marginBottom: '32px' }}>Welcome to LighterFi!</h1>
              <h1 style={{ textAlign: 'left', fontSize: '1.6rem', display: 'block' }}>
              lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem 
                <span style={{ color: 'rgb(255, 0, 0)' }}> Avalanche </span> network!
              </h1>
              <h2 style={{ textAlign: 'left', fontSize: '0.8rem', display: 'block' }}>
              lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem 

              </h2><h2 style={{ textAlign: 'left', fontSize: '0.8rem', marginTop: '-8px', display: 'block' }}>
                It is cheap, fast and secure!
              </h2>
            </Col>
       
          </Row>


          <Row style={{ marginTop: '15%' }}>
            <Col className='col-lg-3 col-12 home-card'>

              <h1 style={{ textAlign: 'left', fontSize: '1.6rem', display: 'block' }}>
                Automation

              </h1>
              <h2 style={{ textAlign: 'left', fontSize: '0.8rem', display: 'block' }}>
                lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem 
              </h2>
            </Col>
            <Col />
            <Col className='col-lg-3 col-12 home-card'>

              <h1 style={{ textAlign: 'left', fontSize: '1.6rem', display: 'block' }}>
                Functions 
              
              </h1>
              <h2 style={{ textAlign: 'left', fontSize: '0.8rem', display: 'block' }}>
              lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem 
              </h2>
            </Col>
            <Col />
            <Col className='col-lg-3 col-12 home-card'>

              <h1 style={{ textAlign: 'left', fontSize: '1.6rem', display: 'block' }}>
                LiFi

              </h1>
              <h2 style={{ textAlign: 'left', fontSize: '0.8rem', display: 'block' }}>
              lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem 
              </h2>
            </Col>
          </Row>

        </header>
      </Container>
  

    </>
  );
};


export default Homepage;