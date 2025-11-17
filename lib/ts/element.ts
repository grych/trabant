Trabant.set_prop = function (selector, what, where) {
  var searchie = where || document;
  var i = 0;
  var found = searchie.querySelectorAll(selector);
  for (i = 0; i < found.length; i++) {
    var element = found[i];
    for (var property in what) {
      var value = what[property];
      switch (property) {
        case "attributes":
          for (var p in value) {
            element.setAttribute(p, value[p]);
          }
          break;
        case "classList":
          element.classList = "";
          for (var p in value) {
            element.classList.add(value[p]);
          }
          break;
        case "style":
          for (var p in value) {
            element[property][p] = value[p];
          }
          break;
        case "dataset":
          for (var p in value) {
            element[property][p] = value[p];
          }
          break;
        case "innerHTML":
          element[property] = what[property];
          // Drab.enable_drab_on(selector);
          break;
        case "outerHTML":
          var parent = element.parentNode;
          element[property] = what[property];
          // Drab.enable_drab_on(parent);
          break;
        case "options":
          if (element.options instanceof HTMLOptionsCollection) {
            element.length = 0;
            for (var p in value) {
              var option = document.createElement("option");
              option.value = p;
              option.text = value[p];
              element.add(option);
            }
          } else {
            element[property] = what[property];
          }
          break;

        default:
          element[property] = what[property];
          break;
      }
    }
  };
  return i;
}

Trabant.get_prop = function (selector, what, where) {
  var searchie = where || document;
  var ret = {};
  var found = searchie.querySelectorAll(selector);
  for (var i = 0; i < found.length; i++) {
    var element = found[i];
    var id = element.id;
    var id_selector;
    if (id) {
      id_selector = "#" + id;
    } else {
      var drab_id = Drab.setid(element);
      id_selector = "[trabant-id='" + drab_id + "']";
    }
    ret[id_selector] = {};
    if (what.length != 0) {
      for (var j in what) {
        var property = what[j];
        switch (property) {
          case "attributes":
            ret[id_selector][property] = get_element_attributes(element);
            break;
          case "style":
            ret[id_selector][property] = to_map(element.style);
            break;
          case "classList":
            ret[id_selector][property] = to_array(element.classList);
            break;
          case "options":
            var options = element.options;
            if (options instanceof HTMLOptionsCollection) {
              var ret_options = {};
              for (var j = 0; j < options.length; j++) {
                ret_options[options[j].value] = options[j].text;
              }
              ret[id_selector][property] = ret_options;
            } else {
              ret[id_selector][property] = element.options;
            }
            break;
          default:
            ret[id_selector][property] = element[property];
            break;
        }
      }
    } else {
      ret[id_selector] = default_properties(element);
    }
  };
  return ret;
};

