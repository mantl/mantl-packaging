datacenter = "dc1"
data_dir = "/var/lib/nomad"
log_level = "INFO"

server {
  enabled = true
  # bootstrap_expect = 1
}

client {
  enabled = true
  # servers = [ ]
}
