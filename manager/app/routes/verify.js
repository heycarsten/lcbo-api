import Em from 'ember';
import Unauthenticated from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Em.Route.extend(Unauthenticated, {
  model: function(params) {
    return Em.$.ajax({
      url: '/manager/verifications/' + params.token,
      type: 'PUT'
    });
  },

  afterModel: function(data) {
    var route = this;

    return this.session.authenticate('authenticator:un-auth', data).then(function() {
      route.transitionTo('dashboard.keys');
    });
  },

  actions: {
    error: function() {
      if (this.session.get('isAuthenticated')) {
        this.replaceWith('dashboard.keys');
      } else {
        this.replaceWith('login');
      }
    }
  }
});
