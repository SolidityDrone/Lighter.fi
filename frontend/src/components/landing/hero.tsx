// Hero.jsx
import React from 'react';
import Button from '../common/button';
import Link from 'next/link';
import Logo from '../layout/logo';

const Hero = () => {

    return (
        <section
            className="bg-neutral backdrop-filter backdrop-blur-3xl bg-opacity-20 text-white p-8 flex items-center justify-center h-screen">

            <div className="flex flex-col items-center ">
                <h1 className="text-5xl font-bold mb-4">Welcome to Lighter.fi</h1>
                <p className="text-lg mb-8">Your Onchain Strategy Factory</p>

                <Link href={"/strategy"}>
                    <Button title="Get Started" color="primary" isActive variant="circle" />
                </Link>

            </div>
        </section>
    );
};

export default Hero;
