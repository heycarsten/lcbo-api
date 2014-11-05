import Em from 'ember';

export default Em.TextField.extend({
  type: Em.computed(function() {
    return this.get('showPassword') ? 'text' : 'password';
  }).property('showPassword')
});
