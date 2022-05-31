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

```shell
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
terraform refresh
```

To destroy the infrastructure:

```shell
cd terraform
terraform destroy --auto-approve
```

## Ansible

The inventory hosts that will be controlled from Ansible are "natted" VMs running inside the Libvirt host (`xeon.lan`),
therefore they cannot be accessed directly from outside the Libvirt host. This will be a problem since my
Ansible controller machine is not the Libvirt host itself but a WSL instance running on my laptop.

So we need a way to make the inventory hosts accessible to our control machine. There are several ways to
accomplish this in ssh (including creating a tunnel), but in my case I opted for using Method 2 described [here](https://www.jeffgeerling.com/blog/2022/using-ansible-playbook-ssh-bastion-jump-host)

In my laptop I've created a `~/.ssh/config` file with:

```yml
Host xeon
  User hector
  Hostname xeon.lan

Host k8s-*
  User kube
  ProxyJump xeon
```

The flow will the be:

`Laptop ----ssh--> Libvirt host ----ssh--> inventory host`

To verify all works as expected, from my controller machine I could

```shell
hector@wsl$ cd ansible
hector@wsl$ make ping
```

And the result should be:

``` yaml
ansible -i inventory/k8s-cluster/inventory.ini all -m ping
k8s-node2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
k8s-node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
k8s-master2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
k8s-master1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
k8s-master3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
k8s-node3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
