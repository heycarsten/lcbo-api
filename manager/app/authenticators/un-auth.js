import Authenticator from 'simple-auth/authenticators/base';
import Ember from 'ember';

export default Authenticator.extend({
  restore: function(data) {
    var expiresAt = data.expiresAt;
    var token     = data.token;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      if (token && expiresAt && moment().isBefore(expiresAt)) {
        Ember.$.ajax({
          url: '/manager/session',
          type: 'PUT',
          headers: {
            Authorization: 'Token ' + token
          }
        }).then(
          function(response) {
            Ember.run(function() {
              resolve({
                token:     response.session.token,
                expiresAt: response.session.expires_at
              });
            });
          },

          function() {
            Ember.run(function() {
              reject();
            });
          }
        );
      } else {
        reject();
      }
    });
  },

  authenticate: function(credentials) {
    return new Ember.RSVP.Promise(function(resolve, reject) {
      if (credentials.session) {
        resolve({
          token: credentials.session.token,
          expiresAt: credentials.session.expires_at
        });

        return;
      }

      Ember.$.ajax({
        url: '/manager/sessions',
        type: 'POST',
        contentType: 'application/json',
        headers: {
          Accept: 'application/vnd.api+json'
        },
        data: JSON.stringify({
          session: {
            email: credentials.identification,
            password: credentials.password
          }
        })
      }).then(
        function(response) {
          Ember.run(function() {
            resolve({
              token: response.session.token,
              expiresAt: response.session.expires_at
            });
          });
        },

        function(xhr) {
          Ember.run(function() {
            reject(xhr);
          });
        }
      );
    });
  },

  invalidate: function() {
    return new Ember.RSVP.Promise(function(resolve) {
      Ember.$.ajax({
        url: '/manager/session',
        type: 'DELETE'
      }).always(function() {
        resolve();
      });
    });
  }
});
