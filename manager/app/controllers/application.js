import Em from 'ember';

export default Em.Controller.extend({
  year: function() {
    return new Date().getFullYear();
  }.property(),

  actions: {
    toggleAccountMenu: function() {
      var controller = this;

      if (this.get('showAccountMenu')) {
        return;
      }

      this.set('showAccountMenu', true);

      Em.run.next(function() {
        Em.$(document).one('click', function() {
          controller.set('showAccountMenu', false);
          return true;
        });
      });
    }
  },

  currentRouteClass: function() {
    var path = this.get('currentPath');
    return path.dasherize().replace(/\./g, '-');
  }.property('currentPath'),
});
