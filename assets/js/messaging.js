export var Messaging = {run: function() {
    var button = document.getElementById("send")

    button.addEventListener("click", scrollPage)

    function scrollPage() {
        window.scroll(0, document.documentElement.scrollHeight)
    }
}}
