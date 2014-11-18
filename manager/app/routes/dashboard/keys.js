import Em from 'ember';

export default Em.Route.extend({
  beforeModel: function() {
    return this.store.find('key');
  },

  model: function() {
    return this.store.filter('key', function(key) {
      return !key.get('isNew');
    });
  },

  afterModel: function(model, transition) {
    if (model.get('length')) {
      return;
    }

    this.transitionTo('dashboard.keys.new');
  }
});
