#!/bin/bash -e

DOWNLOAD_URL='https://raw.githubusercontent.com/kotoyants/public/main/linux'


[ $1 = 'start' ] || { echo "Usage: $0 start"; exit 1; }


echo ' • Config files'
wget -qcP ~/ ${DOWNLOAD_URL}/.bashrc
wget -qcP ~/ ${DOWNLOAD_URL}/.dmrc

echo ' • Hide computer icon and rename home icon'
gsettings set org.mate.caja.desktop computer-icon-visible false
gsettings set org.mate.caja.desktop home-icon-name 'Home'

echo ' • Configure panels'

mkdir -p ~/.config/mate/panel2.d/default/launchers 
cat << EOF > ~/.config/mate/panel2.d/default/launchers/terminator.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name[en_GB]=Terminator
Exec=terminator --geometry 1600x900+150+100
Icon=terminator
Icon[en_GB]=terminator
Name=Terminator
EOF

dconf write /org/mate/panel/objects/menu-bar/tooltip "'Compact Menu'"
dconf write /org/mate/panel/objects/menu-bar/object-type "'menu'"
dconf write /org/mate/panel/objects/menu-bar/has-arrow false
dconf write /org/mate/panel/objects/menu-bar/position 10
dconf write /org/mate/panel/objects/menu-bar/locked true

dconf write /org/mate/panel/objects/window-list/toplevel-id "'top'"
dconf write /org/mate/panel/objects/window-list/position 200

#dconf write /org/mate/panel/objects/icon-terminator/launcher-location "'/usr/share/applications/terminator.desktop'"
dconf write /org/mate/panel/objects/icon-terminator/launcher-location "'terminator.desktop'"
dconf write /org/mate/panel/objects/icon-terminator/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-terminator/position 40
dconf write /org/mate/panel/objects/icon-terminator/locked true
dconf write /org/mate/panel/objects/icon-terminator/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-chromium/launcher-location "'/usr/share/applications/chromium.desktop'"
dconf write /org/mate/panel/objects/icon-chromium/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-chromium/position 66
dconf write /org/mate/panel/objects/icon-chromium/locked true
dconf write /org/mate/panel/objects/icon-chromium/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-chrome/launcher-location "'/usr/share/applications/google-chrome.desktop'"
dconf write /org/mate/panel/objects/icon-chrome/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-chrome/position 92
dconf write /org/mate/panel/objects/icon-chrome/locked true
dconf write /org/mate/panel/objects/icon-chrome/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-pluma/launcher-location "'/usr/share/applications/pluma.desktop'"
dconf write /org/mate/panel/objects/icon-pluma/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-pluma/position 118
dconf write /org/mate/panel/objects/icon-pluma/locked true
dconf write /org/mate/panel/objects/icon-pluma/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-viber/launcher-location "'/usr/share/applications/viber.desktop'"
dconf write /org/mate/panel/objects/icon-viber/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-viber/position 144
dconf write /org/mate/panel/objects/icon-viber/locked true
dconf write /org/mate/panel/objects/icon-viber/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-telegram/launcher-location "'/usr/share/applications/telegramdesktop.desktop'"
dconf write /org/mate/panel/objects/icon-telegram/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-telegram/position 170
dconf write /org/mate/panel/objects/icon-telegram/locked true
dconf write /org/mate/panel/objects/icon-telegram/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-slack/launcher-location "'/usr/share/applications/slack.desktop'"
dconf write /org/mate/panel/objects/icon-slack/object-type "'launcher'"
dconf write /org/mate/panel/objects/icon-slack/position 196
dconf write /org/mate/panel/objects/icon-slack/locked true
dconf write /org/mate/panel/objects/icon-slack/toplevel-id "'top'"

dconf write /org/mate/panel/objects/icon-lock/action-type "'lock'"
dconf write /org/mate/panel/objects/icon-lock/object-type "'action'"
dconf write /org/mate/panel/objects/icon-lock/position 24
dconf write /org/mate/panel/objects/icon-lock/locked true
dconf write /org/mate/panel/objects/icon-lock/panel-right-stick true
dconf write /org/mate/panel/objects/icon-lock/toplevel-id "'top'"

dconf write /org/mate/panel/general/object-id-list "['menu-bar', 'notification-area', 'clock', 'show-desktop', 'window-list', 'workspace-switcher', 'icon-terminator', 'icon-chromium', 'icon-chrome', 'icon-pluma', 'icon-viber', 'icon-telegram', 'icon-slack', 'icon-lock']"

