function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

//async function modifyText(new_text) {
//  const t2 = document.getElementById("t2");
//  await sleep(500);
//  t2.firstChild.nodeValue = new_text;
//}
//const el = document.getElementById("outside");

//const websock  = new WebSocket("ws://localhost:4000/websocket")
//websock.addEventListener("message", function (messageEvent) {
//    substrings = messageEvent.data.split(":")
//    console.log("aaaa " + substrings);
//    if (substrings[0] == "echo_server.click") {
//      document.getElementById("my-id").textContent = parseInt(document.getElementById("my-id").textContent, 10) + //parseInt(substrings[1], 10)
//    }
//    modifyText(messageEvent.data);
//  })
//websock.addEventListener("open", () => websock.send("echo_server.ping"))

//function sendText() {
//  websock.send("echo_server.bla");
//}

(function () {
  "use strict";
  window.Trabant = {
    create: function () {
      this.socket = new WebSocket("ws://localhost:4000/websocket");

      Trabant.socket.onopen = function (event) {
        // Handle connection open
        // console.log("socket opened");
        // console.log(event);
      };

      Trabant.socket.onmessage = function (event) {
        // Handle received message
        // console.log(event.data);
        // console.log("message received");
        // console.log(event);
        const data = eval(JSON.parse(event.data));
        // console.log(data);
        if (data.function == "exec_js") {
          // console.log(data.function);
          const d = eval(JSON.parse(data.input));
          // console.log(d);
          const json = JSON.stringify({ function: "return_exec_js", output: d, process_id: data.process_id });
          Trabant.socket.send_it(json);
        }
        //console.log(event);
      };

      Trabant.socket.onclose = function (event) {
        // Handle connection close
        console.log("closed");
      };

      Trabant.socket.send_it = function (json) {
        // console.log("send " + json);

        Trabant.socket.send(json);
      };
      //Trabant.socket.addEventListener("message", (event) => {
      //const pTag = document.createElement("p")
      //pTag.innerHTML = event.data

      //document.getElementById("main").append(pTag)
      //console.log("event message")
      //});
      console.log("Trabant created");
    },
    query: function (selector) {
      //console.log(selector)
      const node_id = document.querySelectorAll("#" + selector + "");
      // console.log(id.length);
      const params = new Array();
      for (var i = 0; i < node_id.length; i++) {
        params[i] = {
          id: node_id[i].id,
          text: node_id[i].innerText,
          html: node_id[i].innerHTML
        }
        // console.log(node_id);
      }
      // console.log(params)
      return JSON.stringify(params);
    },
    set_event_handlers: function () {
      // const input = document.getElementById("input");
      // const message = input.value;
      var trabants = document.querySelectorAll("input[trabant]");
      for (var i = 0; i < trabants.length; i++) {
        const t = trabants[i].getAttribute("trabant").split(":");
        if (t.length == 2) {
          if (t[0] == "click") {
            // console.log(trabants[i].id)
            const node_id = document.getElementById(trabants[i].id);
            // console.log("!!! " + trabants[i].id);
            // var params = {};
            var params = {
              id: trabants[i].id,
              value: trabants[i].value,
              trabant_attribute: trabants[i].getAttribute("trabant")
            };
            // console.log(params);
            const params_json = JSON.stringify(params);

            node_id.addEventListener("click", () => {
              // const params = new Array();

              // for (var i = 0; i < trabants.length; i++) {
              //   params[i] = {
              //     id: trabants[i].id,
              //     value: trabants[i].value,
              //     trabant_attribute: trabants[i].getAttribute("trabant")
              //   };
              // }

              // console.log(params_json);
              // const mynode_id = document.getElementById("my-node_id");

              const json = JSON.stringify({ function: "do_click", commander: t[1], params: params_json });
              Trabant.socket.send_it(json);
            })
          }
        }
      }
    }
  }
  Trabant.create();
  Trabant.set_event_handlers();
})();
