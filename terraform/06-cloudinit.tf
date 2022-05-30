locals {
  # We create an enriched node object that appends the libvirt network details inside the specific nic object
  # By using  try + coalesce, we can provide default values to arguments that are optional  
  nodes_with_network_lookup = {
    for k, v in var.nodes : k => {
      os                   = v.os
      nics                 = { for i, j in v.nics : i => merge(var.networks[j.libvirt_network], v.nics[i]) }
      username             = coalesce(try(v.user_data.username, null), var.default_user_data.username)
      password             = coalesce(try(v.user_data.password, null), var.default_user_data.password)
      groups               = coalesce(try(v.user_data.groups, null), var.default_user_data.groups)
      ssh_authorized_keys  = coalesce(try(v.user_data.ssh_authorized_keys, null), var.default_user_data.ssh_authorized_keys)
      extra_disks_to_mount = [for d in coalesce(v.extra_disks, []) : d if v.extra_disks != null && d.mount != null]
      domain               = one([for n in libvirt_network.networking : n.domain if n.domain != null])
    }
  }
}

# Create N number of ISOs with our rendered cloudinit configs baked in
# We will attach an iso to a VM during its creation
resource "libvirt_cloudinit_disk" "cloudinit_iso" {

  for_each = local.nodes_with_network_lookup

  name = "cloudinit-${each.key}.iso"
  pool = libvirt_pool.storage.name

  meta_data = templatefile("${path.module}/templates/${each.value.os}/meta-data.tftpl", {})
  network_config = templatefile("${path.module}/templates/${each.value.os}/network-config.tftpl", {
    nics    = each.value.nics
    counter = index(keys(local.nodes_with_network_lookup), each.key) + 1
  })
  user_data = templatefile("${path.module}/templates/${each.value.os}/user-data.tftpl", {
    hostname             = "${var.cluster_prefix}${each.key}"
    username             = each.value.username
    password             = each.value.password
    groups               = each.value.groups
    ssh_authorized_keys  = each.value.ssh_authorized_keys
    extra_disks_to_mount = each.value.extra_disks_to_mount
    domain               = each.value.domain
  })
}
