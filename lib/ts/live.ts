Trabant.get_peek = function (assign) {
  // TODO: if there is not only one, check it and do it something with it
  const amperes = Trabant.amperes;
  for (const [key, value] of Object.entries(amperes)) {
    // console.log(`${key}: ${value}`);
    for (const [key2, value2] of Object.entries(value)) {
      // console.log(`${key2}: ${value2}`);
      if (key2 == assign) {
        return value2
      }
    }
  }
}

Trabant.poke = function (assign, what) {
  const amperes = Trabant.amperes;
  var i = 0;
  var assigns = [];
  // console.log(what);
  // console.log(amperes);
  for (const [key, value] of Object.entries(amperes)) {
    // console.log(`${i} ${key}: ${value}`);
    Trabant.update_attribute(key, "value", 77);
    for (const [key2, value2] of Object.entries(value)) {
      // console.log(`${key2}: ${value2}`);
      if (key2 == assign) {
        i++;
        // make is done in this object
        // value2 = what;
        // console.log("AAHA");
        // return value2
        assigns.push(key);
      }
    }
  }
  const result = i;
  // console.log(i);
  // console.log(assigns);
  // const selector = "[trabant_ampere=" + assigns.join("], [trabant_ampere=") + "]";
  // var found = document.querySelectorAll(selector);
  // // console.log(selector);
  // for (i = 0; i < found.length; i++) {
  //   var element = found[i];
  //   console.log(element);
  //   Trabant.update_attribute(element, "value", 77);
  //   // for (var property in what) {
  //   //   var value = what[property];
  //   //   console.log(value);
  //   // }
  // }
  return result;
}

function selector(ampere) {
  return "[trabant_ampere='" + ampere + "']";
}

function ampere_nodes(ampere, where) {
  var node = where ? where : document;
  return node.querySelectorAll(selector(ampere));
}

Trabant.update_attribute = function (ampere, attribute, new_value) {
  var nodes = ampere_nodes(ampere);
  var n = 0;
  console.log(nodes.length);
  for (var i = 0; i < nodes.length; i++) {
    var node = nodes[i];
    console.log(node);
    // a corner case for <input value="">
    if ((node.tagName.toUpperCase() == "INPUT" || node.tagName.toUpperCase() == "TEXAREA") && attribute.toLowerCase() == "value") {
      node.value = new_value;
      n++;
    }
    node.setAttribute(attribute, new_value);
  }
  return n;
}

Trabant.live_on_open = function () {
  const js = JSON.stringify({ function: "do_click", commander: "Trabant.Commander.on_open", params: JSON.stringify(Trabant.amperes) });
  return js;
}
