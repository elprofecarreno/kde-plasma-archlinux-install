#!/bin/bash

BLUE='\e[38;2;59;130;246m'
CYAN='\e[38;2;0;220;255m'
MAGENTA='\e[38;2;220;90;255m'
RED='\e[38;2;255;0;0m'
YELLOW='\e[38;2;255;215;0m'
GREEN='\e[38;2;0;200;83m'
RESET='\e[0m'


check_root()
{

    if [ "$EUID" -ne 0 ]; then

        echo -e "${RED}[FAIL] Ejecuta este script como root${RESET}"
        echo -e "${YELLOW}Uso:${RESET} sudo $0"

        exit 1

    fi

}



detect_bootloader()
{

echo -e "\n${CYAN}==> Detectando gestor de arranque...${RESET}"


if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="UEFI"
else
    BOOT_MODE="BIOS"
fi


if command -v grub-install &>/dev/null; then

    BOOTLOADER="GRUB"

elif [ -d /boot/loader ]; then

    BOOTLOADER="systemd-boot"

elif [ -f /boot/limine.conf ]; then

    BOOTLOADER="Limine"

else

    BOOTLOADER="Desconocido"

fi


echo -e "${GREEN}[ OK ]${RESET} $BOOTLOADER ($BOOT_MODE)"

}



install_group()
{

local name="$1"

shift


echo -e "\n${CYAN}==> Instalando ${name}...${RESET}"


pacman -S --noconfirm --needed "$@" >/dev/null 2>&1



local failed=()



for pkg in "$@"
do

    if ! pacman -Qi "$pkg" &>/dev/null; then

        failed+=("$pkg")

    fi

done



if [ ${#failed[@]} -eq 0 ]; then

    echo -e "${GREEN}[  OK  ]${RESET} ${name}"

else

    echo -e "${RED}[FAIL ]${RESET} ${name}"

    echo -e "${RED}Paquetes faltantes:${RESET}"

    printf " - %s\n" "${failed[@]}"

fi


}



detect_gpu()
{

echo -e "\n${CYAN}==> Detectando GPU...${RESET}"


GPU_INFO=$(lspci | grep -Ei "VGA|3D|Display")


echo "$GPU_INFO"

echo



if echo "$GPU_INFO" | grep -qi nvidia && \
   echo "$GPU_INFO" | grep -qi intel; then


    RECOMMENDED="NVIDIA"
    HYBRID=true


elif echo "$GPU_INFO" | grep -qi nvidia; then


    RECOMMENDED="NVIDIA"
    HYBRID=false


elif echo "$GPU_INFO" | grep -qi amd; then


    RECOMMENDED="AMD"
    HYBRID=false


elif echo "$GPU_INFO" | grep -qi intel; then


    RECOMMENDED="Intel"
    HYBRID=false


else


    RECOMMENDED="Vulkan genérico"
    HYBRID=false


fi


echo -e "${GREEN}[ OK ] Driver recomendado: ${RECOMMENDED}${RESET}"


if [ "$HYBRID" = true ]; then

echo -e "${YELLOW}[INFO] Sistema híbrido Intel + NVIDIA detectado${RESET}"

fi


}
