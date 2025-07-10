Trabant.get_peek = function (ampere) {
  var trabants = document.querySelectorAll("[trabant_ampere]");
  for (var i = 0; i < trabants.length; i++) {
    var element = trabants[i];
    // element.drab_disable_state = element.disabled;
    for (var j = 0; j < element.attributes.length; j++) {
      if (element.attributes[j].nodeValue == ampere) {
        // TODO: if there is more than one
        // console.log(element);
        // TODO
        return element.innerHTML;
      }
    }
  };
}
