import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login', { path: '/log-in' });
  this.route('signup', { path: '/sign-up' });
  this.route('verify', { path: '/verify/:token' });
});

export default Router;
