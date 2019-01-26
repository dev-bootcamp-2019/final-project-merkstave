import React, { Component } from "react";
import { Link } from "react-router-dom";

class Navigation extends Component {
  render() {
    return (
      <div className="navigation">
      	<Link to="/">Home</Link>
      	<Link to="/bounties">All bounties</Link>
      	<Link to="/my-bounties">My bounties</Link>
      	<Link to="/my-submissions">My submissions</Link>
      </div>
    );
  }
}

export default Navigation;