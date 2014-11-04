import Authenticator from 'manager/authenticators/un-auth';
import Authorizer from 'manager/authorizers/un-auth';

export default {
  name: 'authentication',
  before: 'simple-auth',

  initialize: function(container) {
    container.register('authenticator:un-auth', Authenticator);
    container.register('authorizer:un-auth', Authorizer);
  }
};
