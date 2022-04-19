SHELL := /usr/bin/env bash

.PHONY: ubuntu2204
ubuntu2204:
	@cd packer/ubuntu2204 && \
		packer init . && \
		packer build -force . 2>&1 | \
		tee packer.log

.PHONY: ubuntu2204-debug
ubuntu2204-debug:
	@cd packer/ubuntu2204 && \
		packer init . && \
		PACKER_LOG=1 packer build -on-error=ask -force . 2>&1 | \
		tee packer.log

.PHONY: ubuntu2204-lint
ubuntu2204-lint:
	@cd packer/ubuntu2204 && \
		packer init . && \
		packer validate . && \
		packer fmt .

.PHONY: clean
ubuntu2204-clean:
	@rm -rfv packer/ubuntu2204/output ~/.cache/packer/
