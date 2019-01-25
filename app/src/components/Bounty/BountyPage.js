import React, { Component } from "react";
import { ContractData } from "drizzle-react-components";
import Navigation from "../Navigation/Navigation";

class BountyPage extends Component {
  render() {
    return (
      <div className="App">
        <Navigation />
        <div className="section">
          <ContractData contract="Bounties" method="getBounty" methodArgs="0" />
        </div>
      </div>
    );
  }
}

export default BountyPage;