// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

//Hooks.InfiniteScroll = {
//    scrollAt(){
//        let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
//        let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
//        let clientHeight = document.documentElement.clientHeight
//
//        return scrollTop / (scrollHeight-clientHeight) * 100
//    },
//    mounted(){
//        window.addEventListener("scroll", e => {
//            if(this.scrollAt() < 10) {
//                this.pushEvent("load_messages", {})
//            } 
//        })
//    }
//}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

if (document.querySelector("#body-editor")){
    require("./editor").Editor.run()
}


