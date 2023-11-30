import { FC } from "react";
import { serverClient } from "./_trpc/serverClient";
import Container from "@/components/layout";
import Badge from "@/components/common/badge";

const Home: FC = async () => {
  const greeting = await serverClient.greeting();

  return <div >
    home
  </div>
};

export default Home;
