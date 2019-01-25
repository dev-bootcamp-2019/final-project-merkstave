import React, { Component } from "react";
import { DrizzleProvider } from "drizzle-react";
import { LoadingContainer } from "drizzle-react-components";
import { BrowserRouter as Router, Route } from "react-router-dom";

import "./App.css";

import drizzleOptions from "./drizzleOptions";
import MainContainer from "./components/Main/MainContainer";
import BountyContainer from "./components/Bounty/BountyContainer";

class App extends Component {
  render() {
    return (
      <DrizzleProvider options={drizzleOptions}>
        <LoadingContainer>
          <Router>
            <div>
              <Route exact path="/" component={MainContainer} />
              <Route path="/bounty/:id" component={BountyContainer} />
            </div>
          </Router>
        </LoadingContainer>
      </DrizzleProvider>
    );
  }
}

export default App;
