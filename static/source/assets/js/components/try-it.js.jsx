Prism.languages.json = {
  'property': {
    pattern: /[ ]*"[a-z0-9_]+":/ig,
    inside: {
      quote: /"/,
      colon: /:/
    }
  },
  'null': /\b(null)\b/g,
  'boolean': /\b(true|false)\b/g,
  'string': /(")(\\?.)*?\1/g,
  'number': /\b-?(0x[\dA-Fa-f]+|\d*\.?\d+([Ee]-?\d+)?|NaN|-?Infinity)\b/g,
};

var ENDPOINTS = [
  {
    key: 'product',
    label: 'Product',
    path: 'products/288506'
  },
  {
    key: 'store',
    label: 'Store',
    path: 'stores/511'
  },
  {
    key: 'inventory',
    label: 'Inventory',
    path: 'stores/511/products/288506/inventory'
  },
  {
    key: 'product-inventory',
    label: 'Product Inventories',
    path: 'inventories?product_id=288506'
  },
  {
    key: 'stores-with-product',
    label: 'Stores with Product',
    path: 'stores?product_id=288506'
  },
  {
    key: 'stores-near-point',
    label: 'Stores Near Point',
    path: 'stores?lat=43.65838&lon=-79.44335'
  },
  {
    key: 'stores-near-with-product',
    label: 'Stores Near Point with Product',
    path: 'stores?lat=43.65838&lon=-79.44335&product_id=288506'
  }
];

var TryItEndpointOption = React.createClass({
  handleClick: function(endpoint) {
    this.props.onSelected(endpoint);
  },

  render: function() {
    var classes = React.addons.classSet({
      'selected': this.props.selectedKey === this.props.data.key
    });

    return (
      <li className={classes} onClick={this.handleClick}>
        {this.props.data.label}
      </li>
    );
  }
});

var TryItEndpointSelectList = React.createClass({
  handleSelected: function(endpoint) {
    this.props.onSelected(endpoint);
  },

  componentDidMount: function() {
    var component = this;

    $(document).one('click', function() {
      component.props.onDismiss();
      return true;
    });
  },

  render: function() {
    return (
      <ol className="endpoint-selector-list">
        {ENDPOINTS.map(function(endpoint) {
          return <TryItEndpointOption
            onSelected={this.handleSelected.bind(this, endpoint)}
            key={endpoint.key}
            selectedKey={this.props.selectedKey}
            data={endpoint} />;
        }, this)}
      </ol>
    );
  }
});

var TryItEndpointSelector = React.createClass({
  getInitialState: function() {
    return {
      label: ENDPOINTS[0].label,
      path:  ENDPOINTS[0].path
    };
  },

  handleSelect: function(endpoint) {
    this.closeSelector();
    this.props.onSelected(endpoint);
  },

  openSelector: function() {
    this.setState({ isOpen: true });
  },

  closeSelector: function() {
    this.setState({ isOpen: false });
  },

  render: function() {
    var classes = React.addons.classSet({
      'endpoint-selector': true,
      'open': this.state.isOpen
    });

    var selector;

    var label = ENDPOINTS.filter(function(endpoint) {
      return endpoint.key === this.props.selectedKey;
    }, this)[0].label;

    if (this.state.isOpen) {
      selector = (
        <TryItEndpointSelectList
          selectedKey={this.props.selectedKey}
          onSelected={this.handleSelect}
          onDismiss={this.closeSelector} />
      );
    } else {
      selector = <div />;
    }

    return (
      <div className={classes}>
        <div onClick={this.openSelector} className="endpoint-selector-label">
          {label}
        </div>
        {selector}
      </div>
    );
  }
});

var TryItEndpointPathInput = React.createClass({
  handleSubmit: function(event) {
    event.preventDefault();
    this.props.onSubmit();
  },

  handlePathChange: function(event) {
    this.props.onPathChange(
      event.target.value.trim()
    );
  },

  render: function() {
    return (
      <form className="endpoint-path-input" onSubmit={this.handleSubmit}>
        <span className="readonly">lcboapi.com/</span>
        <input type="text" value={this.props.path} onChange={this.handlePathChange} />
        <input type="submit" value="Submit" />
      </form>
    );
  }
});

var TryItConsole = React.createClass({
  componentDidUpdate: function() {
    $(this.refs.codeDiv.getDOMNode()).scrollTop(0);
  },

  render: function() {
    var html = Prism.highlight(this.props.json, Prism.languages.json);

    return (
      <div ref="codeDiv" className="console">
        <pre><code dangerouslySetInnerHTML={{__html: html}} /></pre>
      </div>
    );
  }
});

var TryItComponent = React.createClass({
  getInitialState: function() {
    return {
      endpoints: ENDPOINTS,
      key: ENDPOINTS[0].key,
      path: ENDPOINTS[0].path,
      json: '{}'
    }
  },

  loadJSON: function() {
    $.ajax({
      url: 'https://lcboapi.com/' + this.state.path,
      headers: {
        Authorization: 'Token token="MDpmOWYzMDk3Yy03YjEyLTExZTQtOTRlYy1kZmVhMmEzMTM5NjU6TWFVZE44Zkd5QzRGNEFaOGVBYzh0eE5GVnVPcEljZlc0aXBa"'
      }
    }).then(function(data) {
      this.setState({
        json: JSON.stringify(data, null, 2)
      });
    }.bind(this));
  },

  handleSelected: function(endpoint) {
    this.setState({
      key: endpoint.key,
      path: endpoint.path,
      label: endpoint.label
    }, function() {
      this.loadJSON();
    }.bind(this));
  },

  handleSubmit: function(data) {
    this.loadJSON();
  },

  handlePathChange: function(path) {
    this.setState({ path: path });
  },

  componentDidMount: function() {
    this.loadJSON();
  },

  render: function() {
    return (
      <div className="try-it-component">
        <div className="control-bar">
          <TryItEndpointSelector selectedKey={this.state.key} onSelected={this.handleSelected} />
          <TryItEndpointPathInput path={this.state.path} onPathChange={this.handlePathChange} onSubmit={this.handleSubmit} />
        </div>
        <TryItConsole json={this.state.json} />
      </div>
    );
  }
});

$(function() {
  var container = document.getElementById('try-it-component');

  if (container) {
    React.render(<TryItComponent />, container);
  }
});
