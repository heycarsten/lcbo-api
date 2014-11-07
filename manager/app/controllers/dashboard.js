import Em from 'ember';

export default Em.Controller.extend({
  needs: 'application',

  currentPath: Em.computed.oneWay('controllers.application.currentPath'),

  inKeys:    Em.computed.match('currentPath', /^dashboard\.keys/),
  inAccount: Em.computed.match('currentPath', /^dashboard\.account/)
});
