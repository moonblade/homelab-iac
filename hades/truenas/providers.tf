# TrueNAS SCALE Terraform Provider
# Requires TrueNAS SCALE 25.10.1+ (uses WebSocket JSON-RPC API)

terraform {
  required_version = ">= 1.0"

  required_providers {
    truenas = {
      source  = "bmanojlovic/truenas"
      version = "~> 0.0.34"
    }
  }
}

provider "truenas" {
  host  = var.truenas_host
  token = var.truenas_api_token
}
