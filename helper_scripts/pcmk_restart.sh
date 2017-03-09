#!/bin/bash
stop()
{
        desc="Pacemaker Cluster Manager"
        prog="pacemakerd"
        shutdown_prog=$prog

        if ! status $prog > /dev/null 2>&1; then
            shutdown_prog="crmd"
        fi

        cname=$(crm_node --name)
        crm_attribute -N $cname -n standby -v true -l reboot

        if status $shutdown_prog > /dev/null 2>&1; then
            kill -TERM $(pidof $prog) > /dev/null 2>&1

            while status $prog > /dev/null 2>&1; do
                sleep 1
                echo -n "."
            done
        else
            echo -n "$desc is already stopped"
        fi

        rm -f /var/lock/subsystem/pacemaker
        rm -f /var/run/${prog}.pid

        /usr/share/corosync/corosync stop > /dev/null 2>&1
        killall -q -9 'corosync'
        killall -q -9 'crmd stonithd attrd cib lrmd pacemakerd corosync'
}

start()
{
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

echo "Stop Pacemaker Cluster Manager ..."
stop

sleep 5

echo "Rtart Pacemaker Cluster Manager ..."
start

exit 0
