FROM centos:centos7
RUN yum install -y --setopt=tsflags=no docs net-tools pacemaker resource-agents pcs corosync which fence-agents-common sysvinit-tools httpd
RUN yum clean
ADD /helper_scripts /usr/sbin
ADD defaults/corosync.conf /etc/corosync/
RUN echo 'hacluster:hacluster' | chpasswd
RUN mkdir -p /etc/systemd/system-preset/
RUN echo 'enable pcsd.service' > /etc/systemd/system-preset/00-pcsd.preset
RUN systemctl enable pcsd
EXPOSE 2224
CMD /usr/lib/systemd/systemd --system;/usr/sbin/pcmk_launch.sh
