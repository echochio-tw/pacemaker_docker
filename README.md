# pacemaker_docker
Docker containerization of the Pacemaker High Availability Cluster Manager

## Example Create Image

Creating a docker container image is trivial. 

```
# git clone git@github.com:chio-nzgft/pacemaker_docker.git
# cd pacemaker_docker
# docker build -t pacemaker_docker .

```

## Launch standalone pacemaker instance for testing.

Then the --privileged=true option must be used. This gives pacemaker the ability
to modify the IP addresses associated with local network devices. 

```
docker run -d -P -v /var/run/docker.sock:/var/run/docker.sock --net=host --privileged=true --name=pcmk_test pacemaker_docker

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

Verify the containerized pacemaker instance can launch and monitor a
container on the docker host machine.
```
docker exec pcmk_test pcs property set stonith-enabled=false
docker exec pcmk_test pcs resource create mycontainer ocf:heartbeat:docker image=centos:centos7 run_cmd="sleep 100000"
```

## Launch an entire pacemaker cluster across multiple hosts.

```
docker load < pcmk_container_248b5d9effc4.tar
```

Now, all we have to do is launch the container and feed in a list of the
static IP addresses associated with the three nodes. The pacemaker container's
launch script knows how to take the PCMK_NODE_LIST environment variable and
dynamically create the corosync.conf file we need to form the cluster.

```
docker run -d -P -v /var/run/docker.sock:/var/run/docker.sock -e PCMK_NODE_LIST="192.168.122.71 192.168.122.72 192.168.122.73" --net=host --privileged=true --name=pcmk_test pacemaker_docker
```

Now, after executing those two commands on each host, you should be able
to run 'crm_mon -1' to verify the cluster formed. In my case, executing
crm_mon -1 within a container running pacemaker returns the following.

```
docker exec pcmk_test crm_mon -1
Last updated: Tue Jul 28 14:57:44 2015
Last change: Tue Jul 28 14:57:43 2015
Stack: corosync
Current DC: c7auto2 (2) - partition with quorum
Version: 1.1.12-a14efad
3 Nodes configured
0 Resources configured


Online: [ c7auto1 c7auto2 c7auto3 ]
```

My three host machines are c7auto<1-3>. Pacemaker running in the container adpoted
the hostname of the docker host machine because I set --net=host.

## Virtual IP addresses and the Cloud.

Traditionally pacemaker manages a VIP using the IPaddr2 resource-agent. This
agent assigns a VIP to a local NIC, then performs ARP updates to inform the
switching hardware that the VIP's layer2 MAC has changed. This method works
fine in containerized docker instances as long as we have control over the
network. By using the --net=host and --privileged=true docker run options,
the pacemaker docker container has all the permissions it needs to manage
VIPs using IPaddr2.

In a cloud environment, we might not be able to dynamically assign any IP we
want to a host. Instead we may need to use the cloud provider's API to assign
a VIP to a specfic compute instance. If pacemaker needs to coordinate this
VIP assignment, we'll need to create a resource-agent that utilizes the cloud
providers API in order to automate moving the VIP between hosts during failover.


