import React, { Component } from "react";
import { ContractData, ContractForm } from "drizzle-react-components";

class SubmissionPage extends Component {
  render() {
    return (
      <div className="section">
        <ContractData contract="Bounties" method="getSubmission" methodArgs={this.props.match.params.id} />
        <div className="separator">Accept submission</div>
        <ContractForm contract="Bounties" method="acceptSubmission" />
        <div className="separator">Reject submission</div>
        <ContractForm contract="Bounties" method="rejectSubmission" />
      </div>
    );
  }
}

export default SubmissionPage;