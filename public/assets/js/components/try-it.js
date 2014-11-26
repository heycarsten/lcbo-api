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

var TryItEndpointOption = React.createClass({displayName: 'TryItEndpointOption',
  handleClick: function(endpoint) {
    this.props.onSelected(endpoint);
  },

  render: function() {
    var classes = React.addons.classSet({
      'selected': this.props.selectedKey === this.props.data.key
    });

    return (
      React.createElement("li", {className: classes, onClick: this.handleClick}, 
        this.props.data.label
      )
    );
  }
});

var TryItEndpointSelectList = React.createClass({displayName: 'TryItEndpointSelectList',
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
      React.createElement("ol", {className: "endpoint-selector-list"}, 
        ENDPOINTS.map(function(endpoint) {
          return React.createElement(TryItEndpointOption, {
            onSelected: this.handleSelected.bind(this, endpoint), 
            key: endpoint.key, 
            selectedKey: this.props.selectedKey, 
            data: endpoint});
        }, this)
      )
    );
  }
});

var TryItEndpointSelector = React.createClass({displayName: 'TryItEndpointSelector',
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
        React.createElement(TryItEndpointSelectList, {
          selectedKey: this.props.selectedKey, 
          onSelected: this.handleSelect, 
          onDismiss: this.closeSelector})
      );
    } else {
      selector = React.createElement("div", null);
    }

    return (
      React.createElement("div", {className: classes}, 
        React.createElement("div", {onClick: this.openSelector, className: "endpoint-selector-label"}, 
          label
        ), 
        selector
      )
    );
  }
});

var TryItEndpointPathInput = React.createClass({displayName: 'TryItEndpointPathInput',
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
      React.createElement("form", {className: "endpoint-path-input", onSubmit: this.handleSubmit}, 
        React.createElement("span", {className: "readonly"}, "lcboapi.com/"), 
        React.createElement("input", {type: "text", value: this.props.path, onChange: this.handlePathChange}), 
        React.createElement("input", {type: "submit", value: "Submit"})
      )
    );
  }
});

var TryItConsole = React.createClass({displayName: 'TryItConsole',
  componentDidUpdate: function() {
    $(this.refs.codeDiv.getDOMNode()).scrollTop(0);
  },

  render: function() {
    var html = Prism.highlight(this.props.json, Prism.languages.json);

    return (
      React.createElement("div", {ref: "codeDiv", className: "console"}, 
        React.createElement("pre", null, React.createElement("code", {dangerouslySetInnerHTML: {__html: html}}))
      )
    );
  }
});

var TryItComponent = React.createClass({displayName: 'TryItComponent',
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
      React.createElement("div", {className: "try-it-component"}, 
        React.createElement("div", {className: "control-bar"}, 
          React.createElement(TryItEndpointSelector, {selectedKey: this.state.key, onSelected: this.handleSelected}), 
          React.createElement(TryItEndpointPathInput, {path: this.state.path, onPathChange: this.handlePathChange, onSubmit: this.handleSubmit})
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
