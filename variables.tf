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

variable "db_url" {
  description = "The Spring Boot datasource URL for the local PostgreSQL container."
  type        = string
  default     = "jdbc:postgresql://postgres:5432/brewtrail_db" # Use the container name 'postgres'
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "brewtrail_user"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secret key for JWT generation."
  type        = string
  sensitive   = true
}

#replace with local frontend for development

# variable "frontend_url" {
#   description = "URL for the Caddy reverse proxy to point to (e.g., https://brewtrail.robbiehem.dev)."
#   type        = string
#   default     = "https://brewtrail.robbiehem.dev"
# }