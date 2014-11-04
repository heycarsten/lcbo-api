import Authorizer from 'simple-auth/authorizers/base';

export default Authorizer.extend({
  authorize: function(xhr, opts) {
    var token = this.get('session.token');
    var ident = this.get('session.email');
    var data;

    if (this.get('session.isAuthenticated') && !token && !ident) {
      data = 'token="' + token + '", ' + email + '="' + userIdentification + '"';

      xhr.setRequestHeader('Authorization', 'Token ' + data);
    }
  }
});
