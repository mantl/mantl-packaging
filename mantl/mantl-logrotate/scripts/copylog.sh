#!/bin/bash
  for component in "mesos" "docker" "zookeeper"; do
      systemctl status component
          if[ $? == 0 ]; then
              cp component /etc/logrotate/
              chmod 0644 /etc/logrotate/component
          else
              echo component not active
          fi
  done
