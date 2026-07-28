#!/bin/sh
pacman -S --noconfirm unzip \
p7zip \
unrar \
unzip \
nano \
sddm \
networkmanager \
discover \
pipewire \
ttf-jetbrains-mono-nerd \
dolphin \
ark \
wireplumber \
flatpak \
git \
wget \
curl \
rsync \
openssh \
ufw \
plasma-systemmonitor \
gparted \
plasma \
plasma \
obs-studio \
vlc \
qt6-multimedia-gstreamer \
gstreamer \
gst-plugins-base \
gst-plugins-good \
gst-plugins-bad \
gst-plugins-ugly \
gst-libav \
keepassxc

sed -i 's/\#\[multilib\]/\[multilib\]' /etc/pacman.conf

#linux-headers
#nvidia

flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
flatpak install -y flathub com.google.Chrome

flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub org.onlyoffice.desktopeditors

