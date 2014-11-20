import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login', { path: '/log-in' });
  this.route('signup', { path: '/sign-up' });
  this.route('verify', { path: '/verify/:token' });
  this.route('password.recover', { path: '/password/recover' });
  this.route('password.change', { path: '/password/:token' });

  this.resource('dashboard', { path: '/' }, function() {
    this.route('account');
    this.route('keys');
    this.route('keys.new', { path: '/keys/new' });
    this.route('keys.show', { path: '/keys/:key_id' });
  });

  this.route('credits');
  this.route('terms');
  this.route('privacy');
});

export default Router;
