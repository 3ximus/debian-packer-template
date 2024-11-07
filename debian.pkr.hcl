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

variable "hcp_client_id" {
  type    = string
  default = "${env("HCP_CLIENT_ID")}"
}

variable "hcp_client_secret" {
  type    = string
  default = "${env("HCP_CLIENT_SECRET")}"
}

source "qemu" "debian-amd64" {
  accelerator       = "kvm"
  machine_type      = "q35"
  qemu_binary       = "qemu-system-x86_64"
  # efi_boot          = true
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
  iso_url           = "https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-${var.version}-amd64-netinst.iso"
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
  # efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  # efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"
}

build {
  sources = [ "source.qemu.debian-amd64", ]

  provisioner "shell" {
    expect_disconnect = true
    execute_command   = "echo vagrant | sudo -S {{ .Vars }} bash {{ .Path }}"
    scripts = [
      "provision/00-custom.sh",
      "provision/01-desktop.sh",
      "provision/97-guest-additions.sh",
      "provision/98-vagrant.sh",
      "provision/99-cleanup.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      only                 = [ "qemu.debian-amd64", ]
      output               = var.vagrant_box
      vagrantfile_template = "Vagrantfile.template"
    }

    post-processor "vagrant-registry" {
      box_tag             = "3ximus/debian-xfce"
      version             = "${var.version}"
      client_id           = "${var.hcp_client_id}"
      client_secret       = "${var.hcp_client_secret}"
      architecture        = "amd64"
      version_description = "Light weight debian ${var.version} + xfce4 box https://github.com/3ximus/debian-packer-template"
    }
  }
}
