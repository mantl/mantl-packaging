template {
  source = "/etc/consul-template/templates/traefik.toml"
  destination = "/var/run/consul-template/traefik.toml"
  command = "sudo systemctl restart traefik.service"
}
