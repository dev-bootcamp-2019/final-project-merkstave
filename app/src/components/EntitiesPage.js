import React, { Component } from "react";
import ContractDataArray from "../ContractDataArray";

class EntitiesPage extends Component {
  render() {
    var propContract = 'Bounties';
    var methodCounter = 'getCountBounties';
    var methodIteration = 'getBounty';
    var pathDetailed = '/bounty';
    var parentId = null;

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
        parentId = this.props.match.params.id;
      break;
      default:
    }

    return (
      <div className="section">
        <ContractDataArray
          contract={propContract}
          methodCounter={methodCounter}
          methodIteration={methodIteration}
          pathDetailed={pathDetailed}
          parentId={parentId}
        />
      </div>
    );
  }
}

export default EntitiesPage;