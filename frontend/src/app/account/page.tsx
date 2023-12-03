"use client"
import { FC } from "react";

import Box from "@/components/layout/box";
import StrategyTable from "@/components/account/strategyTable";


const Account: FC = async () => {

  return <Box>
    <StrategyTable />
  </Box>
};

export default Account;
