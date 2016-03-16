template {
  source = "/etc/consul-template/templates/marathon.sysconfig"
  destination = "/var/run/consul-template/marathon"
  command = "sudo systemctl restart marathon.service"
}
