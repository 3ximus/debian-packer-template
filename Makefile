SHELL=bash
.SHELLFLAGS=-euo pipefail -c

VERSION=10.5.0

debian-${VERSION}-amd64.box: clean preseed.cfg provision/guest-additions.sh provision/final.sh provision/custom.sh debian.pkr.hcl Vagrantfile.template
	rm -f $@
	CHECKPOINT_DISABLE=1 \
	PACKER_LOG=1 \
	PACKER_LOG_PATH=$@.init.log \
		packer init debian.pkr.hcl
	mkdir ./packer_cache
	TMPDIR=${PWD}/packer_cache \
	PACKER_KEY_INTERVAL=10ms \
	CHECKPOINT_DISABLE=1 \
	PACKER_LOG=1 PACKER_LOG_PATH=$@.log \
	PKR_VAR_version=${VERSION} \
	PKR_VAR_vagrant_box=$@ \
		packer build -only=qemu.debian-amd64 -on-error=abort -timestamp-ui debian.pkr.hcl
	rmdir packer_cache

clean:
	rm -rf ./output-debian-amd64 ./packer_cache

.PHONY: help buid-libvirt
