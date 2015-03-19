import Em from 'ember';

export default Em.Controller.extend({
  actions: {
    submit() {
      this.send('loading');

      Em.$.ajax({
        url: '/manager/passwords/' + this.get('token'),
        type: 'PUT',
        data: { password: this.get('password') }
      }).then(data => {
        Em.run(function() {
          this.session.authenticate('authenticator:un-auth', data).then(() => {
            this.transitionToRoute('dashboard.keys');
          });
        });
      }).catch(xhr => {
        Em.run(() => {
          // MEGAHAX :-/
          var err = Em.Object.create({
            remove: function(prop) {
              var val = this.get(prop);

              if (val) {
                val.clear();
              }
            }
          });

          xhr.responseJSON.errors.forEach(e => {
            err[e.path.camelize()] = [{ message: e.detail }];
          });

          this.set('errors', err);
          this.send('loaded');
        });
      });
    }
  }
});
