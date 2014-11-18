import Em from 'ember';

export default Em.ObjectController.extend({
  isWeb:    Em.computed.equal('kind', 'web_client'),
  isServer: Em.computed.equal('kind', 'private_server'),
  isClient: Em.computed.equal('kind', 'native_client'),

  currentMonth: function() {
    return moment().format('MMMM');
  }.property(),

  actions: {
    deleteKey: function() {
      if (this.get('totalCycleRequests') > 0) {
        if (!confirm('Are you sure you want to delete this Access Key? Any integrations that are using it will stop working.')) {
          return;
        }
      }

      this.get('model').destroyRecord();
      this.transitionToRoute('dashboard.keys');
    }
  }
});
