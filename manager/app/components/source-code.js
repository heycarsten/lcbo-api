import Em from 'ember';

export default Em.Component.extend({
  tagName: 'pre',

  classNameBindings: [
    'className'
  ],

  className: function() {
    return 'language-' + this.get('lang');
  }.property('lang'),

  runHighlighter: function() {
    var view = this;

    Em.run.next(function() {
      Prism.highlightElement(view.get('element'));
    });
  }.on('didInsertElement')
});
