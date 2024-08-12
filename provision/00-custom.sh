#!/bin/bash
set -eux

DEBIAN_FRONTEND=noninteractive sudo NEEDRESTART_MODE=a apt install -qq -y --no-install-recommends --no-install-suggests \
    vim-gtk3 lf tmux

# install bottom
curl -sOL https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb --output-dir /tmp
sudo dpkg -i /tmp/bottom_0.9.6_amd64.deb
rm /tmp/bottom_0.9.6_amd64.deb
