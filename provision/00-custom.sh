#!/bin/bash
set -eux

DEBIAN_FRONTEND=noninteractive sudo NEEDRESTART_MODE=a apt install -qq -y --no-install-recommends --no-install-suggests \
    neovim lf tmux git make gawk fzf xclip ripgrep bat

sudo update-alternatives --set vim /usr/bin/nvim

# install bottom
curl -sOL https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb --output-dir /tmp
sudo dpkg -i /tmp/bottom_0.9.6_amd64.deb
rm /tmp/bottom_0.9.6_amd64.deb
