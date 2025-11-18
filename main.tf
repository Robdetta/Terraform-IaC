# --- 2. THE VM RESOURCE BLOCK ---
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  # Create 2 VMs instead of 3
  count = 2
  description = "Managed by Terraform for Docker (VM Test)"

  clone {
    vm_id = 9000
  }

  node_name = "proxmox1"
  # Calculate vm_id: 601 + index (0, 1) = 601, 602
  vm_id     = 601 + count.index
  
  # Dynamic naming convention
  name = "ubuntu-vm-${601 + count.index}"
  tags = ["docker-test", "ansible-target"]

  # Enable QEMU Guest Agent for proper shutdown and management
  agent {
    enabled = true
  }
  stop_on_destroy = true

  startup {
    order    = "3"
    up_delay = "60"
    down_delay = "60"
  }

  cpu {
    cores  = 2
    type   = "host" # Use 'host' for best performance unless compatibility is needed
  }

  memory {
    dedicated = 2048 # 2GB RAM
    floating  = 2048 
  }

  # Inside the resource "proxmox_virtual_environment_vm" "ubuntu_vm" block...
  disk {
    datastore_id = "local-lvm"
    # IMPORTANT: Reference the new download resource name here
    interface    = "scsi0"
    size         = 16
  }

  # --- Network Interface ---
  network_device {
    bridge  = "vmbr0" # **CRITICAL:** Use your management bridge
    vlan_id = 20
    model   = "virtio" # Recommended model for performance
  }

  # --- Initialization (Cloud-Init) ---
  initialization {
    # DHCP from your network is typically the easiest setup
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      # Use the user 'robadmin' and inject the SSH key and password
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = "robadmin" # This sets up the default user for Ansible access
    }
  }

  # Operating system type is only required if not using a cloud image template
  operating_system {
    type = "l26" # Linux 2.6+ kernel
  }

  # Include serial device for console access
  serial_device {}
}

# --- 3. PASSWORD AND KEY MANAGEMENT ---
resource "random_password" "ubuntu_vm_password" {
  length          = 16
  override_special = "_%@"
  special         = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# --- 4. OUTPUTS ---
output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}