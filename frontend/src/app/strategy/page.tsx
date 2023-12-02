"use client"
import { FC } from "react";

import Box from "@/components/layout/box";
import TimeRangeStrategyForm from "@/components/startegy/strategyForm";
import { useWrite } from "@/hooks/useWrite";
import { useCreateStrategy } from "@/contracts/LighterFI";

const Strategy: FC = async () => {
  return <Box>
    <TimeRangeStrategyForm />
  </Box>
};

export default Strategy;
