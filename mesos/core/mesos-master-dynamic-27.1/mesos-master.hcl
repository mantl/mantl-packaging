template {
  source = "/etc/consul-template/templates/mesos-master.sysconfig"
  destination = "/var/run/consul-template/mesos-master"
  command = "sudo systemctl restart mesos-master.service"
}

template {
  source = "/etc/consul-template/templates/mesos-credentials"
  destination = "/var/run/consul-template/mesos-credentials"
  command = "sudo systemctl restart mesos-master.service"
}

template {
  source = "/etc/consul-template/templates/mesos-master-firewall-rules.json"
  destination = "/var/run/consul-template/mesos-master-firewall-rules.json"
  command = "sudo systemctl restart mesos-master.service"
}
