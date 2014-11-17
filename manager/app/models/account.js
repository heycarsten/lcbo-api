import DS from 'ember-data';

export default DS.Model.extend({
  name:     DS.attr('string'),
  email:    DS.attr('string'),
  password: DS.attr('string'),
  cycleRequests: DS.attr('raw'),

  totalCycleRequests: function() {
    return this.get('cycleRequests').reduce(function(t, a) {
      return t + a[1];
    }, 0);
  }.property('cycleRequests')
});
