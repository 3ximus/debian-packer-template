#!/bin/bash
set -eux

DEBIAN_FRONTEND=noninteractive sudo NEEDRESTART_MODE=a apt install -qq -y \
    xfce4 lightdm

# set dark theme
# xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark
