#!/bin/bash

echo start pcmk_test1 pcmk_testr2 pcmk_test3
docker run -d -P  --privileged=true --name=pcmk_test1 pacemaker_docker
docker run -d -P  --privileged=true --name=pcmk_test2 pacemaker_docker
docker run -d -P  --privileged=true --name=pcmk_test3 pacemaker_docker

echo Sleep 60 sec wait for Cluster start
sleep 60

echo copy 3 node config file
docker exec -it pcmk_test1 cp /etc/corosync/corosync-node3.conf /etc/corosync/corosync.conf
docker exec -it pcmk_test2 cp /etc/corosync/corosync-node3.conf /etc/corosync/corosync.conf
docker exec -it pcmk_test3 cp /etc/corosync/corosync-node3.conf /etc/corosync/corosync.conf

echo Start pcs auth
docker exec -it pcmk_test1 pcs cluster auth 172.17.0.3 172.17.0.4 172.17.0.5 -u hacluster -p hacluster

echo Start pcs auth again
docker exec -it pcmk_test1 pcs cluster auth 172.17.0.3 172.17.0.4 172.17.0.5 -u hacluster -p hacluster

echo Restart Cluster
docker exec -it pcmk_test1 sh /usr/sbin/pcmk_restart.sh &
docker exec -it pcmk_test2 sh /usr/sbin/pcmk_restart.sh &
docker exec -it pcmk_test3 sh /usr/sbin/pcmk_restart.sh &
