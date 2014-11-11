// Adapted from https://gist.github.com/ebryn/9061707

import Ember from 'ember';

var get = Ember.get;
var set = Ember.set;
var doc = document;

export default Ember.Component.extend({
  tagName:   'select',
  items:     null,
  valuePath: 'id',
  labelPath: 'label',
  value:     null,
  selected:  null,
  attributeBindings: ['tabindex'],

  didInsertElement: function () {
    var self = this;

    this.$().on('change', function () {
      set(self, 'value', this.value);
    });
  },

  valueDidChange: function () {
    var items = this.items, value = this.value, selected = null;

    if (value && items) {
      selected = items.findBy(this.valuePath, value);
    }

    set(this, 'selected', selected);
  }.observes('value').on('init'),

  itemsWillChange: function () {
    var items = this.items;

    if (items) {
      items.removeArrayObserver(this);
      this.arrayWillChange(items, 0, get(items, 'length'), 0);
    }
  }.observesBefore('items').on('willDestroyElement'),

  itemsDidChange: function () {
    var items = this.items;

    if (items) {
      items.addArrayObserver(this);
      this.arrayDidChange(items, 0, 0, get(items, 'length'));
    }
  }.observes('items').on('didInsertElement'),

  arrayWillChange: function (items, start, removeCount, addCount) {
    var select = get(this, 'element');
    var options = select.childNodes;

    for (var i = start+removeCount-1; i >= start; i--) {
      select.removeChild(options[i]);
    }
  },

  arrayDidChange: function (items, start, removeCount, addCount) {
    var select = get(this, 'element');

    for (var i = start, l = start+addCount; i < l; i++) {
      var item = items.objectAt(i);
      var value = get(item, this.valuePath);
      var label = get(item, this.labelPath);
      var option = doc.createElement('option');

      option.textContent = label;
      option.value = value;

      if (this.value === value) {
        option.selected = true;
        set(this, 'selected', item);
      }

      select.appendChild(option);
    }

    set(this, 'value', select.value);
  }
});
