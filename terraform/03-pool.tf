### Create a libvirt pool for storing custom disk images and cloud-init isos
resource "libvirt_pool" "storage" {
  name = "${var.cluster_prefix}${var.pool_name}"
  type = "dir"
  path = "${pathexpand("${trimsuffix(var.pool_location, "/")}")}/${var.cluster_prefix}${var.pool_name}"
}
