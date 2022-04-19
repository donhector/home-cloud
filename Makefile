SHELL := /usr/bin/env bash

.PHONY: ubuntu2004
ubuntu2004:
	@cd packer/ubuntu2004 && \
		packer init . && \
		packer build -force .

.PHONY: ubuntu2004-debug
ubuntu2004-debug:
	@cd packer/ubuntu2004 && \
		packer init . && \
		PACKER_LOG=1 packer build -on-error=ask -force .

.PHONY: ubuntu2004-lint
ubuntu2004-lint:
	@cd packer/ubuntu2004 && \
		packer init . && \
		packer validate . && \
		packer fmt .

.PHONY: clean
ubuntu2004-clean:
	@rm -rfv packer/ubuntu2004/dist
