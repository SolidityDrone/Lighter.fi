import { FC } from "react";
import { CustomConnectButton } from "../common/ConnectButton";
import Container from "./container";
import Logo from "./logo";
import Link from "next/link";

const Header: FC = () => {
  return (
    <Container>
      <nav className="relative z-50 flex justify-between py-8">
        <Logo title="Lighter.fi" />
        <div className="flex items-center gap-10">
          <Link href={"/strategy"} className="hover:text-accent">New Strategy</Link>
          <Link href={"/account"} className="hover:text-accent">Private Area</Link>
          <CustomConnectButton />
        </div>
      </nav>
    </Container>
  );
};

export default Header;
