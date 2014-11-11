import DS from 'ember-data';

export default DS.Model.extend({
  label:      DS.attr('string'),
  info:       DS.attr('string'),
  createdAt:  DS.attr('date'),
  updatedAt:  DS.attr('date'),
  domain:     DS.attr('string'),
  token:      DS.attr('string'),
  kind:       DS.attr('string'),
  inDevmode:  DS.attr('boolean'),
  isDisabled: DS.attr('boolean')
});
