
resource "libvirt_domain" "domains" {

  for_each = var.nodes

  name       = "${var.cluster_prefix}${each.key}"
  vcpu       = each.value.cpu
  memory     = each.value.memory
  running    = true
  autostart  = false
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.cloudinit_iso[each.key].id

  # NOTE: If q35 chipset is required for your experiments (ie: UEFI secure boot)
  # see https://github.com/dmacvicar/terraform-provider-libvirt/issues/667 to
  # workaround cloudinit ISO mounting IDE not supported issue

  disk {
    volume_id = libvirt_volume.os_disk[each.key].id
  }

  dynamic "disk" {
    for_each = { for k, v in coalesce(each.value.extra_disks, []) : format("%s.extra.%s", each.key, k) => v }
    content {
      volume_id = libvirt_volume.extra_disks[disk.key].id
    }
  }

  dynamic "network_interface" {
    for_each = { for k, v in each.value.nics : k => v }
    content {
      network_id     = libvirt_network.networking[network_interface.value.libvirt_network].id
      mac            = try(network_interface.value.mac, null)
      wait_for_lease = true
    }
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  timeouts {
    create = "3m"
  }

}
