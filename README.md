Learning about privacy-friendly website analytics by copying

- [plausible/analytics](https://github.com/plausible/analytics)
- [umami-software/umami](https://github.com/umami-software/umami)
- [electerious/Ackee](https://github.com/electerious/Ackee)

### Goals

- [ ] self-contained binary release
- [ ] low config
- [ ] easy disaster recovery
- [ ] low resource requirements

### How session durations are calculated

I was suprised to learn that there are multiple ways to calculate session durations. I read through [simpleanalytics/time-on-page](https://github.com/simpleanalytics/roadmap/issues/100), [plausible/863](https://github.com/plausible/analytics/discussions/863), [plausible/190](https://github.com/plausible/analytics/discussions/190), and decided to use something similar to [wakatime](https://wakatime.com) heartbeats. Compared to wakatime, you can think of websites as projects and pages as branches. For a single user session / visit, page durations don't overlap.
