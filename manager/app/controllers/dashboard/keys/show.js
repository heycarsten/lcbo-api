import Em from 'ember';

export default Em.Controller.extend({
  isWeb:    Em.computed.equal('model.kind', 'web_client'),
  isServer: Em.computed.equal('model.kind', 'private_server'),
  isClient: Em.computed.equal('model.kind', 'native_client'),

  currentMonth: Em.computed(function() {
    return moment().format('MMMM');
  }),

  actions: {
    deleteKey() {
      if (this.get('model.totalCycleRequests') > 0) {
        if (!confirm('Are you sure you want to delete this Access Key? Any integrations that are using it will stop working.')) {
          return;
        }
      }

      this.get('model').destroyRecord();
      this.transitionToRoute('dashboard.keys');
    }
  }
});
