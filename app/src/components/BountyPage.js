import React, { Component } from "react";
import { ContractData, ContractForm } from "drizzle-react-components";
import ContractFormWithValue from "../ContractFormWithValue";
import EntitiesPage from "./EntitiesPage";

class BountyPage extends Component {
  render() {
    return (
      <div className="section">
        <ContractData contract="Bounties" method="getBounty" methodArgs={this.props.match.params.id} />
        <div className="separator">Activate bounty</div>
        <ContractFormWithValue contract="Bounties" method="activateBounty" sendArgs={{value: 0}} valueLabel="sendValue" />
        <div className="separator">Close bounty</div>
        <ContractForm contract="Bounties" method="closeBounty" />
        <div className="separator">Create submission</div>
        <ContractForm contract="Bounties" method="createSubmission" />
        <div className="separator">Submissions</div>
        <EntitiesPage entityClass="bounty-submissions" {...this.props} />
      </div>
    );
  }
}

export default BountyPage;