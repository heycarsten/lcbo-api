import Em from 'ember';

export default Em.ObjectController.extend({
  disabled: false,
  currentTemplate: 'signup/form',

  reset: function() {
    this.setProperties({
      name:     null,
      email:    null,
      password: null,
      disabled: false
    });
  },

  actions: {
    createAccount: function(model) {
      var controller = this;

      this.set('disabled', true);

      model.save().then(
        function() {
          controller.set('currentTemplate', 'signup/done');
        },

        function() {
          controller.set('disabled', false);
        }
      );
    }
  }
});
