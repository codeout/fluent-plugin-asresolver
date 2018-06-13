# fluent-plugin-asresolver

## Overview

Fluentd filter plugin to resolve origin AS of src / dst IP addresses with gobgpd lookup.

This plugin assumes that gobgpd running at localhost. Latency matters.


## :bulb: TIPS: How to configure gobgpd remotely

Let's say you have vanilla gobgpd running at fluentd server,

```shell
client $ gobgp -u <fluentd-server> global as <asn> router-id <router-id> listen-port 179
client $ gobgp -u <fluentd-server> neighbor add <neighbor-address> as <peer-asn>
client $ gobgp -u <fluentd-server> neighbor
```

## :warning: Supported address families :warning:

IPv4 only. We're sorry about that.


## Copyright and License

Copyright (c) 2018 Shintaro Kojima. Code released under the [Apache License, Version 2.0](LICENSE).