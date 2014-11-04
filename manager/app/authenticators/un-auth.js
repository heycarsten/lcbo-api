import Authenticator from 'simple-auth/authenticators/base';
import Ember from 'ember';

export default Authenticator.extend({
  sessionUrl: '/v2/manager/session',

  restore: function(data) {
    return new Ember.RSVP.Promise(function(resolve, reject) {
      if (!Ember.isEmpty(data.token)) {
        resolve(data);
      } else {
        reject();
      }
    });
  },

  authenticate: function(credentials) {
    var _this = this;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        url: _this.sessionUrl,
        type: 'POST',
        contentType: 'application/vnd.api+json',
        data: JSON.stringify({
          session: {
            email: credentials.identification,
            password: credentials.password
          }
        })
      }).then(
        function(response) {
          Ember.run(function() {
            resolve({ token: response.session.token });
          });
        },

        function(xhr, status, error) {
          var response = JSON.parse(xhr.responseText);

          Ember.run(function() {
            reject(response.error);
          });
        }
      );
    });
  },

  invalidate: function() {
    var _this = this;

    return new Ember.RSVP.Promise(function(resolve) {
      Ember.$.ajax({
        url: _this.sessionUrl,
        type: 'DELETE'
      }).always(function() {
        resolve();
      });
    });
  }
});
