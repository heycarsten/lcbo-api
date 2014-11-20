import Em from 'ember';
import Unauthenticated from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Em.Route.extend(Unauthenticated, {
  actions: {
    didTransition: function() {
      this.controllerFor('password.recover').reset();
    }
  }
});
