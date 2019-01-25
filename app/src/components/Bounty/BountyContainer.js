import BountyPage from "./BountyPage";
import { drizzleConnect } from "drizzle-react";

const mapStateToProps = state => {
  return {
    accounts: state.accounts,
    Bounties: state.contracts.Bounties,
    drizzleStatus: state.drizzleStatus,
  };
};

const BountyContainer = drizzleConnect(BountyPage, mapStateToProps);

export default BountyContainer;
