template {
  source = "/etc/consul-template/templates/traefik.toml.tmpl"
  destination = "/etc/traefik/traefik.toml"
  command = "sudo systemctl reload traefik.service"
}
