import Em from 'ember';

var KINDS = [
  { id: 'private',       label: 'Private / Backend Application \u2014 PHP, ASP, JSP, Node, etc.' },
  { id: 'web_client',    label: 'Web Browser Application \u2014 JavaScript XHR / Ajax' },
  { id: 'native_client', label: 'Native Client Application \u2014 iOS, Android, Windows, etc.' }
];

export default Em.ObjectController.extend({
  kindOptions: KINDS,
  kind: 'private',
  isWebClient: Em.computed.equal('kind.id', 'web_client'),
  isClient: Em.computed.match('kind.id', /_client$/),

  actions: {
    createKey: function(model) {

    }
  }
});
