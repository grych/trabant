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
