FROM centos:centos7
RUN yum install -y net-tools pacemaker resource-agents pcs corosync which fence-agents-common sysvinit-tools httpd fence-agents-all expect
RUN yum clean all
ADD /helper_scripts /usr/sbin
ADD /defaults /etc/corosync/
RUN echo 'hacluster:hacluster' | chpasswd
EXPOSE 2224
ENTRYPOINT /usr/sbin/pcmk_launch.sh
