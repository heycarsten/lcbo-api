import Em from 'ember';

export default Em.Controller.extend({
  application: Em.inject.controller(),

  currentPath: Em.computed.reads('application.currentPath'),

  inKeys:    Em.computed.match('currentPath', /^dashboard\.keys/),
  inAccount: Em.computed.match('currentPath', /^dashboard\.account/)
});
