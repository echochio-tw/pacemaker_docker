# pacemaker_docker
Docker containerization of the Pacemaker High Availability Cluster Manager

## Example Create Image

Creating a docker container image is trivial. 

```
# git clone https://github.com/chio-nzgft/pacemaker_docker.git
# cd pacemaker_docker
# docker build -t pacemaker_docker .

```

## Launch standalone pacemaker instance for testing.
```
docker run -d -P  --privileged=true --name=pcmk_test pacemaker_docker
```

Verify that pacemaker within the container is active.

```
docker exec -it pcmk_test1 bash
# docker exec -it pcmk_test bash
[root@8106dd63b7c7 /]# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 07:59 ?        00:00:00 /bin/bash /usr/sbin/pcmk_launch.sh
root         18      1  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
root         19      1  0 07:59 ?        00:00:00 /usr/lib/systemd/systemd --system
root         32     19  0 07:59 ?        00:00:00 /usr/lib/systemd/systemd-journald
root         46     19  0 07:59 ?        00:00:00 /usr/sbin/lvmetad -f
root         47     19  0 07:59 ?        00:00:00 /usr/lib/systemd/systemd-udevd
apache       75     18  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       76     18  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       77     18  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       78     18  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       79     18  0 07:59 ?        00:00:00 /sbin/httpd -DFOREGROUND
dbus        100     19  0 07:59 ?        00:00:00 /bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation
root        102     19  0 07:59 ?        00:00:00 /usr/bin/ruby /usr/lib/pcsd/pcsd > /dev/null &
root        105     19  0 07:59 ?        00:00:00 /usr/lib/systemd/systemd-logind
root        115      1  0 07:59 ?        00:00:00 /usr/sbin/gssproxy -D
root        123     19  0 07:59 tty1     00:00:00 /sbin/agetty --noclear tty1 linux
root        140      0  0 07:59 ?        00:00:00 bash
root        165      1  1 07:59 ?        00:00:00 corosync
root        175      1  0 07:59 ?        00:00:00 pacemakerd
haclust+    176    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/cib
root        177    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/stonithd
root        178    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/lrmd
haclust+    179    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/attrd
haclust+    180    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/pengine
haclust+    181    175  0 07:59 ?        00:00:00 /usr/libexec/pacemaker/crmd
root        244      1  0 08:00 ?        00:00:00 sleep 5
root        245    140  0 08:00 ?        00:00:00 ps -ef

[root@8106dd63b7c7 /]# crm_mon -1
Stack: corosync
Current DC: 8106dd63b7c7 (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Wed Mar  8 08:00:54 2017          Last change: Wed Mar  8 07:59:55 2017 by hacluster via crmd on 8106dd63b7c7

1 node and 0 resources configured

Online: [ 8106dd63b7c7 ]

No active resources

[root@8106dd63b7c7 /]# corosync-cmapctl | grep members
runtime.totem.pg.mrp.srp.members.1.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.1.ip (str) = r(0) ip(172.17.0.2)
runtime.totem.pg.mrp.srp.members.1.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.1.status (str) = joined
```
Verify that pacemaker within the container is active.

```
# ]# docker exec -it pcmk_test  crm_mon -1
Stack: corosync
Current DC: 8106dd63b7c7 (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Wed Mar  8 08:01:35 2017          Last change: Wed Mar  8 07:59:55 2017 by hacluster via crmd on 8106dd63b7c7

1 node and 0 resources configured

Online: [ 8106dd63b7c7 ]

No active resources

# docker exec -it pcmk_test  pcs status
Cluster name: docker
WARNING: no stonith devices and stonith-enabled is not false
WARNING: corosync and pacemaker node names do not match (IPs used in setup?)
Stack: corosync
Current DC: 8106dd63b7c7 (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Wed Mar  8 08:01:57 2017          Last change: Wed Mar  8 07:59:55 2017 by hacluster via crmd on 8106dd63b7c7

1 node and 0 resources configured

Online: [ 8106dd63b7c7 ]

No resources


Daemon Status:
  corosync: inactive/disabled
  pacemaker: inactive/disabled
  pcsd: inactive/enabled

```

Verify that the container has access to the host's docker instance

```
#  docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
8106dd63b7c7        pacemaker_docker    "/bin/sh -c /usr/sbin"   3 minutes ago       Up 3 minutes        0.0.0.0:32777->2224/tcp   pcmk_test


```

if your docker next CONTAINER IP

```
172.17.0.3      pcmk_test1
172.17.0.4      pcmk_test2
172.17.0.5      pcmk_test3
```
Run cluster
```
docker run -d -P -e NODE1="172.16.0.2" -e NODE2="172.16.0.3" -e NODE3="172.16.0.4" --privileged=true --name=pcmk_test1 pacemaker_docker
docker run -d -P -e NODE1="172.16.0.2" -e NODE2="172.16.0.3" -e NODE3="172.16.0.4" --privileged=true --name=pcmk_test2 pacemaker_docker
docker run -d -P -e NODE1="172.16.0.2" -e NODE2="172.16.0.3" -e NODE3="172.16.0.4" --privileged=true --name=pcmk_test3 pacemaker_docker
```
Test cluster Auth
```
# docker exec -it pcmk_test1 pcs cluster auth 172.17.0.3 172.17.0.4 172.17.0.5 -u hacluster -p hacluster
172.17.0.3: Authorized
172.17.0.4: Authorized
172.17.0.5: Authorized
```

Use ngrok pass to out site
```
# docker ps -a |grep pcmk_test1
bfdd7ee90038        pacemaker_docker    "/bin/sh -c /usr/sbin"   3 minutes ago       Up 3 minutes        0.0.0.0:32778->2224/tcp   pcmk_test1

# /root/ngrok tcp 0.0.0.0:32778 

ngrok by @inconshreveable                                                                                                                                                                  (Ctrl+C to quit)

Session Status                online
Account                       hahaha (Plan: Free)
Version                       2.1.18
Region                        United States (us)
Web Interface                 http://127.0.0.1:4041
Forwarding                    tcp://0.tcp.ngrok.io:16300 -> 0.0.0.0:32778

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00

```
use https://0.tcp.ngrok.io:16300

![alt tag](https://github.com/chio-nzgft/pacemaker_docker/raw/master/pic1.png)




