Learning about cookie-free website analytics by copying

- [plausible/analytics](https://github.com/plausible/analytics)
- [umami-software/umami](https://github.com/umami-software/umami)
- [electerious/Ackee](https://github.com/electerious/Ackee)

### Goals

- [ ] self-contained binary release
- [ ] low config
- [ ] easy disaster recovery
- [ ] low resource requirements

### How session durations are calculated

I read through [simpleanalytics/time-on-page](https://github.com/simpleanalytics/roadmap/issues/100), [plausible/863](https://github.com/plausible/analytics/discussions/863), [plausible/190](https://github.com/plausible/analytics/discussions/190), and decided to use something similar to [wakatime](https://wakatime.com) heartbeats:

```js
// client js-like pseudo-code
const INTERVAL = 5000;
var heartbeatTimer;

const stopTimer = () => {
  if (heartbeatTimer) removeInterval(heartbeatTimer);
};

const startTimer = () => {
  removeTimer();
  heartbeatTimer = setInterval(() => {
    post("https://klik.copycat.fun/api/heartbeats", { screen: screenSize() });
  }, INTERVAL);
};

document.on("load", () => startTimer());
document.on("pagehide", (h) => (h ? stopTimer() : startTimer()));
document.on("visibilitychange", (v) => (v ? startTimer() : stopTimer()));
```

```js
// server js-like pseudo-code (server is actually written in Elixir)

server.on("post", "/api/heartbeats", (req) => {
  const ua = req.headers["user-agent"];
  const { device, os, browser } = clientInfo(ua, req.body.json());
  const domain = req.headers["host"];
  // TODO
  const url = req.headers[""];
  const page = page(url);
  const ip = req.ip;
  const hash = hash(domain, ip, ua, salt());
  const time = Date();
  const heartbeat = { hash, time, page };

  DB.inTransaction(() => {
    const prevHeartbeat = DB.getHeartbeat(hash);

    if (prevHeartbeat) {
      const diff = heartbeat.time - prevHeartbeat.time;

      if (diff < SIX_MINUTES) {
        // prolong current session
      } else {
        // finish prev session, start new one
      }
    } else {
      // start new website session, page session
    }

    DB.insertHeartbeat(heartbeat);
  });
});
```
