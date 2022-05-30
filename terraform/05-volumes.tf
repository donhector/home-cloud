# Volume(s) that will be attached to the vms. 
# if no size was is provided, it takes the one from the base image (if any)
# if size is provided and bigger than one from base image, then we'll grow it via cloud-init's growpart.
# See https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume#size

# NOTE: Since we want to be able to execute terraform against a remote libvirt server,
# we use "base_volume_name" instead of "base_volume_id". The latter would look for the base volume
# on the machine running terraform, and then would "push" the volume to the remote libvirt server.
# That would be highly inefficient. By using 'base_volume_name' we can leverage a volume that is 
# already present in the remote libvirt server (ie. one that we downloaded earlier with 'null_resource.get_images')

resource "libvirt_volume" "os_disk" {

  for_each = var.nodes

  base_volume_pool = "default"
  base_volume_name = basename(var.download_os_images["${each.value.os}"])

  name   = "${var.cluster_prefix}${each.key}.os"
  size   = each.value.disk
  format = "qcow2"
  pool   = libvirt_pool.storage.name

}

# See https://www.terraform.io/language/functions/flatten#flattening-nested-structures-for-for_each
# We use coalesce to deal with potential null values
locals {
  node_extra_disks = flatten([
    for node_name, node_info in var.nodes : [
      for extra_disk_index, extra_disk_value in coalesce(node_info.extra_disks, []) : {
        node_name  = node_name
        disk_index = extra_disk_index
        disk_size  = extra_disk_value.size
      }
    ]
  ])
}

resource "libvirt_volume" "extra_disks" {

  for_each = { for disk in local.node_extra_disks : format("%s.extra.%s", disk.node_name, disk.disk_index) => disk }

  name   = "${var.cluster_prefix}${each.key}"
  size   = each.value.disk_size
  format = "raw"
  pool   = libvirt_pool.storage.name

}
