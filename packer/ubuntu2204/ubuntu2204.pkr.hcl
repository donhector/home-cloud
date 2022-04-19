source "qemu" "ubuntu-2204-cloudimg" {

  iso_checksum = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  iso_urls = [
    "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  ]

  vm_name          = "ubuntu2204-${local.timestamp}.${var.format}"
  http_directory   = "http"
  output_directory = "dist"

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

}

build {

  sources = ["source.qemu.ubuntu-2204-cloudimg"]

  # Runs on the VM being built.
  # 2204 ships with a modern enough version of ansible
  # that knows how to handle requirements.yml with both roles and collections
  # provisioner "shell" {
  #   inline = [
  #     "sleep 10",
  #     "sudo apt update",
  #     "sudo apt install -y ansible"
  #   ]
  #   max_retries = 5
  # }

  # Runs on the VM being built
  provisioner "ansible-local" {
    playbook_dir            = "ansible"
    command                 = "ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook"
    playbook_file           = "ansible/main.yml"
    extra_arguments         = ["-vvv"]
    galaxy_command          = "ansible-galaxy"
    galaxy_file             = "ansible/requirements.yml"
    clean_staging_directory = true
  }

  # Runs on the VM being built
  # provisioner "shell" {
  #   inline            = ["sudo systemctl reboot"]
  #   expect_disconnect = true
  # }

  # Runs on the Packer host
  post-processor "shell-local" {
    inline = ["echo Build ${source.type}.${source.name} finished!"]
  }

}
