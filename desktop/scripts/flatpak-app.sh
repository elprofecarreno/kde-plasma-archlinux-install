#!/bin/bash

BLUE='\e[38;2;59;130;246m'
CYAN='\e[38;2;0;220;255m'
MAGENTA='\e[38;2;220;90;255m'
RED='\e[38;2;255;0;0m'
YELLOW='\e[38;2;255;215;0m'
GREEN='\e[38;2;0;200;83m'
RESET='\e[0m'


check_flatpak() {

    local name="$1"
    local app="$2"

    echo -e "${CYAN}==> Instalando ${name}...${RESET}"

    flatpak install -y flathub "$app" >/dev/null 2>&1


    if flatpak info "$app" &>/dev/null; then
        echo -e "${GREEN}[  OK  ]${RESET} ${name}"
    else
        echo -e "${RED}[FAIL ]${RESET} ${name}"
    fi

    echo
}


echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${MAGENTA}        Instalación de aplicaciones Flatpak          ${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"


# Verificar Flatpak instalado
if ! command -v flatpak &>/dev/null; then
    echo -e "${RED}[FAIL ] Flatpak no está instalado${RESET}"
    exit 1
else
    echo -e "${GREEN}[  OK  ] Flatpak disponible${RESET}"
fi


# Agregar Flathub si no existe
if ! flatpak remotes | grep -q flathub; then
    echo -e "${YELLOW}==> Agregando repositorio Flathub...${RESET}"

    flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo

    if flatpak remotes | grep -q flathub; then
        echo -e "${GREEN}[  OK  ] Repositorio Flathub agregado${RESET}"
    else
        echo -e "${RED}[FAIL ] No se pudo agregar Flathub${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}[  OK  ] Repositorio Flathub disponible${RESET}"
fi


echo


check_flatpak "Teams" \
    com.github.IsmaelMartinez.teams_for_linux

check_flatpak "Google Chrome" \
    com.google.Chrome

check_flatpak "Discord" \
    com.discordapp.Discord

check_flatpak "OnlyOffice" \
    org.onlyoffice.desktopeditors

check_flatpak "Brave Browser" \
    com.brave.Browser


echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${GREEN}Proceso Flatpak finalizado${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"