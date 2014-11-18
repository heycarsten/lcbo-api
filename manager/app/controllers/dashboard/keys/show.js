import Em from 'ember';

export default Em.ObjectController.extend({
  isWeb:    Em.computed.equal('kind', 'web_client'),
  isServer: Em.computed.equal('kind', 'private_server'),
  isClient: Em.computed.equal('kind', 'native_client')
});
