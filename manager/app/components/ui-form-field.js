import Em from 'ember';
import capitalize from 'manager/utils/capitalize';

var TYPES = {
  'select':   'select',
  'textarea': 'textarea',
  'checkbox': 'checkbox',
  'password': 'password'
};

export default Em.Component.extend({
  tagName:           'li',
  classNames:        'field',
  classNameBindings: ['isInvalid', 'isOptional', 'controlType', 'for'],
  type:              'text',

  form:  Em.computed.alias('parentView'),
  model: Em.computed.alias('form.model'),

  isInvalid:  Em.computed.bool('errors.length'),
  isOptional: Em.computed.bool('optional'),

  valuePath: 'id',
  labelPath: 'label',

  actions: {
    togglePasswordMask: function() {
      this.toggleProperty('showPassword');
    }
  },

  isPassword: Em.computed.equal('type', 'password'),
  isCheckbox: Em.computed.equal('type', 'checkbox'),
  minimal:    Em.computed.alias('parentView.minimal'),

  passwordPlaceholder: function() {
    return this.get('showPassword') ? 'Password' : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022';
  }.property('showPassword'),

  controlType: function() {
    return this.get('type') || 'text';
  }.property('type'),

  controlPartialPath: function() {
    var type = TYPES[this.get('type')] || 'input';
    return 'components/ui-form-field/' + type;
  }.property('type'),

  isMinimal: function() {
    return this.get('minimal') && !this.get('isCheckbox');
  }.property('minimal', 'isCheckbox'),

  isStacked: function() {
    return !this.get('minimal') && !this.get('isCheckbox');
  }.property('minimal', 'isCheckbox'),

  installCpAliases: function() {
    var field = this.get('for');

    this.reopen({
      errors: Em.computed.alias('model.errors.' + field),
      value:  Em.computed.alias('model.' + field)
    });
  }.on('init'),

  fieldGuid: function() {
    var field = this.get('for');
    var guid  = Em.guidFor(this.get('model'));

    return 'ui-form-field-' + field + '-' + guid;
  }.property('for', 'model'),

  label: function() {
    return capitalize(this.get('for'));
  }.property('for'),

  clearErrors: function() {
    this.get('model.errors').remove(this.get('for'));
  }.on('focusIn')
});
