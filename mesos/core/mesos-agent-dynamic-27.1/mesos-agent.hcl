template {
  source = "/etc/consul-template/templates/mesos-agent.sysconfig"
  destination = "/var/run/consul-template/mesos-agent"
  command = "sudo systemctl restart mesos-agent.service"
}

template {
  source = "/etc/consul-template/templates/mesos-credential"
  destination = "/var/run/consul-template/mesos-credential"
  command = "sudo systemctl restart mesos-agent.service"
}

template {
  source = "/etc/consul-template/templates/mesos-agent-firewall-rules.json"
  destination = "/var/run/consul-template/mesos-agent-firewall-rules.json"
  command = "sudo systemctl restart mesos-agent.service"
}
