import Em from 'ember';

export default Em.View.extend({
  classNames: 'app',
  classNameBindings: [
    'controller.currentRouteClass',
    'controller.isLoading:loading:loaded'
  ]
});
