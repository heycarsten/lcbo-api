import Ember from 'ember';
import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin';

export default Ember.Route.extend(ApplicationRouteMixin, {
  actions: {
    didTransition: function() {
      var route = this;

      Ember.run.next(function() {
        route.controllerFor('application').set('isLoading', false);
      });
    },

    loading: function() {
      this.controllerFor('application').set('isLoading', true);
    },

    loaded: function() {
      this.controllerFor('application').set('isLoading', false);
    },

    logOut: function() {
      if (!confirm('Are you sure that you want to log out of LCBO API?')) {
        return;
      }

      this.send('invalidateSession');
    }
  }
});
