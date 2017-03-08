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

Then the --privileged=true option must be used. This gives pacemaker the ability
to modify the IP addresses associated with local network devices. 

```
docker run -d -P --privileged=true --name=pcmk_test pacemaker_docker
```

Verify that pacemaker within the container is active.

```
docker exec -it pcmk_test bash
# docker exec -it pcmk_test bash
[root@5b26503f05f0 /]# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 03:39 ?        00:00:00 /bin/bash /usr/sbin/pcmk_launch.sh
root         16      1  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
root         23      1  2 03:39 ?        00:00:00 corosync
apache       25     16  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       26     16  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       27     16  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       28     16  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
apache       29     16  0 03:39 ?        00:00:00 /sbin/httpd -DFOREGROUND
root         37      1  0 03:39 ?        00:00:00 pacemakerd
haclust+     38     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/cib
root         39     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/stonithd
root         40     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/lrmd
haclust+     41     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/attrd
haclust+     42     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/pengine
haclust+     43     37  1 03:39 ?        00:00:00 /usr/libexec/pacemaker/crmd
root         45      0  0 03:39 ?        00:00:00 bash
root         63      1  0 03:39 ?        00:00:00 sleep 5
root         64     45  0 03:39 ?        00:00:00 ps -ef


[root@5b26503f05f0 /]# crm_mon -1
Stack: corosync
Current DC: 5b26503f05f0 (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Wed Mar  8 03:41:00 2017          Last change: Wed Mar  8 03:40:09 2017 by hacluster via crmd on 5b26503f05f0

1 node and 0 resources configured

Online: [ 5b26503f05f0 ]

No active resources

[root@5b26503f05f0 /]#  corosync-cmapctl | grep members
runtime.totem.pg.mrp.srp.members.1.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.1.ip (str) = r(0) ip(172.17.0.2)
runtime.totem.pg.mrp.srp.members.1.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.1.status (str) = joined

```
Verify that pacemaker within the container is active.

```
# docker exec -it pcmk_test  crm_mon -1
Stack: corosync
Current DC: test.com (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Tue Mar  7 07:58:14 2017          Last change: Tue Mar  7 07:56:57 2017 by hacluster via crmd on test.com

1 node and 0 resources configured

Online: [ test.com ]

No active resources

# docker exec pcmk_test  pcs status
Cluster name: docker
WARNING: corosync and pacemaker node names do not match (IPs used in setup?)
Stack: corosync
Current DC: test.com (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Tue Mar  7 08:07:18 2017          Last change: Tue Mar  7 08:04:35 2017 by root via cibadmin on test.com

1 node and 0 resources configured

Online: [ test.com ]

No resources


Daemon Status:
  corosync: inactive/disabled
  pacemaker: inactive/disabled
  pcsd: inactive/disabled


```

Verify that the container has access to the host's docker instance

```
# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
90ab96174d87        pacemaker_docker    "/bin/sh -c /usr/sbin"   About a minute ago   Up About a minute                       pcmk_test

```



