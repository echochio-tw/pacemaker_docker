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
docker run -d -P -v --privileged=true --name=pcmk_test pacemaker_docker
```

Verify that pacemaker within the container is active.

```
docker exec -it pcmk_test bash
[root@test /]# ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 07:52 ?        00:00:00 /bin/bash /usr/sbin/pcmk_launch.sh
root         13      1  1 07:52 ?        00:00:00 corosync
root         22      1  0 07:52 ?        00:00:00 pacemakerd
haclust+     23     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/cib
root         24     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/stonithd
root         25     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/lrmd
haclust+     26     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/attrd
haclust+     27     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/pengine
haclust+     28     22  0 07:52 ?        00:00:00 /usr/libexec/pacemaker/crmd
root         85      0  0 07:52 ?        00:00:00 bash
root        101      1  0 07:52 ?        00:00:00 sleep 5
root        102     85  0 07:52 ?        00:00:00 ps -ef

[root@test /]# crm_mon -1
Stack: corosync
Current DC: test.com (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
Last updated: Tue Mar  7 07:56:58 2017          Last change: Tue Mar  7 07:56:57 2017 by hacluster via crmd on test.com

1 node and 0 resources configured

Online: [ test.com ]

No active resources


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



