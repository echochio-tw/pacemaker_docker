FROM centos:centos7
RUN yum install -y net-tools pacemaker resource-agents pcs corosync which fence-agents-common sysvinit-tools docker
ADD /helper_scripts /usr/sbin
ADD defaults/corosync.conf /etc/corosync/
RUN echo 'hacluster:hacluster' | chpasswd
ENTRYPOINT /usr/sbin/pcmk_launch.sh
