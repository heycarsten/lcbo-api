import Authenticator from 'manager/authenticators/un-auth';
import Authorizer from 'manager/authorizers/un-auth';
import Session from 'manager/sessions/un-auth';

export default {
  name: 'authentication',
  before: 'simple-auth',

  initialize: function(container) {
    container.register('authenticator:un-auth', Authenticator);
    container.register('authorizer:un-auth', Authorizer);
    container.register('session:un-auth', Session);
  }
};
