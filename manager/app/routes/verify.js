import Em from 'ember';

export default Em.Route.extend({
  model: function(params) {
    return Em.$.ajax({
      url: '/manager/verifications/' + params.token,
      type: 'PUT'
    });
  },

  afterModel: function(data) {
    var route = this;

    return this.session.authenticate('authenticator:un-auth', data).then(function() {
      route.transitionTo('index');
    });
  },

  actions: {
    error: function(err) {
      if (this.session.get('isAuthenticated')) {
        this.replaceWith('index');
      } else {
        this.replaceWith('login');
      }
    }
  }
});
