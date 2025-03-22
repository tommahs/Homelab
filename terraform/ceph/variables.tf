# variables.tf
variable "ssh_key" {
  description = "SSH key to add to the arch user"
  type        = string
  default     = SSH_PUB_KEY_HERE
}

variable "vm_image_path" {
  description = "Path to the base image for the VM"
  type        = string
  default     = /path/to/cloudinit/os-image.qcow2"
}

