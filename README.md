# HOME CLOUD

Repo for my home cloud IaC lab

## Libvirt

Libvirt is used as the backing hypervisor. Libvirt acts here as your "cloud provider" (ie. your own AWS, GCP or Azure). Then using Terraform's Libivirt provider you can manage resources in a similar way you'd do for public clouds.    

## Packer

The Packer folder contains some blueprints to generate Packer images. This is more for toying around with Packer as I'm not actually using the built Packer images as the OS image for my libvirt VMs, but you never know when they might come in handy (ie need for a custom VirtualBox / VMWare / Vagrant formatted ISO).

The Packer blueprints use official CloudImages as the starting point, which are then lightly configured via CloudInit and then finally provisioned using Ansible.

The `packer/ubuntu2204` folder uses the `ansible provisioner` method, which bascially means that your host machine is the Ansible control machine and the VM is the controlled host. This is my preferred method.

The `packer/ubuntu2204_` folder uses the `ansible-local provisioner` method. While I got it working, I was not satified with the end results for two reasons:

- Despite uninstalling ansible from the VM once the provisioning was complete, the final disk image was about 1Gb larger that when just using the `ansible` provisioner.

- Currently the provisioner lacks support for ansible-galaxy `requirements.yml` that include both, collections and roles. It assumes you only have either roles or collections. So you end up adding workarounds and your packer template ends up being ugly. 

## Terraform

The `terraform` folder contains the IaC files to spin up VMs (and their networks) using Libvirt.

I've made the Terraform files quite flexible so all the important settings are exposed via configuration.

These include being able to adjust VM's:

- OS (ubuntu2004, ubuntu2204, debian11, fedora35, fedora36)
- vCPU
- Memory
- Number of disks, their size and mount point (if any). If a mount is provided, the disk will be partitioned and then formatted using ext4 (most stable format in storage solutions such as Longhorn / Mayastor)
- Number of nics, their addressing, and host libvirt network they connect to
- CloudInit user-data

Please refer to `config.auto.tfvars.example*` files for reference.

### Usage

```
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
terraform refresh
```

To destroy the infrastructure:

```
cd terraform
terraform destroy --auto-approve
```

## Ansible
