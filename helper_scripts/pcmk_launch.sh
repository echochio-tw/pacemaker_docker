#!/bin/bash

start()
{
        if [ ! -n "$IP" ]; then
                export IP=`ip addr |grep "scope global eth0"|sed 's/    inet //g'|sed 's/\/16 scope global eth0//g'`
                sed -i 's/127.0.0.1/'$(echo $IP)'/g' /etc/corosync/corosync.conf
                sed -i 's/Listen 80/Listen '$(echo $IP)':80/g' /etc/httpd/conf/httpd.conf
                mkdir -p /etc/systemd/system-preset/
                echo 'enable pcsd.service' > /etc/systemd/system-preset/00-pcsd.preset
                systemctl enable pcsd
        fi

        rm -f /usr/local/apache2/logs/httpd.pid

        /sbin/httpd -DFOREGROUND &
        /usr/lib/systemd/systemd --system &

        sleep 30

        /usr/share/corosync/corosync start > /dev/null 2>&1
        mkdir -p /var/run

        export PCMK_debugfile=/var/log/pacemaker.log
        (pacemakerd &) & > /dev/null 2>&1
        sleep 5

        pid=$(pidof pacemakerd)
        if [ "$?" -ne 0 ]; then
                echo "startup of pacemaker failed"
                exit 1
        fi
        echo "$pid" > /var/run/pacemakerd.pid
}

start

while true; do
done

exit 0
