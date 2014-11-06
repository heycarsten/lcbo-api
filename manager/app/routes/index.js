import Em from 'ember';

export default Em.Route.extend({
  redirect: function() {
    this.replaceWith('keys');
  }
});
