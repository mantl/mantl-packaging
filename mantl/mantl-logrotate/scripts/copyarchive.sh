#!/bin/bash
for component in "mesos" "docker" "zookeeper"; do
    systemctl status component
        if[ $? == 0 ]; then
            sudo cp component /var/log/component/archive
            sudo chmod 0644 /var/log/component/archive
        else
            echo component not active
        fi
done
