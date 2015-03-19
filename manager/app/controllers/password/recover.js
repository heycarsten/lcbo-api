import Em from 'ember';

export default Em.Controller.extend({
  email: null,

  subTemplate: 'password/recover/form',

  reset() {
    this.set('email', null);
    this.set('subTemplate', 'password/recover/form');
  },

  actions: {
    submit() {
      this.send('loading');

      Em.$.ajax({
        url:  '/manager/passwords',
        type: 'POST',
        data: { email: this.get('email') }
      }).always(() => {
        Em.run(() => {
          this.set('subTemplate', 'password/recover/done');
          this.send('loaded');
        });
      });
    }
  }
});
