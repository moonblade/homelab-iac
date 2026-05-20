# TrueNAS Configuration Variables

variable "truenas_host" {
  description = "TrueNAS host IP or hostname"
  type        = string
  default     = "192.168.1.10"
}

variable "truenas_api_token" {
  description = "TrueNAS API token (generate from UI: Settings -> API Keys)"
  type        = string
  sensitive   = true
}
