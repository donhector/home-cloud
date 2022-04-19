locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "cpus" {
  type        = number
  default     = 2
  description = "CPUs to allocate to the building VM"
}

variable "memory" {
  type        = number
  default     = 1024
  description = "Memory in mb to allocate to the building VM"
}

variable "disk_size" {
  type        = string
  default     = "8G"
  description = "Disk size in mb to allocate to the resulting build"
}

variable "ssh_private_key_file" {
  sensitive   = true
  type        = string
  default     = "~/.ssh/id_ed25519"
  description = "SSH private key to use for connecting to the build"
}

variable "format" {
  type        = string
  default     = "qcow2"
  description = "Disk image format. Qemu supports 'qcow2' or 'raw'"
}

variable "accelerator" {
  type        = string
  default     = "kvm"
  description = "Host acceleration type to use. Use 'tcg' for Github hosted runners"
}
