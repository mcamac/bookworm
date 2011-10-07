(function() {
  var $, i, options, placeholders, _ref;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  $ = jQuery;
  options = ["Term(s)", "Subject(s)"];
  placeholders = ['Cantabridgian', 'A'];
  for (i = 0, _ref = placeholders.length; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
    placeholders = placeholders[options[i]];
  }
  jQuery(function() {
    var searchBoxes;
    $.getJSON('static/json/cats.json', function(json) {
      var categories, headings, i, key, _ref, _results;
      categories = {};
      headings = [];
      if (key.length = 1) {
        headings = __indexOf.call(json, key) >= 0;
      }
      categories = {
        key: (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = json.length; _i < _len; _i++) {
            key = json[_i];
            _results.push(json[key]);
          }
          return _results;
        })()
      };
      $('#category-browser p').append(' <select class=catselect id=catselect multiple="multiple" size=10> </select>');
      headings = headings.sort();
      _results = [];
      for (i = 0, _ref = headings.length; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        _results.push($('#category-browser select').append('<option value=' + key + '>' + key + ': ' + categories[headings[i]] + '</option>'));
      }
      return _results;
    });
    $('body').append('<img id="feedback" src="static/images/feedback1.png" alt="feedback" width="100" height="30" />');
    $('#feedback').feedback();
    $('#feedback').colorbox({
      width: "50%",
      inline: true,
      href: "#fback"
    });
    console.log('DOM ready');
    searchBoxes = 0;
    addSearchBox();
    return $('#ngrams').val('Boston');
  });
}).call(this);
