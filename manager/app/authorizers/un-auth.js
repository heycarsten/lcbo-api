import Authorizer from 'simple-auth/authorizers/base';

export default Authorizer.extend({
  authorize: function(xhr) {
    var token = this.get('session.token');

    if (this.get('session.isAuthenticated') && token) {
      xhr.setRequestHeader('Authorization', 'Token ' + token);
    }
  }
});
