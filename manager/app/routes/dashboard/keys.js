import Em from 'ember';

export default Em.Route.extend({
  model: function() {
    return this.store.find('key', { page: 1 });
  },

  afterModel: function() {
    var meta = this.store.metadataFor('key');
    this.controllerFor('keys').set('page', meta.pagination.current_page);
  }
});
