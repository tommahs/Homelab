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
  pool   = "homelab_k8s"
  source = var.vm_image_path  # Path to the base image
  format = "qcow2"
}

# Defining master nodes
resource "libvirt_volume" "master_disk" {
  count  = 3
  name   = "master-k8s-${count.index + 1}.qcow2"
  pool   = "homelab_k8s"
  source = libvirt_volume.base_arch_qcow2.id
  format = "qcow2"
  size   = 41943040
}
# Define the master node using the new 50GB disk
resource "libvirt_domain" "master_node" {
  count    = 3
  name     = "master-k8s-${count.index + 1}"
  memory   = 4096
  vcpu     = 2

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.master_disk[count.index].id
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

  cloudinit = libvirt_cloudinit_disk.master_cloudinit[count.index].id
}

# Declare the disksize variable
variable "disksize" {
  description = "The size of the disk for each VM in GB"
  type        = number
  default     = 45097156608  # Default size for the disk
}

resource "libvirt_cloudinit_disk" "master_cloudinit" {
  count     = 3
  name      = "master-k8s-cloudinit-${count.index + 1}"
  pool      = "homelab_k8s"

  user_data = <<EOF
#cloud-config
hostname: master-k8s-${count.index + 1}
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
  - sudo swapoff -a
  - sudo sed -i '/swap/s/^/#/' /etc/fstab
  - sudo pacman-key --init 
  - sudo pacman-key --populate archlinux
  - sudo pacman -Syy --noconfirm
  - sudo pacman -S ssh --noconfirm
  - sudo systemctl enable --now sshd
  - sudo chmod 700 /home/arch/.ssh
  - sudo chmod 600 /home/arch/.ssh/authorized_keys
  - sudo chown -R arch:arch /home/arch/.ssh
  - sudo pacman -S plocate vim nfs-utils --noconfirm
  - sudo pacman -R iptables iproute2 base dhclient cloud-init  --noconfirm
  - sudo pacman -S kubeadm kubelet kubectl docker helm base dhclient cloud-init nfs-utils --noconfirm
  - sudo modprobe br_netfilter
  - sudo sysctl -p /etc/sysctl.d/50-kubelet.conf
  - sudo systemctl enable --now docker kubelet
  - helm repo add stable https://charts.helm.sh/stable
EOF

  network_config = <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF
}
#########################
# Define 6 Worker Nodes
#########################

resource "libvirt_volume" "worker_disk" {
  count  = 6
  name   = "worker-k8s-${count.index + 1}.qcow2"
  pool   = "homelab_k8s"
  source = libvirt_volume.base_arch_qcow2.id
  format = "qcow2"
  size   = 41943040
}

resource "libvirt_domain" "worker_node" {
  count  = 6
  name   = "worker-k8s-${count.index + 1}"
  memory = 4096
  vcpu   = 2

  cpu {
    mode = "host-passthrough"
  }
  disk {
    volume_id = libvirt_volume.worker_disk[count.index].id
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

  cloudinit = libvirt_cloudinit_disk.worker_cloudinit[count.index].id
}

resource "libvirt_cloudinit_disk" "worker_cloudinit" {
  count     = 6
  name      = "worker-k8s-cloudinit-${count.index + 1}"
  pool      = "homelab_k8s"

  user_data = <<EOF
#cloud-config
hostname: worker-k8s-${count.index + 1}
manage_etc_hosts: true
users:
  - default
  - name: arch
    ssh-authorized-keys:
      - ${var.ssh_key}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    lock_passwd: false
    passwd: "FunTimes2025!"
    shell: /bin/bash

runcmd:
  - sudo swapoff -a
  - sudo sed -i '/swap/s/^/#/' /etc/fstab
  - sudo pacman-key --init
  - sudo pacman-key --populate archlinux
  - sudo pacman -Syy --noconfirm
  - sudo pacman -S ssh --noconfirm
  - sudo systemctl enable --now sshd
  - sudo chmod 700 /home/arch/.ssh
  - sudo chmod 600 /home/arch/.ssh/authorized_keys
  - sudo chown -R arch:arch /home/arch/.ssh
  - sudo pacman -S plocate vim nfs-utils --noconfirm 
  - sudo pacman -S kubeadm kubelet kubectl docker helm base dhclient cloud-init nfs-utils --noconfirm
  - sudo modprobe br_netfilter
  - sudo sysctl -p /etc/sysctl.d/50-kubelet.conf
  - sudo systemctl enable --now docker kubelet
EOF

  network_config = <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF
}

######################################
# Define Worker Nodes With Extra RAM
######################################

resource "libvirt_volume" "worker_RAM_disk" {
  count  = 1
  name   = "worker-k8s-RAM${count.index + 1}.qcow2"
  pool   = "homelab_k8s"
  source = libvirt_volume.base_arch_qcow2.id
  format = "qcow2"
  size   = 41943040
}

resource "libvirt_domain" "worker_node_RAM" {
  count  = 1
  name   = "worker-k8s-RAM${count.index + 1}"
  memory = 24576
  vcpu   = 4

  cpu {
    mode = "host-passthrough"
  }
  disk {
    volume_id = libvirt_volume.worker_RAM_disk[count.index].id
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

  cloudinit = libvirt_cloudinit_disk.worker_RAM_cloudinit_[count.index].id
}

resource "libvirt_cloudinit_disk" "worker_RAM_cloudinit_" {
  count     = 1
  name      = "worker-k8s-cloudinit-RAM${count.index + 1}"
  pool      = "homelab_k8s"

  user_data = <<EOF
#cloud-config
hostname: worker-k8s-ram${count.index + 1}
manage_etc_hosts: true
users:
  - default
  - name: arch
    ssh-authorized-keys:
      - ${var.ssh_key}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    lock_passwd: false
    passwd: "FunTimes2025!"
    shell: /bin/bash

runcmd:
  - sudo swapoff -a
  - sudo sed -i '/swap/s/^/#/' /etc/fstab
  - sudo pacman-key --init
  - sudo pacman-key --populate archlinux
  - sudo pacman -Syy --noconfirm
  - sudo pacman -S ssh --noconfirm
  - sudo systemctl enable --now sshd
  - sudo chmod 700 /home/arch/.ssh
  - sudo chmod 600 /home/arch/.ssh/authorized_keys
  - sudo chown -R arch:arch /home/arch/.ssh
  - sudo pacman -S plocate vim nfs-utils --noconfirm 
  - sudo pacman -S kubeadm kubelet kubectl docker helm base dhclient cloud-init nfs-utils --noconfirm
  - sudo modprobe br_netfilter
  - sudo sysctl -p /etc/sysctl.d/50-kubelet.conf
  - sudo systemctl enable --now docker kubelet
EOF

  network_config = <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
EOF
}