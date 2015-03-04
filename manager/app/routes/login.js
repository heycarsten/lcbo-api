import Ember from 'ember';
import UnauthenticatedRoute from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Ember.Route.extend(UnauthenticatedRoute, {
  setupController: function(controller) {
    controller.set('errorMessage', null);
  }
});
