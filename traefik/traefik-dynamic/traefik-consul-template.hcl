template {
  source = "/etc/consul-template/templates/traefik.toml.tmpl"
  # TODO: confirm destination
  destination = "/etc/traefik/traefik.toml"
  command = "sudo systemctl reload traefik.service"
}
