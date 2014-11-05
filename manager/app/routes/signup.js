import Ember from 'ember';
import Unauthenticated from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Ember.Route.extend(Unauthenticated, {
  setupController: function(controller) {
    controller.reset();
  }
});
