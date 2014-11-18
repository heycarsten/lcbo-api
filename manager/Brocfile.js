/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var app = new EmberApp({
  minifyJS: {
    options: {
      uglify2: {
        mangle: {
          except: ["$super"]
        }
      }
    }
  }
});

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

app.import('bower_components/moment/moment.js');
app.import('bower_components/d3/d3.js');
app.import('vendor/prism/prism.js');
app.import('bower_components/rickshaw/rickshaw.css');
app.import('bower_components/rickshaw/rickshaw.js');
app.import('vendor/prism/prism.css');

module.exports = app.toTree();
