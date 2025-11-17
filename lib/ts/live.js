Trabant.get_peek = function (assign) {
    // TODO: if there is not only one, check it and do it something with it
    var amperes = Trabant.amperes;
    for (var _i = 0, _a = Object.entries(amperes); _i < _a.length; _i++) {
        var _b = _a[_i], key = _b[0], value = _b[1];
        // console.log(`${key}: ${value}`);
        for (var _c = 0, _d = Object.entries(value); _c < _d.length; _c++) {
            var _e = _d[_c], key2 = _e[0], value2 = _e[1];
            // console.log(`${key2}: ${value2}`);
            if (key2 == assign) {
                return value2;
            }
        }
    }
};
Trabant.poke = function (assign, what) {
    var amperes = Trabant.amperes;
    var i = 0;
    var assigns = [];
    // console.log(what);
    // console.log(amperes);
    for (var _i = 0, _a = Object.entries(amperes); _i < _a.length; _i++) {
        var _b = _a[_i], key = _b[0], value = _b[1];
        // console.log(`${i} ${key}: ${value}`);
        Trabant.update_attribute(key, "value", 77);
        for (var _c = 0, _d = Object.entries(value); _c < _d.length; _c++) {
            var _e = _d[_c], key2 = _e[0], value2 = _e[1];
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
    var result = i;
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
};
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
};
Trabant.live_on_open = function () {
    var js = JSON.stringify({ function: "do_click", commander: "Trabant.Commander.on_open", params: JSON.stringify(Trabant.amperes) });
    return js;
};
