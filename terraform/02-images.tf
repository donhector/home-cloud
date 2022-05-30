### Download OS images into the remote libvirt server 

locals {
  os_image_urls = [for url in var.download_os_images : url]
}

resource "null_resource" "get_os_images" {

  triggers = {
    urls = join(" ", local.os_image_urls)
  }

  connection {
    type        = "ssh"
    host        = var.libvirt_connection.host
    user        = var.libvirt_connection.user
    private_key = file(pathexpand(var.ssh_private_key))
  }

  # Start downloading on the remote libvirt host. Downloads will be parallelized via xargs
  provisioner "remote-exec" {
    inline = [
      "echo ${join(" ", local.os_image_urls)} | xargs -n 1 -P 8 wget --continue -N --directory-prefix ${pathexpand("${trimsuffix(var.download_destination, "/")}")}"
    ]
  }
}
