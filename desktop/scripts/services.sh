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



service_exists()
{

    systemctl list-unit-files | grep -q "^$1"

}



enable_service()
{

    local SERVICE="$1"
    local NAME="$2"


    echo -e "\n${CYAN}==> Configurando ${NAME}...${RESET}"



    if ! service_exists "$SERVICE"; then

        echo -e "${YELLOW}[INFO] ${NAME} no disponible${RESET}"

        return

    fi



    systemctl enable "$SERVICE" >/dev/null 2>&1



    if systemctl is-enabled "$SERVICE" &>/dev/null; then

        echo -e "${GREEN}[ OK ]${RESET} ${NAME} habilitado"

    else

        echo -e "${RED}[FAIL]${RESET} ${NAME}"

    fi


}



start_service()
{

    local SERVICE="$1"
    local NAME="$2"



    echo -e "${CYAN}==> Iniciando ${NAME}...${RESET}"



    systemctl start "$SERVICE" >/dev/null 2>&1



    if systemctl is-active "$SERVICE" &>/dev/null; then

        echo -e "${GREEN}[ OK ]${RESET} ${NAME} activo"

    else

        echo -e "${RED}[FAIL]${RESET} ${NAME}"

    fi


}




enable_user_service()
{

    local SERVICE="$1"
    local NAME="$2"



    echo -e "\n${CYAN}==> Usuario: ${NAME}...${RESET}"



    systemctl --global enable "$SERVICE" >/dev/null 2>&1



    if [ $? -eq 0 ]; then

        echo -e "${GREEN}[ OK ]${RESET} ${NAME}"

    else

        echo -e "${YELLOW}[INFO] ${NAME} no disponible${RESET}"

    fi


}




detect_bluetooth()
{

    if lsusb | grep -qi bluetooth || \
       rfkill list | grep -qi bluetooth; then


        return 0


    else


        return 1


    fi

}



detect_pipewire()
{


if command -v pipewire &>/dev/null; then

    return 0

else

    return 1

fi


}




configure_network()
{


enable_service \
NetworkManager.service \
"NetworkManager"


}




configure_display()
{


if pacman -Q plasma-desktop &>/dev/null || \
   pacman -Q plasma-meta &>/dev/null; then


    enable_service \
    sddm.service \
    "SDDM KDE Display Manager"


else


    echo -e "${YELLOW}[INFO] KDE Plasma no detectado, omitiendo SDDM${RESET}"


fi


}




configure_bluetooth()
{


echo -e "\n${CYAN}==> Detectando Bluetooth...${RESET}"



if detect_bluetooth; then


    echo -e "${GREEN}[ OK ] Adaptador Bluetooth detectado${RESET}"


    enable_service \
    bluetooth.service \
    "Bluetooth"



else


    echo -e "${YELLOW}[INFO] Sin adaptador Bluetooth${RESET}"


fi


}




configure_docker()
{


echo -e "\n${CYAN}==> Verificando Docker...${RESET}"



if pacman -Q docker &>/dev/null; then


    enable_service \
    docker.service \
    "Docker"



else


    echo -e "${YELLOW}[INFO] Docker no instalado${RESET}"


fi


}




configure_ssh()
{


echo -e "\n${CYAN}==> Verificando SSH...${RESET}"



if pacman -Q openssh &>/dev/null; then


    enable_service \
    sshd.service \
    "SSH Server"



else


    echo -e "${YELLOW}[INFO] OpenSSH no instalado${RESET}"


fi


}




configure_firewall()
{


echo -e "\n${CYAN}==> Configurando Firewall...${RESET}"



if ! command -v ufw &>/dev/null; then


    echo -e "${YELLOW}[INFO] UFW no instalado${RESET}"

    return


fi



systemctl enable ufw >/dev/null 2>&1

systemctl start ufw >/dev/null 2>&1


ufw --force enable >/dev/null 2>&1



if ufw status | grep -q active; then


    echo -e "${GREEN}[ OK ] Firewall UFW activo${RESET}"


else


    echo -e "${RED}[FAIL] Firewall UFW${RESET}"


fi


}




configure_pipewire()
{


echo -e "\n${CYAN}==> Verificando PipeWire...${RESET}"



if detect_pipewire; then



    enable_user_service \
    pipewire.socket \
    "PipeWire socket"



    enable_user_service \
    pipewire-pulse.socket \
    "PipeWire Pulse"



    enable_user_service \
    wireplumber.service \
    "WirePlumber"



else


    echo -e "${YELLOW}[INFO] PipeWire no instalado${RESET}"


fi


}




configure_timesync()
{


enable_service \
systemd-timesyncd.service \
"Sincronización de hora"


}



summary()
{


echo

echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${GREEN}Servicios configurados correctamente${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"

echo

echo -e "${CYAN}Servicios activos:${RESET}"

systemctl --type=service --state=running | \
grep -E "NetworkManager|sddm|bluetooth|docker|sshd|ufw"



echo

echo -e "${YELLOW}Recomendado reiniciar:${RESET}"
echo -e "${GREEN}sudo reboot${RESET}"


}




clear


echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${MAGENTA}        Configuración Servicios Arch KDE             ${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"



check_root
configure_network
configure_display
configure_bluetooth
configure_docker
configure_ssh
configure_firewall
configure_pipewire
configure_timesync
summary