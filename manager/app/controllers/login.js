import Em from 'ember';
import LoginControllerMixin from 'simple-auth/mixins/login-controller-mixin';

export default Em.Controller.extend(LoginControllerMixin, {
  authenticator: 'authenticator:un-auth',

  actions: {
    // display an error when authentication fails
    authenticate: function() {
      this.send('loading');

      this._super().catch(xhr => {
        var msg;

        if (xhr.status === 422) {
          msg = xhr.responseJSON.error.detail;
        } else {
          msg = `an HTTP ${xhr.status} error occurred on the server, try again`;
        }

        this.send('loaded');
        this.set('errorMessage', msg.capitalize() + '.');
      });
    }
  }
});
