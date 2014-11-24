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

var TryItEndpointSelector = React.createClass({
  render: function() {
    return (
      <div className="endpoint-selector">
        Product
      </div>
    );
  }
});

var TryItEndpointPathInput = React.createClass({
  handleSubmit: function(event) {
    event.preventDefault();

    var path = this.refs.path.getDOMNode().value.trim();

    this.props.onPathChange({
      path: path
    });
  },

  render: function() {
    return (
      <form className="endpoint-path-input" onSubmit={this.handleSubmit}>
        <span className="readonly">lcboapi.com/</span>
        <input type="text" ref="path" defaultValue={this.props.path} />
        <input type="submit" value="Submit" />
      </form>
    );
  }
});

var TryItConsole = React.createClass({
  render: function() {
    var html = Prism.highlight(this.props.json, Prism.languages.json);

    return (
      <div className="console">
        <pre><code dangerouslySetInnerHTML={{__html: html}} /></pre>
      </div>
    );
  }
});

var TryItComponent = React.createClass({
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
      <div className="try-it-component">
        <div className="control-bar">
          <TryItEndpointSelector onSelectEndpoint={this.handleEndpointSelected} />
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
