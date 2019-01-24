import React, { Component } from "react";
import { AccountData, ContractForm } from "drizzle-react-components";
import ContractDataArray from "./ContractDataArray";

class MyComponent extends Component {
  render() {
    return (
      <div className="App">
        <div className="section">
          <h2>Active Account</h2>
          <AccountData accountIndex="0" units="ether" precision="3" />
        </div>

        <div className="section">
          <strong>Create bounty:</strong>
          <ContractForm
            contract="Bounties"
            method="createBounty"
            methodArgs={[{ from: this.props.accounts[0] }]}
          />
        </div>

        <div className="section">
          <strong>Bounties</strong>
          <ContractDataArray
            contract="Bounties"
            methodCounter="getCountBounties"
            methodIteration="getBounty"
          />
        </div>

        <div className="section">
          <strong>My bounties</strong>
          <ContractDataArray
            contract="Bounties"
            methodCounter="getCountMyBounties"
            methodIteration="getMyBounty"
          />
        </div>

        <div className="section">
          <strong>My submissions</strong>
          <ContractDataArray
            contract="Bounties"
            methodCounter="getCountMySubmissions"
            methodIteration="getMySubmission"
          />
        </div>
      </div>
    );
  }
}

export default MyComponent;
