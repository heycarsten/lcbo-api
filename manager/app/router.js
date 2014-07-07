import Ember from 'ember';

var Router = Ember.Router.extend({
  location: ManagerENV.locationType
});

Router.map(function() {
  this.route('logIn', { path: '/log-in' });
  this.route('registration', { path: '/register' });
  this.route('verifyRegistration', { path: '/register/:token' });
  this.route('account');
  this.route('verification', { path: '/account/verify/:token' });

  this.resource('keys', { path: '/manage' }, function() {
    this.route('new', { path: '/manage/keys/new' });
    this.route('show', { path: '/manage/keys/:key_id' });
  });
});

export default Router;
