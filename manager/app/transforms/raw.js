import DS from 'ember-data';

export default DS.Transform.extend({
  deserialize: function(json) {
    return json;
  },

  serialize: function(js) {
    return js;
  }
});
