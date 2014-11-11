import ApplicationAdapter from 'manager/adapters/application';

export default ApplicationAdapter.extend({
  buildURL: function() {
    return '/manager/accounts';
  }
});
