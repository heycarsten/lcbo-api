import Ember from 'ember';
import LoginControllerMixin from 'simple-auth/mixins/login-controller-mixin';

export default Ember.Controller.extend(LoginControllerMixin, {
  authenticator: 'authenticator:un-auth',

  actions: {
    // display an error when authentication fails
    authenticate: function() {
      var controller = this;

      this.send('loading');

      this._super().then(null, function(xhr) {
        var msg;

        if (xhr.status === 422) {
          msg = xhr.responseJSON.error.detail;
        } else {
          msg = 'an HTTP ' + xhr.status + ' error occurred on the server, try again';
        }

        controller.send('loaded');
        controller.set('errorMessage', msg.capitalize() + '.');
      });
    }
  }
});
