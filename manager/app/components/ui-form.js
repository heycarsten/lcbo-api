import Em from 'ember';

export default Em.Component.extend({
  tagName: 'form',
  classNameBindings: 'hasErrors',
  hasErrors: Ember.computed.bool('model.errors.length'),

  hasClickedSubmitButton: function(event) {
    event.preventDefault();
    this.sendAction('action', this.get('model'));
  }.on('submit')
});
