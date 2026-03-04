resource "truenas_keychaincredential" "sirius_ssh_keypair" {
  name = "sirius-ssh-keypair"
  type = "SSH_KEY_PAIR"
  attributes = jsonencode({
    private_key = file("${path.module}/../../secrets/truenas_rsync_key")
    public_key  = file("${path.module}/../../secrets/truenas_rsync_key.pub")
  })
}

resource "truenas_keychaincredential" "sirius_ssh_connection" {
  name = "sirius-ssh-connection"
  type = "SSH_CREDENTIALS"
  attributes = jsonencode({
    host            = "192.168.1.150"
    port            = 22
    username        = "operator"
    private_key     = tonumber(truenas_keychaincredential.sirius_ssh_keypair.id)
    remote_host_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFL72xf0TKFDHyIvkLcfMfYdg9ZDD7p6gakbE77Lm0Mc"
    connect_timeout = 10
  })
}

resource "truenas_rsynctask" "config_to_sirius" {
  path            = "/mnt/primary/root/config"
  user            = "truenas_admin"
  mode            = "SSH"
  remotepath      = "/mnt/secondary/config-backup"
  ssh_credentials = tonumber(truenas_keychaincredential.sirius_ssh_connection.id)
  direction       = "PUSH"
  desc            = "Sync config to sirius backup (every 4 hours)"

  schedule = jsonencode({
    minute = "0"
    hour   = "*/4"
    dom    = "*"
    month  = "*"
    dow    = "*"
  })

  recursive    = true
  times        = true
  compress     = true
  archive      = true
  delete       = true
  delayupdates = true
  enabled      = true

  depends_on = [
    truenas_filesystem_setperm.root_perms,
    truenas_keychaincredential.sirius_ssh_connection
  ]
}
