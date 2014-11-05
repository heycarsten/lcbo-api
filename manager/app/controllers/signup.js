import Em from 'ember';

export default Em.Controller.extend({
  firstName: null,
  lastName:  null,
  email:     null,
  disabled:  false,

  name: function() {
    var parts = [];
    var first = this.get('firstName');
    var last  = this.get('lastName');

    if (first) {
      parts.push(first);
    }

    if (last) {
      parts.push(last);
    }

    return parts.join(' ');
  }.property('firstName', 'lastName'),

  reset: function() {
    this.setProperties({
      firstName:    null,
      lastName:     null,
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

  actions: {
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
