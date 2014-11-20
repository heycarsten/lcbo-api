import Em from 'ember';

export default Em.Controller.extend({
  actions: {
    submit: function() {
      var controller = this;

      this.send('loading');

      Em.$.ajax({
        url: '/manager/passwords/' + this.get('token'),
        type: 'PUT',
        data: { password: this.get('password') }
      }).then(
        function(data) {
          Em.run(function() {
            controller.session.authenticate('authenticator:un-auth', data).then(function() {
              controller.transitionToRoute('dashboard.keys');
            });
          });
        },

        function(xhr) {
          Em.run(function() {
            // MEGAHAX :-/
            var err = Em.Object.create({
              remove: function(prop) {
                var val = this.get(prop);

                if (val) {
                  val.clear();
                }
              }
            });

            xhr.responseJSON.errors.forEach(function(e) {
              err[e.path.camelize()] = [{ message: e.detail }];
            });

            controller.set('errors', err);
            controller.send('loaded');
          });
        }
      );

    }
  }
});
