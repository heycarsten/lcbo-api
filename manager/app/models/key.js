import DS from 'ember-data';

var HUMAN_KINDS = {
  private_server: 'Server',
  native_client: 'Client',
  web_client: 'Web'
};

export default DS.Model.extend({
  label:         DS.attr('string'),
  info:          DS.attr('string'),
  createdAt:     DS.attr('date'),
  updatedAt:     DS.attr('date'),
  domain:        DS.attr('string'),
  token:         DS.attr('string'),
  kind:          DS.attr('string'),
  inDevmode:     DS.attr('boolean'),
  isDisabled:    DS.attr('boolean'),
  cycleRequests: DS.attr('raw'),

  humanKind: function() {
    return HUMAN_KINDS[this.get('kind')];
  }.property('kind'),

  totalCycleRequests: function() {
    return this.get('cycleRequests').reduce(function(t, d) {
      return t + d[1];
    }, 0);
  }.property('cycleRequests')
});
