#!/bin/bash
set -exu

# make sure we cannot directly login as root.
usermod --lock root

# let the sudo group members use root permissions without a password.
#   d-i automatically adds vagrant into the sudo group.
sed -i -E 's,^%sudo\s+.+,%sudo ALL=(ALL) NOPASSWD:ALL,g' /etc/sudoers

# change default Vagrant user name
sed -i 's/Vagrant Default User/Vagrant/' /etc/passwd

# install the wget dependency.
DEBIAN_FRONTEND=noninteractive apt-get install -y wget network-manager

# install the vagrant public key.
#    vagrant will replace it on the first run.
install -d -m 700 /home/vagrant/.ssh
pushd /home/vagrant/.ssh
wget -qOauthorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 600 authorized_keys
chown -R vagrant:vagrant .
popd

# disable the DNS reverse lookup on the SSH server. this stops it from
# trying to resolve the client IP address into a DNS domain name, which
# is kinda slow and does not normally work when running inside VB.
echo UseDNS no >>/etc/ssh/sshd_config
