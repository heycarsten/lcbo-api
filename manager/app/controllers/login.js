import Ember from 'ember';
import LoginControllerMixin from 'simple-auth/mixins/login-controller-mixin';

export default Ember.Controller.extend(LoginControllerMixin, {
  authenticator: 'authenticator:un-auth',
  needs: 'application',
  isLoading: Em.computed.alias('controllers.application.isLoading'),

  actions: {
    // display an error when authentication fails
    authenticate: function() {
      var controller = this;

      this.set('isLoading', true);

      this._super().then(
        function() {
          controller.set('isLoading', false);
        },

        function(xhr) {
          var msg;

          if (xhr.status === 422) {
            msg = xhr.responseJSON.error.detail;
          } else {
            msg = 'an HTTP ' + xhr.status + ' error occurred on the server, try again';
          }

          controller.set('isLoading', false);
          controller.set('errorMessage', msg.capitalize() + '.');
        }
      );
    }
  }
});
