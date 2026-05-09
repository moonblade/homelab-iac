variable "vmid" {
  type = number
}

variable "target_node" {
  type = string
}

variable "hostname" {
  type = string
}

variable "ostemplate" {
  description = "LXC template path. Eg: local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  type        = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "unprivileged" {
  type    = bool
  default = true
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "swap" {
  description = "Swap in MB"
  type        = number
  default     = 512
}

variable "rootfs_storage" {
  type    = string
  default = "local-lvm"
}

variable "rootfs_size" {
  description = "Root filesystem size. Eg: 20G"
  type        = string
  default     = "20G"
}

variable "ipv4_addr" {
  description = "Static ipv4 address for the container. Eg: 192.168.1.100/24"
  type        = string
}

variable "ipv4_gw" {
  description = "Ipv4 gateway. Eg: 192.168.1.1"
  type        = string
}

variable "nameserver" {
  type    = string
  default = "1.1.1.1"
}

variable "sshkeys" {
  description = "SSH public keys (newline-separated)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Semicolon-separated tags for the container"
  type        = string
  default     = "moonblade"
}

variable "nesting" {
  description = "Allow nesting (for Docker inside LXC)"
  type        = bool
  default     = false
}
