/* eslint-env browser */

(function (window) {
  if (!window) return;
  var t;

  function data() {
    var referer =
      (window.document.referrer || "")
        // .replace(locationHostname, definedHostname)
        .replace(/^https?:\/\/((m|l|w{2,3}([0-9]+)?)\.)?([^?#]+)(.*)$/, "$4")
        .replace(/^([^/]+)$/, "$1") || undefined;

    return {
      // TODO https://web.dev/user-agent-client-hints/?
      // TODO why not window.screen.width?
      w: window.innerWidth,
      u: window.location.href,
      d: window.location.hostname,
      r: referer,
    };
  }

  function post(data) {
    var xhr = new XMLHttpRequest();
    // xhr.open("POST", "http://10.1.30.130:4000/api/heartbeats", true);
    xhr.open("POST", "http://localhost:4000/api/heartbeats", true);
    // TODO
    // xhr.setRequestHeader("Content-Type", "text/plain; charset=UTF-8");
    xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
    xhr.send(JSON.stringify(data));
  }

  function startTimer() {
    stopTimer();
    t = setInterval(function () {
      console.log("timer fired!");
      post(data());
    }, 5000);
  }

  function stopTimer() {
    if (t) {
      clearInterval(t);
    }
  }

  document.addEventListener("visibilitychange", function () {
    console.log("visible?", !document.hidden);
    document.hidden ? stopTimer() : startTimer();
  });

  post(data());
  startTimer();
})(window);
