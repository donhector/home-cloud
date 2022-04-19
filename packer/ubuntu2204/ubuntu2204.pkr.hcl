source "qemu" "ubuntu-2204-cloudimg" {

  iso_checksum = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  iso_urls = [
    "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  ]

  vm_name          = "ubuntu2204-${local.timestamp}.${var.format}"
  http_directory   = "http"
  output_directory = "output"

  cpus             = var.cpus
  memory           = var.memory
  disk_size        = var.disk_size
  format           = var.format
  disk_image       = true
  disk_compression = true
  disk_interface   = "virtio"
  net_device       = "virtio-net"

  vnc_port_min = 6000
  vnc_port_max = 6000

  ssh_handshake_attempts = 500
  ssh_pty                = true
  ssh_timeout            = "30m"
  ssh_username           = "ubuntu"
  ssh_private_key_file   = var.ssh_private_key_file

  headless    = true
  accelerator = var.accelerator
  qemuargs    = [["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/"]]
  boot_wait   = "1s"

}

build {

  sources = ["source.qemu.ubuntu-2204-cloudimg"]

  # Runs on the Packer host. Requires ansible to be already there.
  provisioner "ansible" {
    galaxy_file     = "ansible/requirements.yml"
    playbook_file   = "ansible/main.yml"
    extra_arguments = ["-vvv"]
    ansible_env_vars = [
      "ANSIBLE_FORCE_COLOR=1",
      "PYTHONUNBUFFERED=1",
      "ANSIBLE_HOST_KEY_CHECKING=False"
    ]
  }

  # Runs on the VM being built
  # Clean cloud-init run so we can further cloud-init the generated disk image
  provisioner "shell" {
    inline = [ "sudo cloud-init clean" ]
  }

  # Runs on the Packer host
  post-processor "shell-local" {
    inline = ["echo Build ${source.type}.${source.name} finished!"]
  }

}
