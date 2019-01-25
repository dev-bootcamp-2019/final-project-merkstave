import React, { Component } from "react";
import { Link } from "react-router-dom";

class Navigation extends Component {
  render() {
    return (
      <div className="navigation">
      	<Link to="/">Home</Link>
      </div>
    );
  }
}

export default Navigation;