import React, { Component } from "react";
import ContractDataArray from "../ContractDataArray";

class EntitiesPage extends Component {
  render() {
    var propContract = 'Bounties';
    var methodCounter = 'getCountBounties';
    var methodIteration = 'getBounty';
    var pathDetailed = '/bounty';
    var methodArgs = [];

    switch (this.props.entityClass) {
      case 'my-bounties':
        methodCounter = 'getCountMyBounties';
        methodIteration = 'getMyBounty';
      break;
      case 'my-submissions':
        methodCounter = 'getCountMySubmissions';
        methodIteration = 'getMySubmission';
        pathDetailed = '/submission';
      break;
      case 'bounty-submissions':
        methodCounter = 'getCountBountySubmissions';
        methodIteration = 'getBountySubmission';
        pathDetailed = '/submission';
        methodArgs = [this.props.match.params.id]
      break;
    }

    return (
      <div className="section">
        <ContractDataArray
          contract={propContract}
          methodCounter={methodCounter}
          methodIteration={methodIteration}
          pathDetailed={pathDetailed}
          methodArgs={methodArgs}
        />
      </div>
    );
  }
}

export default EntitiesPage;