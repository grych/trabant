function sleep(ms) {
    return new Promise(function (resolve) { return setTimeout(resolve, ms); });
}
(function () {
    "use strict";
    window.Trabant = {
        create: function () {
            this.socket = new WebSocket("ws://localhost:4000/websocket");
            Trabant.socket.onmessage = function (event) {
                // Handle received message
                // console.log(event.data);
                // console.log("message received");
                // console.log(event);
                var data = eval(JSON.parse(event.data));
                // console.log(data);
                if (data.function == "exec_js") {
                    // console.log(data.function);
                    var d = eval(JSON.parse(data.input));
                    // console.log(d);
                    var json = JSON.stringify({ function: "return_exec_js", output: d, process_id: data.process_id });
                    // console.log(data);
                    Trabant.socket.send_it(json);
                }
                //console.log(event);
            };
            Trabant.socket.onclose = function (event) {
                // Handle connection close
                console.log("closed");
            };
            Trabant.socket.onopen = function (event) {
                var json = Trabant.live_on_open();
                //  JSON.stringify({ function: "do_click", commander: "Trabant.Commander.on_open", params: JSON.stringify(Trabant.amperes)});
                Trabant.socket.send_it(json);
            };
            Trabant.socket.send_it = function (json) {
                // console.log("send " + json);
                Trabant.socket.send(json);
            };
        },
        query: function (selector) {
            //console.log(selector)
            var node_id = document.querySelectorAll("#" + selector + "");
            // console.log(id.length);
            var params = new Array();
            for (var i = 0; i < node_id.length; i++) {
                params[i] = {
                    id: node_id[i].id,
                    text: node_id[i].innerText,
                    html: node_id[i].innerHTML
                };
                // console.log(node_id);
            }
            // console.log(params)
            return JSON.stringify(params);
        },
        set_event_handlers: function () {
            // const input = document.getElementById("input");
            // const message = input.value;
            var trabants = document.querySelectorAll("input[trabant]");
            var _loop_1 = function () {
                var t = trabants[i].getAttribute("trabant").split(":");
                if (t.length == 2) {
                    if (t[0] == "click") {
                        // console.log(trabants[i].id)
                        var node_id = document.getElementById(trabants[i].id);
                        // console.log("!!! " + trabants[i].id);
                        // var params = {};
                        params = {
                            id: trabants[i].id,
                            value: trabants[i].value,
                            trabant_attribute: trabants[i].getAttribute("trabant")
                        };
                        // console.log(params);
                        var params_json_1 = JSON.stringify(params);
                        node_id.addEventListener("click", function () {
                            var json = JSON.stringify({ function: "do_click", commander: t[1], params: params_json_1 });
                            Trabant.socket.send_it(json);
                        });
                    }
                }
            };
            var params;
            for (var i = 0; i < trabants.length; i++) {
                _loop_1();
            }
        }
    };
    Trabant.create();
    Trabant.set_event_handlers();
})();
