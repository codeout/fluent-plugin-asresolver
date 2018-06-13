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


## :warning: Supported gobgpd version :warning:

Use v1.32 and DO NOT USE newer version. It'll cause fluentd crash.

```
commit a6e0d00a705146e6b7f72a4d58c61b063980cc65
Author: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date:   Fri Jun 1 20:32:28 2018 +0900

    GoBGP 1.32

    Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
```


## Copyright and License

Copyright (c) 2018 Shintaro Kojima. Code released under the [Apache License, Version 2.0](LICENSE).