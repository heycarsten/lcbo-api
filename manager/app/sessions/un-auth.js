import Session from 'simple-auth/session';

export default Session.extend({
  account: function() {
    return this.container.lookup('store:main').find('account', 'current');
  }.property('content.token')
});
