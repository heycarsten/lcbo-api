import Em from 'ember';

export default Em.Controller.extend({
  name:      null,
  email:     null,
  password:  null,
  doesAgreeToTerms: null,
  disabled:  false,
  currentTemplate: 'signup/form',

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
      password: this.get('password'),
      does_agree_to_terms: this.get('doesAgreeToTerms')
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
            controller.set('currentTemplate', 'signup/done');
          });
        },

        function(xhr) {
          Em.run(function() {
            controller.set('errors', Em.Object.create());

            xhr.responseJSON.errors.forEach(function(error) {
              controller.set('errors.' + error.path.camelize(), error.detail);
            });

            controller.set('disabled', false);
          });
        }
      );
    }
  }
});
