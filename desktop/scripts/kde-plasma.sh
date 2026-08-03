#!/bin/bash

BLUE='\e[38;2;59;130;246m'
CYAN='\e[38;2;0;220;255m'
MAGENTA='\e[38;2;220;90;255m'
RED='\e[38;2;255;0;0m'
YELLOW='\e[38;2;255;215;0m'
GREEN='\e[38;2;0;200;83m'
RESET='\e[0m'

check_status() {
    local name="$1"
    local status="$2"

    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}[  OK  ]${RESET} ${name}"
    else
        echo -e "${RED}[FAIL ]${RESET} ${name}"
    fi
}


check_root() {

    echo -e "\n${CYAN}==> Verificando ejecución como root...${RESET}"

    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[FAIL ]${RESET} Ejecución como root requerida"
        echo -e "${YELLOW}Ejecuta:${RESET} sudo $0"
        exit 1
    fi

    check_status "Ejecución como root" 0
}

enable_multilib() {

    echo -e "\n${CYAN}==> Configurando repositorios Arch...${RESET}"

    if grep -q '^\[multilib\]$' /etc/pacman.conf && \
       grep -q '^Include = /etc/pacman.d/mirrorlist$' /etc/pacman.conf; then

        check_status "Repositorio multilib habilitado" 0

    else

        sed -i '/^#\[multilib\]/,/^#Include/s/^#//' /etc/pacman.conf

        if grep -q '^\[multilib\]$' /etc/pacman.conf && \
           grep -q '^Include = /etc/pacman.d/mirrorlist$' /etc/pacman.conf; then

            check_status "Repositorio multilib habilitado" 0

        else

            check_status "Repositorio multilib habilitado" 1
            return 1

        fi
    fi
}

install_group() {
    local name="$1"
    shift

    echo -e "${CYAN}==> Instalando ${name}...${RESET}"

    pacman -S --noconfirm --needed "$@" >/dev/null 2>&1

    local failed=()

    for pkg in "$@"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            failed+=("$pkg")
        fi
    done

    if [ ${#failed[@]} -eq 0 ]; then
        echo -e "${GREEN}[  OK  ]${RESET} ${name}"
    else
        echo -e "${RED}[ERROR]${RESET} ${name}"
        echo -e "${RED}        No instalados:${RESET}"
        printf "          - %s\n" "${failed[@]}"
    fi

    echo
}


echo -e "\n\n${MAGENTA}Verificando ejecución como root...${RESET}"

check_root
enable_multilib

echo -e "\n${YELLOW}Actualizando repositorios...${RESET}"
# Actualizar repositorios
pacman -Sy

install_group "Compresión" \
    zip \
    unzip \
    p7zip \
    unrar \
    gzip \
    bzip2 \
    xz \
    zstd \
    lz4 \
    lzip \
    ark


install_group "Sistema KDE" \
    plasma-desktop \
    plasma-nm \
    plasma-pa \
    sddm \
    sddm-kcm \
    discover \
    dolphin \
    konsole \
    kwrite \
    kwallet \
    kwalletmanager


install_group "Multimedia" \
    ffmpeg \
    ffmpegthumbs \
    qt6-multimedia-gstreamer \
    vlc \
    vlc-plugin-ffmpeg \
    gst-libav \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    pipewire \
    pipewire-pulse \
    pipewire-jack \
    pipewire-alsa \
    wireplumber \
    lib32-pipewire \
    pavucontrol \
    firefox \
    obs-studio


install_group "Conectividad" \
    networkmanager \
    network-manager-applet \
    openssh \
    bluez \
    bluedevil \
    bluez-utils


install_group "Seguridad" \
    ufw \
    gnupg \
    keepassxc


install_group "Herramientas del Sistema" \
    nano \
    flatpak \
    gparted \
    flameshot \
    fastfetch \
    btop \
    htop \
    tree \
    ncdu \
    tmux


install_group "Diagnóstico" \
    lsof \
    strace \
    iotop \
    iftop


install_group "Red y Diagnóstico Avanzado" \
    nmap \
    tcpdump \
    netcat \
    mtr \
    traceroute \
    bind \
    whois \
    iperf3


install_group "Fuentes" \
    ttf-jetbrains-mono-nerd \
    ttf-jetbrains-mono \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    ttf-liberation \
    ttf-carlito \
    ttf-fira-code \
    ttf-ibm-plex

install_group "Fuentes Compatibilidad Windows" \
    ttf-liberation \
    ttf-carlito \
    ttf-caladea


install_group "Fuentes Estilo macOS" \
    ttf-liberation \
    ttf-carlito \
    noto-fonts \
    noto-fonts-emoji \
    ttf-dejavu \
    ttf-roboto \
    ttf-ibm-plex \
    ttf-fira-code
