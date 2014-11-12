import Em from 'ember';

export default Em.ObjectController.extend({
  disabled: false,
  currentTemplate: 'signup/form',
  needs: 'application',
  isLoading: Em.computed.alias('controllers.application.isLoading'),

  reset: function() {
    this.setProperties({
      name:     null,
      email:    null,
      password: null
    });
  },

  actions: {
    createAccount: function(model) {
      var controller = this;

      this.set('isLoading', true);

      model.save().then(
        function() {
          controller.set('isLoading', false);
          controller.set('currentTemplate', 'signup/done');
        },

        function() {
          controller.set('isLoading', false);
        }
      );
    }
  }
});
