import Ember from 'ember';
import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin';

export default Ember.Route.extend(ApplicationRouteMixin, {
  actions: {
    logOut: function() {
      if (!confirm('Are you sure that you want to log out of LCBO API?')) {
        return;
      }

      this.send('invalidateSession');
    }
  }
});
