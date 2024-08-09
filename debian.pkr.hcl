packer {
  required_plugins {
    qemu = {
      version = "1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "version" {
  type = string
}

variable "vagrant_box" {
  type = string
}

source "qemu" "debian-amd64" {
  accelerator       = "kvm"
  machine_type      = "q35"
  qemu_binary       = "qemu-system-x86_64"
  qemuargs          = [["-bios", "OVMF.fd"]]
  cpus              = 2
  memory            = 2 * 1024
  headless          = true
  net_device        = "virtio-net"
  format            = "qcow2"
  disk_size         = 10 * 1024
  disk_interface    = "virtio-scsi"
  disk_cache        = "writeback"
  disk_discard      = "ignore"
  disk_compression  = true
  iso_url           = "https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
  iso_checksum      = "file:https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/SHA512SUMS"
  http_directory    = "."
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "60m"
  boot_wait         = "3s"
  boot_command      = [
    "c<wait>",
    "linux /install.amd/vmlinuz",
    " auto=true",
    " priority=critical",
    " hostname=vagrant",
    " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " vga=788 noprompt quiet --<enter>",
    " interface=auto",
    " BOOT_DEBUG=2",
    " DEBCONF_DEBUG=5",
    "<enter><wait>",
    "initrd /install.amd/initrd.gz",
    "<enter><wait>",
    "boot",
    "<enter><wait>",
  ]
  shutdown_command  = "echo vagrant | sudo -E -S poweroff"
}

build {
  sources = [ "source.qemu.debian-amd64", ]

  provisioner "shell" {
    expect_disconnect = true
    execute_command   = "echo vagrant | sudo -S {{ .Vars }} bash {{ .Path }}"
    scripts = [
      # "provision/00-custom.sh",
      "provision/98-vagrant.sh",
      "provision/99-cleanup.sh"
    ]
  }

  post-processor "vagrant" {
    only = [ "qemu.debian-amd64", ]
    output               = var.vagrant_box
    vagrantfile_template = "Vagrantfile.template"
  }
}
