packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-qemu
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
  efi_boot          = true
  cpus              = 4
  memory            = 4 * 1024
  qemuargs          = [["-cpu", "host"]]
  headless          = false
  net_device        = "virtio-net"
  format            = "qcow2"
  disk_size         = 20 * 1024
  disk_interface    = "virtio-scsi"
  disk_cache        = "unsafe"
  disk_discard      = "unmap"
  disk_compression  = true
  iso_url           = "https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
  iso_checksum      = "file:https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/SHA512SUMS"
  http_directory    = "."
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "60m"
  boot_wait         = "5s"
  boot_command      = [
    "c<wait>",
    "linux /install.amd/vmlinuz",
    " auto=true",
    " priority=critical",
    " hostname=vagrant",
    " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " BOOT_DEBUG=2",
    " DEBCONF_DEBUG=5",
    "<enter><wait>",
    "initrd /install.amd/initrd.gz",
    "<enter><wait>",
    "boot",
    "<enter><wait>",
  ]
  shutdown_command  = "echo vagrant | sudo -S poweroff"
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"
}

build {
  sources = [ "source.qemu.debian-amd64", ]

  provisioner "shell" {
    expect_disconnect = true
    execute_command   = "echo vagrant | sudo -S {{ .Vars }} bash {{ .Path }}"
    scripts = [
      # "provision/guest-additions.sh",
      "provision/custom.sh",
      "provision/final.sh"
    ]
  }

  post-processor "vagrant" {
    only = [ "qemu.debian-amd64", ]
    output               = var.vagrant_box
    vagrantfile_template = "Vagrantfile.template"
  }
}
