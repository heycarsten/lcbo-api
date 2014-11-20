import Em from 'ember';
import Unauthenticated from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Em.Route.extend(Unauthenticated, {
  setupController: function(controller, params) {
    controller.set('token', params.token);
  }
});
