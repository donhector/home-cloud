### Create Libvirt networks
resource "libvirt_network" "networking" {

  for_each = var.networks

  name      = "${var.cluster_prefix}${each.key}"
  mode      = each.value.mode
  bridge    = each.value.bridge
  addresses = each.value.addresses
  domain    = each.value.mode == "bridge" ? null : each.value.domain
  autostart = true

  dynamic "dns" {

    for_each = each.value.dns == null ? [] : [each.value.dns]

    content {
      enabled    = dns.value.enabled
      local_only = dns.value.local_only

      # This controls the dns host entries in libvirt's internal dns server for this network
      dynamic "hosts" {

        # We will be creating dns entries for any hosts in the 'extra_hosts' list (regardless of DHCP being used or not)
        # We will also be creating dns entries for any nodes that are not using DCHP in their nic (ie: they use static ip)  
        # To do so we build an uber list (via concat) containing all the dns entries to be created and iterate over it  
        # NOTE: if a node is not using dhcp for its nic, but no ip was explicitly provided, 
        #       then we assign an autocalculated ip based on network address range, network offset and node number

        for_each = concat(
          [for extra_host in coalesce(var.networks[each.key].dns.extra_hosts, []) : extra_host],
          flatten([
            for node_key, node_value in var.nodes : [
              for nic_key, nic_value in node_value.nics : {
                ip       = try(nic_value.ips[0], cidrhost(each.value.addresses[0], each.value.offset + index(keys(var.nodes), node_key) + 1))
                hostname = "${var.cluster_prefix}${node_key}"
            } if nic_value.libvirt_network == each.key && nic_value.dhcp == false]
          ])
        )

        content {
          ip       = hosts.value.ip
          hostname = hosts.value.hostname
        }

      }
    }
  }

  dynamic "dhcp" {

    for_each = each.value.dhcp == null ? [] : [each.value.dhcp]

    content {
      enabled = each.value.dhcp.enabled
    }
  }

  # Requires 'xsltproc' (debian) or 'libxslt' (redhat) package to be installed on the libvirt host
  dynamic "xml" {

    for_each = each.value.dhcp == null ? [] : [each.value.dhcp]

    content {
      xslt = templatefile("${path.module}/templates/network.xslt", {
        dhcp_range_start = each.value.dhcp.range_start
        dhcp_range_end   = each.value.dhcp.range_end
      })
    }
  }

}
