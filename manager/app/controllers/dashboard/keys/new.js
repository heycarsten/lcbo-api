import Em from 'ember';

var KINDS = [
  { id: 'private_server', label: 'Backend / Server \u2014 PHP, ASP, Python, Java, Ruby, etc.' },
  { id: 'web_client',     label: 'Web Browser / Ajax \u2014 jQuery.ajax, WinJS, Angular, Dojo, etc.' },
  { id: 'native_client',  label: 'Desktop / Mobile \u2014 Apple iOS / Cocoa, Android, Blackberry, etc.' }
];

export default Em.ObjectController.extend({
  kindOptions: KINDS,
  isWebClient: Em.computed.equal('kind', 'web_client'),
  isClient:    Em.computed.match('kind', /_client$/),

  actions: {
    createKey: function(model) {
      var controller = this;

      model.save().then(function() {
        controller.transitionTo('dashboard.keys');
      }, Em.K);
    }
  }
});
