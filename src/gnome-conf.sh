#!/usr/bin/bash

# Copyright 2020 Sébastien Millet

set -euo pipefail

# ############################################################################
# Background

gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background primary-color '#004956'

# ############################################################################
# Create key bindings
#   Ctrl-Alt-T: open terminal (alacritty) with tmux inside
#   Ctrl-Alt-U: same as above, but attaching to an existing session

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'alacritty -e tmux'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Ctrl><Alt>T'

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Terminal (attached)'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'alacritty -e tmux attach'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Ctrl><Alt>U'

# ############################################################################
# Don't group applications with Alt-Tab

dconf write /org/gnome/desktop/wm/keybindings/switch-applications \
    "['<Super>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward \
    "['<Shift><Super>Tab']"

dconf write /org/gnome/desktop/wm/keybindings/switch-windows \
    "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward \
    "['<Shift><Alt>Tab']"

# ############################################################################
# French keyboard

gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr+oss')]"

# ############################################################################
# Mouse left-handed

gsettings set org.gnome.desktop.peripherals.mouse left-handed 'true'

# ############################################################################
# Session settings

gsettings set org.gnome.desktop.screensaver lock-enabled 'false'
gsettings set org.gnome.desktop.session 'idle-delay' 600
gsettings set org.gnome.desktop.notifications show-in-lock-screen 'false'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

mkdir -p ~/tmp
cat > ~/tmp/ignore-lid-switch-tweak.desktop << EOF
[Desktop Entry]
Type=Application
Name=ignore-lid-switch-tweak
Exec=/usr/lib/gnome-tweak-tool-lid-inhibitor
EOF
mkdir -p ~/.config/autostart
mv ~/tmp/ignore-lid-switch-tweak.desktop ~/.config/autostart/

# ############################################################################
# Update alacritty configuration at session start
# Reason: i3 and gnome manage display differently and the font size of alacritty
#         must be different between gnome and i3
#         To avoid file writes back and forth, the solution consists in linking
#         alacritty config file to a pre-defined configuration file.

cat > ~/tmp/gnome-autostart << EOF
#!/usr/bin/bash

ln -sf ~/.alacritty.yml.gnome ~/.config/alacritty/alacritty.yml
EOF
chmod +x ~/tmp/gnome-autostart
echo "sudo mv ~/tmp/gnome-autostart /usr/local/bin/gnome-autostart"
sudo mv ~/tmp/gnome-autostart /usr/local/bin/gnome-autostart

