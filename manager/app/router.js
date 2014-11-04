import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('manager');
  this.route('login', { path: '/log-in' });
});

export default Router;
