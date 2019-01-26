import React, { Component } from "react";
import { AccountData, ContractForm } from "drizzle-react-components";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import ContractDataArray from "../ContractDataArray";
import BountyPage from "./BountyPage";
import BountyCreatePage from "./BountyCreatePage";
import SubmissionPage from "./SubmissionPage";
import EntitiesPage from "./EntitiesPage";

class MainPage extends Component {
  render() {
    return (
      <div className="App">
        <div className="section">
          <h2>Active Account</h2>
          <AccountData accountIndex="0" units="ether" precision="3" />
        </div>

        <Router>
          <div>
            <div className="section">
              <Link to="/">All bounties</Link>&nbsp;|&nbsp;
              <Link to="/new-bounty">Create bounty</Link>&nbsp;|&nbsp;
              <Link to="/my-bounties">My bounties</Link>&nbsp;|&nbsp;
              <Link to="/my-submissions">My submissions</Link>
            </div>

            <Route exact path="/" component={EntitiesPage} />
            <Route path="/new-bounty" component={BountyCreatePage} />
            <Route path="/my-bounties" render={(props) => <EntitiesPage entityClass="my-bounties" {...props} /> } />
            <Route path="/my-submissions" render={(props) => <EntitiesPage entityClass="my-submissions" {...props} /> } />
            <Route path="/bounty/:id" component={BountyPage} />
            <Route path="/submission/:id" component={SubmissionPage} />
          </div>
        </Router>
      </div>
    );
  }
}

export default MainPage;