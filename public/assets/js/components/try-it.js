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
    label: 'Product',
    path: 'products/288506'
  },
  {
    label: 'Store',
    path: 'stores/511'
  },
  {
    label: 'Stores with Product',
    path: 'products/288506/stores'
  }
];

var TryItEndpointSelector = React.createClass({displayName: 'TryItEndpointSelector',
  render: function() {
    return (
      React.createElement("div", {className: "endpoint-selector"}, 
        "Product"
      )
    );
  }
});

var TryItEndpointPathInput = React.createClass({displayName: 'TryItEndpointPathInput',
  handleSubmit: function(event) {
    event.preventDefault();

    var path = this.refs.path.getDOMNode().value.trim();

    this.props.onPathChange({
      path: path
    });
  },

  render: function() {
    return (
      React.createElement("form", {className: "endpoint-path-input", onSubmit: this.handleSubmit}, 
        React.createElement("span", {className: "readonly"}, "lcboapi.com/"), 
        React.createElement("input", {type: "text", ref: "path", defaultValue: this.props.path}), 
        React.createElement("input", {type: "submit", value: "Submit"})
      )
    );
  }
});

var TryItConsole = React.createClass({displayName: 'TryItConsole',
  render: function() {
    var html = Prism.highlight(this.props.json, Prism.languages.json);

    return (
      React.createElement("div", {className: "console"}, 
        React.createElement("pre", null, React.createElement("code", {dangerouslySetInnerHTML: {__html: html}}))
      )
    );
  }
});

var TryItComponent = React.createClass({displayName: 'TryItComponent',
  getInitialState: function() {
    return {
      endpoints: ENDPOINTS,
      selectedEndpoint: ENDPOINTS[0],
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

  handlePathChange: function(data) {
    this.setState({
      path: data.path
    }, function() {
      this.loadJSON();
    }.bind(this));
  },

  handleEndpointSelected: function(data) {
    this.setState({
      selectedEndpoint: data.selectedEndpoint,
      path: data.selectedEndpoint.path
    }, function() {
      this.loadJSON();
    }.bind(this));
  },

  componentDidMount: function() {
    this.loadJSON();
  },

  render: function() {
    return (
      React.createElement("div", {className: "try-it-component"}, 
        React.createElement("div", {className: "control-bar"}, 
          React.createElement(TryItEndpointSelector, {onSelectEndpoint: this.handleEndpointSelected}), 
          React.createElement(TryItEndpointPathInput, {path: this.state.path, onPathChange: this.handlePathChange})
        ), 
        React.createElement(TryItConsole, {json: this.state.json})
      )
    );
  }
});

$(function() {
  var container = document.getElementById('try-it-component');

  if (container) {
    React.render(React.createElement(TryItComponent, null), container);
  }
});
