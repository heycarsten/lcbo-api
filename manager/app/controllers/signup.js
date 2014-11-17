import Em from 'ember';

export default Em.ObjectController.extend({
  disabled: false,
  currentTemplate: 'signup/form',

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

      this.send('loading');

      model.save().then(
        function() {
          controller.send('loaded');
          controller.set('currentTemplate', 'signup/done');
        },

        function() {
          controller.send('loaded');
        }
      );
    }
  }
});
