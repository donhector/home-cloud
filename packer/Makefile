SHELL := /usr/bin/env bash

#####################
## PACKER SECTION  ##
#####################
.PHONY: ubuntu2204
ubuntu2204-build:
	@cd ubuntu2204 && \
		packer init . && \
		packer build -force . 2>&1 | \
		tee packer.log

.PHONY: ubuntu2204-debug
ubuntu2204-debug:
	@cd ubuntu2204 && \
		packer init . && \
		PACKER_LOG=1 packer build -on-error=ask -force . 2>&1 | \
		tee packer.log

.PHONY: ubuntu2204-lint
ubuntu2204-lint:
	@cd ubuntu2204 && \
		packer init . && \
		packer validate . && \
		packer fmt .

.PHONY: clean
ubuntu2204-clean:
	@rm -rfv ubuntu2204/output


ubuntu2204-libvirt-up:
	@qemu-img info ubuntu2204-*.qcow2
	@qemu-img create -f qcow2 -b ubuntu2204-*.qcow2 ubuntu2204.qcow2 20G
	@virt-install --name=ubuntu2204-packer \
		--os-type Linux \
		--os-variant generic \
		--machine q35 \
		--vcpus 1 \
		--ram 1024 \
		--disk ubuntu2204.qcow2,bus=virtio,format=qcow2 \
		--import \
		--network network=default \
		--graphics spice \
		--noautoconsole

ubuntu2204-libvirt-down:
	@virsh shutdown ubuntu2204-packer

ubuntu2204-libvirt-delete:
	@virsh undefine ubuntu2204-packer --remove-all-storage
