import Ember from 'ember';
import Unauthenticated from 'simple-auth/mixins/unauthenticated-route-mixin';

export default Ember.Route.extend(Unauthenticated, {
  model: function() {
    return this.store.createRecord('signup');
  }
});
