# To get a specific output var, run `terraform output <varname>`
# In case not all data got populated, try with `terraform refresh`

output "pool_name" {
  value       = libvirt_pool.storage.name
  description = "Name of the libvirt pool that was created"
}

output "pool_path" {
  value       = libvirt_pool.storage.path
  description = "Name of the libvirt pool that was created"
}

output "networks" {
  value       = [for n in libvirt_network.networking : n.name]
  description = "Name of the libvirt networks that were created"
}

output "instances" {
  value       = { for k, v in libvirt_domain.domains : v.name => { ip = v.network_interface.*.addresses.0, mac = v.network_interface.*.mac } }
  description = "Nodes with their IPv4 IPs and MACs"
}
