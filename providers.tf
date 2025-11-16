terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.86.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  api_token = "${var.proxmox_username}!terraform=${var.proxmox_password}"
  insecure = true
}
