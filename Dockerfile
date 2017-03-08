FROM centos:centos7
RUN yum install -y --setopt=tsflags=no docs net-tools pacemaker resource-agents pcs corosync which fence-agents-common sysvinit-tools httpd
RUN yum clean
ADD /helper_scripts /usr/sbin
ADD defaults/corosync.conf /etc/corosync/
RUN echo 'hacluster:hacluster' | chpasswd
EXPOSE 2224
ENTRYPOINT /usr/sbin/pcmk_launch.sh
