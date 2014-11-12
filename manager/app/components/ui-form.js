import Em from 'ember';

export default Em.Component.extend({
  tagName: 'form',
  classNameBindings: 'hasErrors',
  hasErrors: Em.computed.bool('model.errors.length'),
  disabled: Em.computed.oneWay('model.isLoading'),

  hasClickedSubmitButton: function(event) {
    event.preventDefault();
    this.sendAction('action', this.get('model'));
  }.on('submit')
});
