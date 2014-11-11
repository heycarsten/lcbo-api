import Em from 'ember';
import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  namespace: 'manager',

  ajaxError: function(xhr) {
    var errors = {};
    var error  = this._super(xhr);

    if (xhr && xhr.status === 422) {
      xhr.responseJSON.errors.forEach(function(err) {
        var path = err.path.camelize();

        if (Em.isNone(errors[path])) {
          errors[path] = [];
        }

        errors[path].push(err.detail);
      });

      return new DS.InvalidError(errors);
    } else {
      return error;
    }
  }
});
