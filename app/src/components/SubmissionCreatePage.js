import React, { Component } from "react";
import { ContractForm } from "drizzle-react-components";

class SubmissionCreatePage extends Component {
  render() {
    return (
      <div className="section">
        <ContractForm contract="Bounties" method="createSubmission" />
      </div>
    );
  }
}

export default SubmissionCreatePage;