# pacemaker_docker
Docker containerization of the Pacemaker High Availability Cluster Manager

## Example Create Image

Creating a docker container image is trivial. 

```
# git clone git@github.com:chio-nzgft/pacemaker_docker.git
# cd pacemaker_docker
# docker build -t pcmk_container .

```

## Launch standalone pacemaker instance for testing.

Then the --privileged=true option must be used. This gives pacemaker the ability
to modify the IP addresses associated with local network devices. 

```
docker run -d -P -v /var/run/docker.sock:/var/run/docker.sock --net=host --privileged=true --ip 192.168.0.67 --name=pcmk_test pacemaker_docker

```

Verify that pacemaker within the container is active.

```
docker exec pcmk_test crm_mon -1
  Last updated: Fri Jul 24 21:50:20 2015
  Last change: Fri Jul 24 21:49:36 2015
  Stack: corosync
  Current DC: 8e1eae1a7d0b (1) - partition with quorum
  Version: 1.1.12-a14efad
  1 Nodes configured
  0 Resources configured

  Online: [ 8e1eae1a7d0b ]
```

Verify that the container has access to the host's docker instance

```
docker exec pcmk_test docker ps
  CONTAINER ID        IMAGE                 COMMAND                CREATED             STATUS              PORTS               NAMES
  8e1eae1a7d0b        56992a77e0a9:latest   "/bin/sh -c /usr/sbi   7 seconds ago       Up 6 seconds                            pcmk_test        
```

Verify the containerized pacemaker instance can launch and monitor a
container on the docker host machine.
```
docker exec pcmk_test pcs property set stonith-enabled=false
docker exec pcmk_test pcs resource create mycontainer ocf:heartbeat:docker image=centos:centos7 run_cmd="sleep 100000"
```

## Launch an entire pacemaker cluster across multiple hosts.

The examples so far demonstrate how to build and launch a standalone single
instance pacemaker container. In practice, this is useless. All a standalone
pacemaker instance does is show us that we got the "containerize pacemaker"
part right. Now lets launch a real pacemaker cluster.

In order to do this, we need to know the static IP addresses of the hosts
machines that make up our pacemaker cluster. In this example, my static
IP addresses are 192.168.122.71 192.168.122.72 and 192.168.122.73. These
are the actual addresses assigned to a NIC on three docker host machines.

Once we know our three static IP addresses, launching a pacemaker cluster
is trivial. We can run the exact same set of commands on each host node.

First. load up the pacemaker container from the .tar file. You'll need to
copy the .tar file the 'pcmk_create_image' script generates to each host.
In this example, my container image ID is 248b5d9effc4.

```
docker load < pcmk_container_248b5d9effc4.tar
```

Now, all we have to do is launch the container and feed in a list of the
static IP addresses associated with the three nodes. The pacemaker container's
launch script knows how to take the PCMK_NODE_LIST environment variable and
dynamically create the corosync.conf file we need to form the cluster.

```
docker run -d -P -v /var/run/docker.sock:/var/run/docker.sock -e PCMK_NODE_LIST="192.168.122.71 192.168.122.72 192.168.122.73" --net=host --privileged=true --name=pcmk_test 248b5d9effc4
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