dconf reset -f "/org/mate/panel/objects/workspace-switcher/"
dconf reset -f "/org/mate/panel/objects/show-desktop/"
dconf reset -f "/org/mate/panel/toplevels/bottom/"
#!!! second panel not deleted

pkill -HUP mate-panel

echo ' • Setup wallpaper'
mkdir -p ~/.local/share/background
wget -qcP ~/.local/share/background ${DOWNLOAD_URL}/bg-tile.png
convert -size 1920x1200 tile:/home/${USER}/.local/share/background/bg-tile.png ~/.local/share/background/bg-hd.png
dconf write /org/mate/desktop/background/picture-filename "'/home/${USER}/.local/share/background/bg-tile.png'"
dconf write /org/mate/desktop/background/picture-options "'wallpaper'"

echo ' • Enable Faenza icon theme'
dconf write /org/mate/desktop/interface/icon-theme "'Faenza'"

echo ' • Configure dektop fonts'
dconf write /org/mate/desktop/interface/font-name "'Ubuntu 11'"
dconf write /org/mate/desktop/interface/document-font-name "'Ubuntu 11'"
dconf write /org/mate/caja/desktop/font "'Ubuntu 11'"
dconf write /org/mate/marco/general/titlebar-font "'Ubuntu Bold 12'"
dconf write /org/mate/desktop/interface/monospace-font-name "'Ubuntu Mono 13'"

echo ' • Configure keyboard layouts'
mkdir -p ~/.icons/flags
wget -qcP ~/.icons/flags ${DOWNLOAD_URL}/ru.png
wget -qcP ~/.icons/flags ${DOWNLOAD_URL}/us.png
dconf write /org/mate/desktop/peripherals/keyboard/indicator/show-flags true
dconf write /org/mate/desktop/peripherals/keyboard/kbd/layouts "['us', 'ru']"
dconf write  /org/mate/desktop/peripherals/keyboard/kbd/options "['grp\tgrp:win_space_toggle']"

echo ' • Disable open media on automount'
dconf write /org/mate/desktop/media-handling/automount-open false

echo ' • Configure keybindings'
dconf write /org/mate/marco/global-keybindings/show-desktop "'<Mod4>d'"
dconf write /org/mate/marco/keybinding-commands/command-screenshot "'bash -c \"flameshot gui -r | xclip -selection clipboard -t image/png && pkill flameshot\"'"

echo ' • Create link for media folder'
[ ! -f ~/Media -a ! -d ~/Media -o -L ~/Media ] && ln -sf /var/run/media/${USER} ~/Media || { echo '~/Media file exist and is not a link'; exit 1; }
mkdir -p ~/Desktop/Screens

echo ' • Configure external editor for mc'
sed -i 's/use_internal_edit=true/use_internal_edit=false/' ~/.config/mc/ini
sed -i 's/safe_delete=false/safe_delete=true/' ~/.config/mc/ini
sed -i 's/show_backups=true/show_backups=false/' ~/.config/mc/ini
sed -i 's/show_dot_files=true/how_dot_files=false/' ~/.config/mc/ini
sed -i 's/message_visible=true/message_visible=false/' ~/.config/mc/ini
sed -i 's/keybar_visible=true/keybar_visible=false/' ~/.config/mc/ini
sed -i 's/menubar_visible=true/menubar_visible=false/' ~/.config/mc/ini

echo ' • Configure Conky'
wget -qcP ~/ ${DOWNLOAD_URL}/.conkyrc
mkdir -p ~/.config/autostart
cp /usr/share/applications/conky.desktop ~/.config/autostart/

echo ' • Configure clock'
dconf write /org/mate/panel/objects/clock/prefs/show-seconds true
dconf write /org/mate/panel/objects/clock/prefs/cities "['<location name=\"\" city=\"Odesa\" timezone=\"Europe/Kiev\" latitude=\"46.433334\" longitude=\"30.766666\" code=\"UKOO\" current=\"false\"/>', '<location name=\"\" city=\"New York\" timezone=\"America/New_York\" latitude=\"40.783333\" longitude=\"-73.966667\" code=\"KNYC\" current=\"false\"/>', '<location name=\"\" city=\"Tbilisi\" timezone=\"Asia/Tbilisi\" latitude=\"41.669167\" longitude=\"44.954723\" code=\"TBS\" current=\"true\"/>']"

echo ' • Configure default apps'
dconf write /org/mate/desktop/applications/terminal/exec "'terminator'"

echo ' • Configure mplayer'
mkdir -p ~/.mplayer
cat << EOF > ~/.mplayer/config
progbar-align=100
fs=yes
ontop=yes
EOF
