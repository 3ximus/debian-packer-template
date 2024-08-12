SHELL=bash
.SHELLFLAGS=-euo pipefail -c

VERSION=12.6.0

debian-${VERSION}-amd64-libvirt.box: clean preseed.cfg debian.pkr.hcl Vagrantfile.template \
				provision/00-custom.sh \
				provision/01-desktop.sh \
				provision/97-guest-additions.sh \
				provision/98-vagrant.sh \
				provision/99-cleanup.sh
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
	rm -rf debian-${VERSION}-amd64-libvirt.box* ./output-debian-amd64 ./packer_cache
