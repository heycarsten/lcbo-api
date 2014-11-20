import Em from 'ember';

export default Em.Controller.extend({
  email: null,

  subTemplate: 'password/recover/form',

  reset: function() {
    this.set('email', null);
    this.set('subTemplate', 'password/recover/form');
  },

  actions: {
    submit: function() {
      var controller = this;

      this.send('loading');

      Em.$.ajax({
        url:  '/manager/passwords',
        type: 'POST',
        data: { email: this.get('email') }
      }).always(function() {
        Em.run(function() {
          controller.set('subTemplate', 'password/recover/done');
          controller.send('loaded');
        });
      });
    }
  }
});
