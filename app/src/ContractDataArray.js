import { drizzleConnect } from 'drizzle-react'
import React, { Component } from 'react'
import PropTypes from 'prop-types'

class ContractDataArray extends Component {
  constructor(props, context) {
    super(props);

    this.contracts = context.drizzle.contracts;

    this.state = {
      dataKeyCounter: 0,
      dataKeysItems: [],
      lastCount: 0
    };
  }

  initDataKeyCounter() {
    return this.contracts[this.props.contract].methods[this.props.methodCounter].cacheCall();
  }

  initDataKeysItems(count) {
    var dataKeysItems = [];
    for (var i = 0; i < count; i++) {
      dataKeysItems.push(this.contracts[this.props.contract].methods[this.props.methodIteration].cacheCall(i));
    }
    return dataKeysItems;
  }

  componentDidMount() {
    var timestr = new Date().toLocaleString();
    console.log("componentDidMount", timestr);
    var dataKeyCounter = this.initDataKeyCounter();
    this.setState({ dataKeyCounter })
  }

  componentDidUpdate() {
    var timestr = new Date().toLocaleString();
    console.log("componentDidUpdate", timestr);
    if (this.state.dataKeyCounter in this.props.contracts[this.props.contract][this.props.methodCounter]) {
      var count = this.props.contracts[this.props.contract][this.props.methodCounter][this.state.dataKeyCounter].value;
      if (count !== this.state.lastCount) {
        this.setState({
          lastCount: count,
          dataKeysItems: this.initDataKeysItems(count)
        });
      }
    }
  }

  render() {
    if (!this.props.contracts[this.props.contract].initialized) {
      return (
        <div>Initializing...</div>
      );
    }

    if (!(this.state.dataKeyCounter in this.props.contracts[this.props.contract][this.props.methodCounter])) {
      return (
        <div>none</div>
      );
    }

    var i = 0;
    var items = [];
    var arrayLength = this.state.dataKeysItems.length;
    var isResolved = arrayLength > 0;
    for (i = 0; i < arrayLength; i++) {
      var itemKey = this.state.dataKeysItems[i];
      if (itemKey in this.props.contracts[this.props.contract][this.props.methodIteration]) {
        items.push(this.props.contracts[this.props.contract][this.props.methodIteration][itemKey].value);
      } else {
        isResolved = false;
      }
    }

    if (!isResolved) {
      return (
        <div>none</div>
      )
    }

    const displayObjects = [];
    items.map((item, index) => {
      var uniqueItemKey = 'item-' + index;
      i = 0;
      const displayObjectProps = [];

      Object.keys(item).forEach((key) => {
        if (i != key) {
          var uniquePropKey = 'item-' + index + '-prop-' + i;
          displayObjectProps.push(<li key={uniquePropKey}>
            <strong>{key}</strong>:&nbsp;{`${item[key]}`}
          </li>);
        }

        i++
      })

      displayObjects.push(<ul key={uniqueItemKey}>{displayObjectProps}</ul>);
    });

    return(displayObjects);
  }
}

ContractDataArray.contextTypes = {
  drizzle: PropTypes.object
}

const mapStateToProps = state => {
  return {
    contracts: state.contracts
  }
}

export default drizzleConnect(ContractDataArray, mapStateToProps)