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
    key: 'store-with-product',
    label: 'Stores with Product',
    path: 'products/288506/stores'
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
      component.props.parent.setState({ isOpen: false });
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
    this.props.onSelected(endpoint);
  },

  openSelector: function() {
    this.setState({
      isOpen: true
    });
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
          parent={this}
          onSelected={this.handleSelect} />
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
  getInitialState: function() {
    return {
      path: this.props.path
    };
  },

  handleSubmit: function(event) {
    event.preventDefault();

    this.props.onPathChange({
      path: this.state.path
    });
  },

  handlePathChange: function(event) {
    this.state.path = event.target.value.trim();
  },

  render: function() {
    return (
      <form className="endpoint-path-input" onSubmit={this.handleSubmit}>
        <span className="readonly">lcboapi.com/</span>
        <input type="text" value={this.state.path} onChange={this.handlePathChange} />
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
      url: 'http://lcboapi.com/' + this.state.path,
      dataType: 'jsonp'
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

  handlePathChange: function(data) {
    this.setState({
      path: data.path
    }, function() {
      this.loadJSON();
    }.bind(this));
  },

  componentDidMount: function() {
    this.loadJSON();
  },

  render: function() {
    return (
      <div className="try-it-component">
        <div className="control-bar">
          <TryItEndpointSelector selectedKey={this.state.key} onSelected={this.handleSelected} />
          <TryItEndpointPathInput path={this.state.path} onPathChange={this.handlePathChange} />
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
