#!/bin/bash

# Verificar ejecución como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse como root."
    echo "Ejecuta: sudo $0"
    exit 1
fi

echo "Ejecutando como root..."

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
qt6-multimedia-gstreamer \
networkmanager \
discover \
pipewire \
pipewire-pulse \
pipewire-jack \
pipewire-alsa \
wireplumber \
lib32-pipewire \
pavucontrol
plasma-desktop \
plasma-nm \
plasma-pa \
ttf-jetbrains-mono-nerd \
dolphin \
ark \
flatpak \
git \
wget \
curl \
rsync \
openssh \
ufw \
gparted \
obs-studio \
vlc \
keepassxc \
konsole \
bluez \
bluez-utils \
kwallet \
kwalletmanager \
kwrite \
docker \
docker-compose \
flameshot \
gnupg


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
echo "Enable docker Services"
sudo systemctl enable docker.service
echo "Enable PipeWire Services (System-wide templates)"
# Habilitar los sockets a nivel de usuario global para nuevos usuarios
systemctl --global enable pipewire.socket
systemctl --global enable pipewire-pulse.socket
systemctl --global enable wireplumber.service
echo "Enable system-timesyncd Services"
systemctl enable systemd-timesyncd

echo "Instalación Teams -> Flathub"
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
echo "Instalación Chrome -> Flathub"
flatpak install -y flathub com.google.Chrome
echo "Instalación Discord -> Flathub"
flatpak install -y flathub com.discordapp.Discord
echo "Instalación OnlyOffice -> Flathub"
flatpak install -y flathub org.onlyoffice.desktopeditors
echo "Instalación Brave -> Flathub"
flatpak install -y flathub com.brave.Browser
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
                mesa \
                libglvnd \
                vulkan-icd-loader \
                vulkan-tools
            break
            ;;

        2)
            pacman -S --noconfirm \
                linux-headers \
                nvidia-dkms \
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

reboot