import Em from 'ember';

export default Em.Controller.extend({
  name:      null,
  email:     null,
  password:  null,
  disabled:  false,

  reset: function() {
    this.setProperties({
      name:         null,
      email:        null,
      password:     null,
      showPassword: false,
      disabled:     false,
      errors:       Em.Object.create()
    });
  },

  asJSON: function() {
    return {
      name:     this.get('name'),
      email:    this.get('email'),
      password: this.get('password')
    };
  },

  passwordPlaceholder: function() {
    return this.get('showPassword') ? 'Password' : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022';
  }.property('showPassword'),

  actions: {
    togglePasswordMask: function() {
      this.toggleProperty('showPassword');
    },

    clearErrorsOn: function(property) {
      this.set('errors.' + property, null);
    },

    createAccount: function() {
      var controller = this;

      this.set('disabled', true);

      Em.$.ajax({
        url:  '/manager/accounts',
        type: 'POST',
        data: { account: controller.asJSON() }
      }).then(
        function(data) {
          Em.run(function() {
            controller.set('isSent', true);
          });
        },

        function(xhr) {
          Em.run(function() {
            xhr.responseJSON.errors.forEach(function(error) {
              controller.set('errors.' + error.path, error.detail);
            });

            controller.set('disabled', false);
          });
        }
      );
    }
  }
});
