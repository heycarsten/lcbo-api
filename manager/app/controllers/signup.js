import Em from 'ember';

export default Em.Controller.extend({
  disabled: false,
  currentTemplate: 'signup/form',

  reset() {
    this.setProperties({
      name: null,
      email: null,
      password: null
    });
  },

  actions: {
    createAccount(model) {
      this.send('loading');

      model.save().then(() => {
        this.send('loaded');
        this.set('currentTemplate', 'signup/done');
      }).catch(() => {
        this.send('loaded');
      });
    }
  }
});
