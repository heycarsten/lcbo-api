import DS from 'ember-data';

export default DS.Transform.extend({
  deserialize: function(timestamp) {
    return timestamp ? moment(timestamp) : null;
  },

  serialize: function(moment) {
    return moment ? moment.toISOString() : null;
  }
});
