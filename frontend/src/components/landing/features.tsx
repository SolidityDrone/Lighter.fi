// Features.jsx
import React from 'react';

const Features = () => {
  return (
    <section className="py-12 bg-transparent">
      <div className="container mx-auto text-center">
        {/* Feature 1 */}
        <div className="mb-12">
          {/* Feature icon */}
          <div className="text-5xl mb-4">&#128161;</div>
          {/* Feature content */}
          <div>
            <h2 className="text-2xl font-bold mb-2">Powerful Strategies</h2>
            <p className="text-gray-700">Create and deploy powerful onchain strategies effortlessly.</p>
          </div>
        </div>

        {/* Feature 2 */}
        <div className="mb-12">
          {/* Feature icon */}
          <div className="text-5xl mb-4">&#128295;</div>
          {/* Feature content */}
          <div>
            <h2 className="text-2xl font-bold mb-2">Decentralized Execution</h2>
            <p className="text-gray-700">Execute your strategies in a decentralized and secure environment.</p>
          </div>
        </div>

        {/* Feature 3 */}
        <div>
          {/* Feature icon */}
          <div className="text-5xl mb-4">&#127760;</div>
          {/* Feature content */}
          <div>
            <h2 className="text-2xl font-bold mb-2">Real-time Analytics</h2>
            <p className="text-gray-700">Track and analyze your strategy's performance with real-time data.</p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Features;
