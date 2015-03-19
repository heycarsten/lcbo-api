import Em from 'ember';

var KINDS = [
  { id: 'private_server', label: 'Backend / Server \u2014 PHP, ASP, Python, Java, Ruby, etc.' },
  { id: 'web_client',     label: 'Web Browser / Ajax \u2014 jQuery.ajax, WinJS, Angular, Dojo, etc.' },
  { id: 'native_client',  label: 'Desktop / Mobile \u2014 Apple iOS / Cocoa, Android, Blackberry, etc.' }
];

export default Em.Controller.extend({
  kindOptions: KINDS,
  isWebClient: Em.computed.equal('model.kind', 'web_client'),
  isClient:    Em.computed.match('model.kind', /_client$/),

  actions: {
    createKey(model) {
      model.save().then(() => {
        this.transitionTo('dashboard.keys');
      }, Em.K);
    }
  }
});
