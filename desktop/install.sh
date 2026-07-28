#!/bin/bash

echo "Habilitar multilib repository"
# Habilitar multilib
sed -i '/^\#\[multilib\]/,/^#Include/s/^#//' /etc/pacman.conf

echo "Actualizar repositorios"
# Actualizar repositorios
pacman -Sy

echo "Instalación de paquetes kde-plasma base"
# Paquetes base
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
pipewire \
pipewire-pulse \
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
plasma-wayland-session \
xorg-xwayland \
xdg-desktop-portal \
xdg-desktop-portal-kde \
mesa \
libglvnd \
obs-studio \
vlc \
qt6-multimedia-gstreamer \
gstreamer \
gst-plugins-base \
gst-plugins-good \
gst-plugins-bad \
gst-plugins-ugly \
gst-libav \
keepassxc \
bluez \
bluez-utils

echo "Enable NetworkManager Services"
systemctl enable NetworkManager
echo "Enable sddm Services"
systemctl enable sddm
echo "Enable sshd Services"
systemctl enable sshd
echo "Enable ufw Services"
systemctl enable ufw
systemctl start ufw
ufw enable
echo "Enable bluetooth Services"
systemctl enable bluetooth
echo "Enable pipewire Services"
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber
echo "Enable system-timesyncd Services"
systemctl enable systemd-timesyncd

echo "Instalación Teams -> Flathub"
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
echo "Instalación Chrome -> Flathub"
flatpak install -y flathub com.google.Chrome
echo "Instalación Discord -> Flathub"
flatpak install -y flathub com.discordapp.Discord
echo "Instalación Teams -> OnlyOffice"
flatpak install -y flathub org.onlyoffice.desktopeditors

PS3="Selecciona driver GPU: "

select DRIVER in \
    "Vulkan genérico" \
    "NVIDIA propietario" \
    "AMD Mesa" \
    "Intel Mesa" \
    "Sin driver"
do
    case $REPLY in
        1)
            pacman -S --noconfirm \
                vulkan-icd-loader \
                vulkan-tools
            break
            ;;

        2)
            pacman -S --noconfirm \
                linux-headers \
                nvidia \
                nvidia-utils \
                nvidia-settings \
                lib32-nvidia-utils \
                vulkan-icd-loader \
                vulkan-tools
            break
            ;;

        3)
            pacman -S --noconfirm \
                mesa \
                vulkan-radeon \
                lib32-vulkan-radeon \
                vulkan-tools
            break
            ;;

        4)
            pacman -S --noconfirm \
                mesa \
                vulkan-intel \
                lib32-vulkan-intel \
                vulkan-tools
            break
            ;;

        5)
            break
            ;;

        *)
            echo "Opción inválida"
            ;;
    esac
done

