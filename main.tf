resource "proxmox_virtual_environment_container" "ubuntu_container" {
  count = 3
  description = "Managed by Terraform"

  node_name = "proxmox1"
# Calculate vm_id: 501 + index (0, 1, 2) = 501, 502, 503
  vm_id       = 601 + count.index

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "ubuntu-${501 + count.index}"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name = "veth0"
    bridge  = "vmbr0"  # **CRITICAL:** Use the bridge connected to your physical NIC
    vlan_id =  20
  
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }


  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    #template_file_id = "local-lvm:base-127"
    type             = "ubuntu"
  }




  mount_point {
    # volume mount, a new volume will be created by PVE
    volume = "local-lvm"
    size   = "10G"
    path   = "/mnt/volume"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
  
}


resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}

# # 1. Network: caddy_network
# resource "docker_network" "caddy_network" {
#   name = "caddy_network"
# }

# # 2. Volumes: Used for Caddy configuration and data persistence
# resource "docker_volume" "caddy_data" {
#   name = "caddy_data"
# }

# resource "docker_volume" "caddy_config" {
#   name = "caddy_config"
# }

# # 3. Volume: Placeholder for PostgreSQL Data (Required if using a local DB)
# resource "docker_volume" "postgres_data" {
#   name = "postgres_data"
# }


  # mount_point {
  #   # bind mount, *requires* root@pam authentication
  #   volume = "/mnt/bindmounts/shared"
  #   path   = "/mnt/shared"
  # }


  # operating_system {
  #   template_file_id = proxmox_virtual_environment_download_file.ubuntu_2504_lxc_img.id
  #   # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
  #   # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
  #   type             = "ubuntu"
  # }
    # **CRITICAL FIX:** Directly reference the local template volume ID.
  # Assuming the stable Ubuntu 22.04 template is on 'local' storage.


# resource "proxmox_virtual_environment_download_file" "ubuntu_2504_lxc_img" {
#   content_type = "vztmpl"
#   datastore_id = "local"
#   node_name    = "proxmox1"
#   url          = "https://mirrors.servercentral.com/ubuntu-cloud-images/releases/25.04/release/ubuntu-25.04-server-cloudimg-amd64-root.tar.xz"
# }
