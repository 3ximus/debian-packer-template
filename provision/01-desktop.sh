#!/bin/bash
set -eux

DEBIAN_FRONTEND=noninteractive sudo NEEDRESTART_MODE=a apt install -qq -y --no-install-suggests \
    lightdm xfce4 xfce4-terminal

# customize lightdm
cat <<EOF >>/etc/lightdm/lightdm-gtk-greeter.conf
theme-name=Adwaita-dark
hide-user-image=true
background=#1F3C6D
EOF

sed 's/#\?greeter-hide-users=.*/greeter-hide-users=false/' -i /etc/lightdm/lightdm.conf

# set user dirs
cat <<EOF >/etc/xdg/user-dirs.defaults
DESKTOP=desk
DOWNLOAD=downloads
TEMPLATES=
PUBLICSHARE=
DOCUMENTS=
MUSIC=
PICTURES=
VIDEOS=
EOF

# set terminal stuff
mkdir -p /etc/xdg/xfce4/terminal
cat <<EOF >/etc/xdg/xfce4/terminal/terminalrc
[Configuration]
RunCustomCommand=TRUE
MiscBordersDefault=TRUE
MiscMenubarDefault=FALSE
MiscRightClickAction=TERMINAL_RIGHT_CLICK_ACTION_CONTEXT_MENU
CustomCommand=/usr/bin/tmux
EOF

# set dark theme
sed -i '/ThemeName/ s/Xfce/Adwaita-dark/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
sed -i '/IconThemeName/ s/Tango/Adwaita/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# set no icons on desktop
cat <<EOF >/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVirtual-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="2"/>
          <property name="image-style" type="int" value="0"/>
          <property name="rgba1" type="array">
            <value type="double" value="0.10196078431372549"/>
            <value type="double" value="0.37254901960784315"/>
            <value type="double" value="0.70588235294117652"/>
            <value type="double" value="1"/>
          </property>
          <property name="rgba2" type="array">
            <value type="double" value="0.14117647058823529"/>
            <value type="double" value="0.12156862745098039"/>
            <value type="double" value="0.19215686274509805"/>
            <value type="double" value="1"/>
          </property>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="0"/>
  </property>
</channel>
EOF

# set only top panel
cat <<EOF >/etc/xdg/xfce4/panel/default.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="16"/>
      <property name="size" type="uint" value="26"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="8"/>
        <value type="int" value="11"/>
        <value type="int" value="12"/>
        <value type="int" value="13"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="org.xfce.panel.applicationsmenu"/>
      <property name="show-generic-names" type="bool" value="false"/>
      <property name="show-menu-icons" type="bool" value="true"/>
      <property name="show-button-title" type="bool" value="true"/>
      <property name="small" type="bool" value="false"/>
      <property name="button-title" type="string" value=" Applications"/>
      <property name="show-tooltips" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="uint" value="1"/>
      <property name="show-handle" type="bool" value="true"/>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="pager"/>
    <property name="plugin-5" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-6" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
      <property name="known-items" type="array">
        <value type="string" value="example-simple-client"/>
      </property>
    </property>
    <property name="plugin-8" type="string" value="pulseaudio">
      <property name="enable-keyboard-shortcuts" type="bool" value="true"/>
      <property name="show-notifications" type="bool" value="true"/>
    </property>
    <property name="plugin-11" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-12" type="string" value="clock"/>
    <property name="plugin-13" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
  </property>
</channel>
EOF
