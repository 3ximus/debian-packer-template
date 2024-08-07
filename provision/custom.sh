#!/bin/bash
set -eux

export DEBIAN_FRONTEND="noninteractive"

# use bash shell
sudo chsh vagrant -s /bin/bash

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

# ====================================================================================================
# MAIN
sudo NEEDRESTART_MODE=a apt install -qq --no-install-recommends -y \
    gnome-core

# install bottom
curl -sOL https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb --output-dir /tmp
sudo dpkg -i /tmp/bottom_0.9.6_amd64.deb
rm /tmp/bottom_0.9.6_amd64.deb
