terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Base image for the VM
resource "libvirt_volume" "base_arch_qcow2" {
  name   = "base-arch.qcow2"
  pool   = "homelab_ceph"
  source = var.vm_image_path  # Path to the base image
  format = "qcow2"
}
# Defining node disks
resource "libvirt_volume" "ceph_disk" {
  count  = 3
  name   = "ceph${count.index + 1}.qcow2"
  pool   = "homelab_ceph"
  source = libvirt_volume.base_arch_qcow2.id
  format = "qcow2"
  size   = 41943040
}

# Define second disk for each VM (50GB nonformatted disk)
resource "libvirt_volume" "ceph_data_disk" {
  count  = 3
  name   = "ceph${count.index + 1}-data.qcow2"
  pool   = "homelab_ceph"
  format = "qcow2"
  size   = 52428800  # 50GB in KB
}

# Define second disk for each VM (50GB nonformatted disk)
resource "libvirt_volume" "ceph_data_disk" {
  count  = 3
  name   = "ceph${count.index + 1}-data.qcow2"
  pool   = "homelab_ceph"
  format = "qcow2"
  size   = 52428800  # 50GB in KB
}

# Define the node using the new 50GB disk
resource "libvirt_domain" "ceph_node" {
  count    = 3
  name     = "ceph${count.index + 1}"
  memory   = 4096
  vcpu     = 2

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.ceph_disk[count.index].id
  }
  
  disk {
    volume_id = libvirt_volume.ceph_data_disk[count.index].id
  }
  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  cloudinit = libvirt_cloudinit_disk.ceph_cloudinit[count.index].id
}

# Declare the disksize variable
variable "disksize" {
  description = "The size of the disk for each VM in KB"
  type        = number
  default     = 41943040  # Default size for the disk
}

resource "libvirt_cloudinit_disk" "ceph_cloudinit" {
  count     = 3
  name      = "cloudinit-ceph${count.index + 1}"
  pool      = "homelab_k8s"

  user_data = <<EOF
#cloud-config
hostname: ceph${count.index + 1}
manage_etc_hosts: true
users:
  - default
  - name: arch
    ssh-authorized-keys:
      - ${var.ssh_key}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: false
    passwd: "FunTimes2025!"
    shell: /bin/bash

runcmd:
  - sudo pacman -S ssh --noconfirm
  - sudo systemctl enable --now sshd
  - sudo chmod 700 /home/arch/.ssh
  - sudo chmod 600 /home/arch/.ssh/authorized_keys
  - sudo chown -R arch:arch /home/arch/.ssh
  - sudo pacman -S git htop btop 
  - git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
  - yay -Syy

EOF

  network_config = <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF
}
