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



detect_gpu()
{

echo -e "\n${CYAN}==> Detectando GPU...${RESET}"


GPU_INFO=$(lspci | grep -Ei "VGA|3D|Display")



if [ -z "$GPU_INFO" ]; then

    echo -e "${RED}[FAIL] No se detectó GPU${RESET}"

    RECOMMENDED="Vulkan genérico"
    HYBRID=false

    return

fi



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

install_common()
{

install_group "Componentes gráficos base" \
    mesa \
    libglvnd \
    vulkan-icd-loader \
    vulkan-tools \
    lib32-mesa

}



install_nvidia()
{


install_group "NVIDIA propietario" \
    linux-headers \
    nvidia-dkms \
    nvidia-utils \
    nvidia-settings \
    nvidia-prime \
    switcheroo-control \
    lib32-nvidia-utils \
    vulkan-icd-loader \
    vulkan-tools



echo -e "\n${CYAN}==> Regenerando initramfs...${RESET}"


mkinitcpio -P



if [ $? -eq 0 ]; then

    echo -e "${GREEN}[ OK ] Initramfs actualizado${RESET}"

else

    echo -e "${RED}[FAIL] Error regenerando initramfs${RESET}"

fi


}



install_amd()
{


install_group "AMD Mesa" \
    mesa \
    vulkan-radeon \
    lib32-vulkan-radeon \
    vulkan-tools


}



install_intel()
{


install_group "Intel Mesa" \
    mesa \
    vulkan-intel \
    lib32-vulkan-intel \
    vulkan-tools


}



configure_hybrid_gpu()
{


if [ "$HYBRID" = true ]; then


echo -e "\n${CYAN}==> Configurando GPU híbrida Intel + NVIDIA...${RESET}"



install_group "Soporte GPU híbrida" \
    switcheroo-control \
    nvidia-prime



systemctl enable --now switcheroo-control.service



if systemctl is-active --quiet switcheroo-control.service; then

    echo -e "${GREEN}[ OK ] switcheroo-control activo${RESET}"

else

    echo -e "${RED}[FAIL] switcheroo-control no pudo iniciar${RESET}"

fi



fi


}



configure_nvidia_kms()
{


echo -e "\n${CYAN}==> Configurando NVIDIA DRM KMS...${RESET}"



case $BOOTLOADER in



GRUB)


    if grep -q "nvidia_drm.modeset=1" /etc/default/grub; then


        echo -e "${GREEN}[ OK ] NVIDIA DRM KMS ya configurado${RESET}"


    else


        sed -i \
        's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' \
        /etc/default/grub



        grub-mkconfig -o /boot/grub/grub.cfg



        echo -e "${GREEN}[ OK ] NVIDIA DRM KMS agregado a GRUB${RESET}"


    fi


;;



systemd-boot)


    echo -e "${CYAN}==> Configurando systemd-boot...${RESET}"



    ENTRY=$(ls /boot/loader/entries/*.conf 2>/dev/null | head -1)



    if [ -z "$ENTRY" ]; then


        echo -e "${RED}[FAIL] No se encontró entrada systemd-boot${RESET}"

        return


    fi



    if grep -q "nvidia_drm.modeset=1" "$ENTRY"; then


        echo -e "${GREEN}[ OK ] NVIDIA DRM KMS ya configurado${RESET}"


    else


        sed -i \
        's/options /options nvidia_drm.modeset=1 /' \
        "$ENTRY"



        echo -e "${GREEN}[ OK ] NVIDIA DRM KMS agregado a systemd-boot${RESET}"


    fi


;;



Limine)


    echo -e "${YELLOW}[INFO] Limine detectado${RESET}"

    echo -e "${YELLOW}Agregar nvidia_drm.modeset=1 en la configuración de Limine${RESET}"


;;



*)


    echo -e "${RED}[FAIL] Bootloader desconocido${RESET}"


;;


esac


}



validate_vulkan()
{


echo -e "\n${CYAN}==> Verificando Vulkan...${RESET}"



if command -v vulkaninfo &>/dev/null; then



    GPU_VULKAN=$(vulkaninfo --summary 2>/dev/null | grep -E "GPU id|deviceName")



    if [ -n "$GPU_VULKAN" ]; then


        echo -e "${GREEN}[ OK ] Vulkan detectó GPU:${RESET}"

        echo "$GPU_VULKAN"


    else


        echo -e "${RED}[FAIL] Vulkan no detectó GPU${RESET}"


        echo -e "${YELLOW}[INFO] Reinicia el equipo antes de volver a probar Vulkan${RESET}"


    fi



else


    echo -e "${RED}[FAIL] vulkan-tools no instalado${RESET}"


fi


}

menu_driver()
{


while true
do


echo

echo -e "${MAGENTA}============================================${RESET}"
echo -e "${MAGENTA}          Instalación Drivers GPU           ${RESET}"
echo -e "${MAGENTA}============================================${RESET}"


echo

echo -e "${CYAN}GPU recomendada:${RESET} ${GREEN}${RECOMMENDED}${RESET}"


if [ "$HYBRID" = true ]; then

    echo -e "${YELLOW}Modo:${RESET} Intel + NVIDIA híbrido"

fi


echo

echo -e "${BLUE}1)${RESET} Instalar recomendado (${GREEN}${RECOMMENDED}${RESET})"
echo -e "${BLUE}2)${RESET} NVIDIA propietario"
echo -e "${BLUE}3)${RESET} AMD Mesa"
echo -e "${BLUE}4)${RESET} Intel Mesa"
echo -e "${BLUE}5)${RESET} Vulkan genérico"
echo -e "${BLUE}6)${RESET} Sin driver"


echo


read -p "$(echo -e "${YELLOW}Seleccione driver: ${RESET}")" OPTION



case $OPTION in



1)


case $RECOMMENDED in



NVIDIA)


    install_nvidia

    configure_nvidia_kms

    configure_hybrid_gpu


;;



AMD)


    install_amd


;;



Intel)


    install_intel


;;



*)


    install_common


;;


esac



break


;;



2)


install_nvidia

configure_nvidia_kms

configure_hybrid_gpu


break


;;



3)


install_amd


break


;;



4)


install_intel


break


;;



5)


install_common


break


;;



6)


echo -e "${YELLOW}[INFO] Sin instalación de drivers GPU${RESET}"

break


;;



*)


echo -e "${RED}[ERROR] Opción inválida. Seleccione una opción del 1 al 6.${RESET}"


;;


esac


done


}




clear


echo -e "${MAGENTA}============================================${RESET}"
echo -e "${MAGENTA}       Instalador Drivers Arch KDE          ${RESET}"
echo -e "${MAGENTA}============================================${RESET}"



check_root


detect_bootloader


detect_gpu


menu_driver


validate_vulkan



echo

echo -e "${MAGENTA}------------------------------------------------------------${RESET}"
echo -e "${GREEN}Instalación de drivers finalizada.${RESET}"
echo -e "${YELLOW}Se recomienda reiniciar el sistema:${RESET}"
echo -e "${CYAN}sudo reboot${RESET}"
echo -e "${MAGENTA}------------------------------------------------------------${RESET}"