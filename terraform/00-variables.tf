### Libvirt host connection details
variable "libvirt_connection" {
  description = "Libvirt host URI connection details"
  type = object({
    user = string
    host = string
  })
}

variable "ssh_private_key" {
  description = "Private key that will be used for remote-exec provisioner to SSH into the Libvirt host"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

### Cluster variables
variable "cluster_prefix" {
  description = "Prefix that will be used to name resources"
  type        = string
  default     = "dev-"
}

### OS image downloading variables
variable "download_os_images" {
  description = "Map of OS images that will be downloaded and their aliases"
  type        = map(string)
  default = {
    "ubuntu2004" = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
    "ubuntu2204" = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    "debian11"   = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
    "fedora35"   = "https://download.fedoraproject.org/pub/fedora/linux/releases/35/Cloud/x86_64/images/Fedora-Cloud-Base-35-1.2.x86_64.qcow2"
    "fedora36"   = "https://download.fedoraproject.org/pub/fedora/linux/releases/36/Cloud/x86_64/images/Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
  }
}

# The idea is to download "gold" images into a common location (ie: default pool)
# and not into the pool that we will be creating. This allows destroying the created pool
# without destroying the downloaded images, so they could be used for other projects.
variable "download_destination" {
  description = "Folder where OS images files will be downloaded"
  type        = string
  default     = "/var/lib/libvirt/images/default"
}

### Storage pool variables
variable "pool_name" {
  description = "Libvirt storage pool name. This will be used to store the node disk(s) including cloudinit ISOs"
  type        = string
  default     = "storage"
}

variable "pool_location" {
  description = "Location where the new storage pool will be created"
  type        = string
  default     = "~/libvirt/pools"
}

### Libvirt networks 
variable "networks" {
  description = "Libvirt network(s) that will be created"
  type = map(object({
    mode      = string
    bridge    = optional(string)
    domain    = optional(string)
    addresses = optional(list(string))
    offset    = optional(number)
    dhcp = optional(object({
      enabled     = optional(bool)
      range_start = optional(string)
      range_end   = optional(string)
    }))
    dns = optional(object({
      enabled    = optional(bool)
      local_only = optional(bool)
      extra_hosts = optional(list(object({
        hostname = string
        ip       = string
      })))
    }))
  }))

  default = {
    "cluster" = {
      mode      = "nat"
      domain    = "home.lab"
      addresses = ["10.10.0.0/24"]
      offset    = 100
      dhcp = {
        enabled     = true
        range_start = "10.10.0.2"
        range_end   = "10.10.0.254"
      }
      dns = {
        enabled    = true
        local_only = true
      }
    }
  }
}

### Libvirt domains
variable "nodes" {
  description = "Domains to create and their characteristics"
  type = map(object({
    cpu    = number
    memory = number
    disk   = number
    extra_disks = optional(list(object({
      size  = number
      mount = optional(string) # If no mount is provided, disk will not be formatted
    })))
    os = string
    nics = optional(map(object({
      dhcp            = bool
      mac             = optional(string)
      ips             = optional(list(string))
      libvirt_network = string
    })))
    user_data = optional(object({
      username            = optional(string)
      password            = optional(string)
      groups              = optional(string)
      ssh_authorized_keys = optional(list(string))
    }))
    ansible_playbook = optional(string)
  }))
}


variable "default_user_data" {
  description = "Defaults for user-data variables"
  type = object({
    username            = string
    password            = string
    groups              = string
    ssh_authorized_keys = list(string)
  })
  default = {
    username            = "kube"
    password            = "$6$kg4B/C45o7wpuagy$EChLgozGUgT/oQMMsUmKe8rmmuYI7RD0Kz/8T8erso5/.aE3XSABVRS3nhDqzzTiJS/2H/jJ8P2zy5/3WxhYm."
    groups              = "users,sudo,adm"
    ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYOzTJoN5TImhjMTw9gYzYJiDIK5NHMAbJ8OXxvDX2W donhector"]
  }
}
