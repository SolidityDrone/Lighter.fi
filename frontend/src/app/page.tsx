"use client"
import { FC } from "react";
import { serverClient } from "./_trpc/serverClient";
import Container from "@/components/layout";
import Badge from "@/components/common/badge";
import Hero from "@/components/landing/hero";
import Features from "@/components/landing/features";


const Home: FC = async () => {
     
  return <div 
       >
    <Hero/>
    <Features/>
  </div>
};

export default Home;
