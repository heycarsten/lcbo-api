import Em from 'ember';
import Authenticated from 'simple-auth/mixins/authenticated-route-mixin';

export default Em.Route.extend(Authenticated, {
  model: function() {
    return this.store.find('key');
  }
});
