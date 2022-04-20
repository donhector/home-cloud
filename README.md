# HOME CLOUD

Repo for my home cloud IaC

## Libvirt

## Packer

In the end I opted for provisioning the disk using the ansible installation on the host machine (ie: provisioner `ansible` and not `ansible-local`). See `packer/ubuntu2204` folder.

Just for reference, I've also tryed using `ansible-local` provisioner instead (see `packer/ubuntu2204_` folder). I got it working but was not satified with the end results for two reasons:

- Despite uninstalling ansible from the VM once the provisioning was complete, the final disk image was about 1Gb larger that when just using the `ansible` provisioner.
- Currently the provisioner lacks support for ansible-galaxy `requirements.yml` that include both, collections and roles. It assumes you only have either roles or collections. So you end up adding workarounds and your packer template ends up being ugly. 

## Terraform

## Ansible
