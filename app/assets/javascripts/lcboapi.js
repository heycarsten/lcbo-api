//= require jquery
//= require ./vendor/beautify

var LCBOAPI = new function() {
  this.load = function() {
    $.each(LCBOAPI, function() {
      if (this.init) {
        this.init();
      }
    });
  };
};

LCBOAPI.UsageExampleForm = new function() {
  this.init = function() {
    $('.usage-example-form').submit(formHasBeenSubmitted);
    $('.usage-example-form').each(function(i, form) {
      refeshForm(form);
    });
  };

  function refeshForm(form) {
    var url = $(form).find('#query').val().trim();
    $.get(url, function(data) {
      var beaut = js_beautify(data, { indent_size: 2, indent_char: ' ' });
      $(form).find('.example-json-response').text(beaut);
    }, 'text');
  };

  function formHasBeenSubmitted(event) {
    event.preventDefault();
    refeshForm(this);
  };
};

$(LCBOAPI.load);
