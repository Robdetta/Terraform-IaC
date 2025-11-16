# variables.tf

variable "proxmox_endpoint" {
  description = "The URL of the Proxmox API (e.g., https://192.168.1.10:8006/api2/json)"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox API user (e.g., root@pam)"
  type        = string
  sensitive   = true
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}
