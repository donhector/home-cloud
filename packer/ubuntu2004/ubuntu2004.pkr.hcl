source "qemu" "ubuntu-2004-cloudimg" {

  iso_checksum = "file:https://cloud-images.ubuntu.com/releases/focal/release/SHA256SUMS"
  iso_urls = [
    "http://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  ]

  vm_name          = "ubuntu2004-${local.timestamp}.${var.format}"
  http_directory   = "http"
  output_directory = "dist"

  memory           = var.memory
  disk_size        = var.disk_size
  format           = var.format
  disk_image       = true
  disk_compression = true
  disk_interface   = "virtio"
  net_device       = "virtio-net"

  vnc_port_min = 6000
  vnc_port_max = 6000

  ssh_handshake_attempts    = 500
  ssh_pty                   = true
  ssh_timeout               = "30m"
  ssh_username              = "ubuntu"
  ssh_password              = var.ssh_password
  ssh_clear_authorized_keys = true


  headless    = true
  accelerator = var.accelerator
  qemuargs    = [["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/"]]

  shutdown_command = "echo '${var.ssh_password}' | sudo -S poweroff"

}

build {

  sources = ["source.qemu.ubuntu-2004-cloudimg"]

  # workaround for dealing with requirements that include roles and collections
  # See https://github.com/hashicorp/packer-plugin-ansible/issues/32

  provisioner "file" {
    source      = "ansible/requirements.yml"
    destination = "/tmp/"
  }

  # Runs on the VM being built. Ensure latest ansible
  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install -y ansible",
      "ansible-galaxy role install -r /tmp/requirements.yml",
      "ansible-galaxy collection install -r /tmp/requirements.yml"
    ]
  }

  # Runs on the VM being built
  provisioner "ansible-local" {
    playbook_dir    = "ansible"
    command         = "ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook"
    playbook_file   = "ansible/main.yml"
    extra_arguments = ["-vvv"]
    # galaxy_command          = "ansible-galaxy"
    # galaxy_file             = "ansible/requirements.yml"
    clean_staging_directory = true
  }

  # Runs on the VM being built
  provisioner "shell" {
    inline            = ["sudo systemctl reboot"]
    expect_disconnect = true
  }

  # Runs on the Packer host
  post-processor "shell-local" {
    inline = ["echo Build ${source.type}.${source.name} finished!"]
  }

}
