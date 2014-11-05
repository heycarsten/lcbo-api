import Ember from 'ember';
import LoginControllerMixin from 'simple-auth/mixins/login-controller-mixin';

export default Ember.Controller.extend(LoginControllerMixin, {
  authenticator: 'authenticator:un-auth',

  actions: {
    // display an error when authentication fails
    authenticate: function() {
      var controller = this;

      this._super().then(null, function(msg) {
        controller.set('errorMessage', msg);
      });
    }
  }
});
