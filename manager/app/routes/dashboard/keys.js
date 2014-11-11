import Em from 'ember';

export default Em.Route.extend({
  model: function() {
    return this.store.find('key', { page: 1 });
  },

  afterModel: function() {
    var meta = this.store.metadataFor('key');

    console.log(meta);
  }
});
