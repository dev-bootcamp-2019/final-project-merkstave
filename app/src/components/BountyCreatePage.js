import React, { Component } from "react";
import { ContractForm } from "drizzle-react-components";

class BountyCreatePage extends Component {
  render() {
    return (
      <div className="section">
        <ContractForm contract="Bounties" method="createBounty" />
      </div>
    );
  }
}

export default BountyCreatePage;