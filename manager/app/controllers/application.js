import Em from 'ember';

export default Em.Controller.extend({
  year: function() {
    return new Date().getFullYear();
  }.property(),

  actions: {
    toggleAccountMenu: function() {
      this.toggleProperty('showAccountMenu');
    }
  },

  currentRouteClass: function() {
    var path = this.get('currentPath');
    return path.dasherize().replace(/\./g, '-');
  }.property('currentPath'),
});
