import Em from 'ember';

export default Em.Controller.extend({
  year: Em.computed(function() {
    return new Date().getFullYear();
  }),

  actions: {
    toggleAccountMenu() {
      if (this.get('showAccountMenu')) {
        return;
      }

      this.set('showAccountMenu', true);

      Em.run.next(() => {
        Em.$(document).one('click', () => {
          this.set('showAccountMenu', false);
          return true;
        });
      });
    }
  },

  currentRouteClass: Em.computed(function() {
    return this.get('currentPath').dasherize().replace(/\./g, '-');
  }).property('currentPath')
});
