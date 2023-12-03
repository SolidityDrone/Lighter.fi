"use client"
import { FC } from "react";

import Box from "@/components/layout/box";
import StrategyForm from "@/components/startegy/strategyForm";
import { useWrite } from "@/hooks/useWrite";
import { useCreateStrategy } from "@/contracts/lighterfi/methods";

const Strategy: FC = async () => {
  return <Box>
    <StrategyForm />
  </Box>
};

export default Strategy;
