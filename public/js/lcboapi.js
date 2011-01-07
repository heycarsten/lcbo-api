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
    if (!$('#query').length) return;
    $('.usage-example-form').submit(formHasBeenSubmitted);
    getJSON();
  };

  function formHasBeenSubmitted(event) {
    event.preventDefault();
    getJSON();
  };

  function getJSON() {
    var url = $('#query').val().trim();
    $.get(url, replaceText, 'text');
  };

  function replaceText(data) {
    var beaut = js_beautify(data, { indent_size: 2, indent_char: ' ' });
    $('.example-json-response').text(beaut);
  };
};

$(LCBOAPI.load);
