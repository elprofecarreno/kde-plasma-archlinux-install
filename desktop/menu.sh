#!/bin/bash

BLUE='\e[38;2;59;130;246m'
CYAN='\e[38;2;0;220;255m'
MAGENTA='\e[38;2;220;90;255m'
RED='\e[38;2;255;0;0m'
YELLOW='\e[38;2;255;215;0m'
GREEN='\e[38;2;0;200;83m'
RESET='\e[0m'


echo -e "${MAGENTA}__________________________________________________________________________"
echo -e "${MAGENTA}__________________________________________________________________________"
echo -e "${MAGENTA}__________________________________________________________________________${RESET}"

echo -e "${BLUE}
██╗  ██╗██████╗ ███████╗    ██████╗ ██╗      █████╗ ███████╗███╗   ███╗ █████╗
██║ ██╔╝██╔══██╗██╔════╝    ██╔══██╗██║     ██╔══██╗██╔════╝████╗ ████║██╔══██╗
█████╔╝ ██║  ██║█████╗      ██████╔╝██║     ███████║███████╗██╔████╔██║███████║
██╔═██╗ ██║  ██║██╔══╝      ██╔═══╝ ██║     ██╔══██║╚════██║██║╚██╔╝██║██╔══██║
██║  ██╗██████╔╝███████╗    ██║     ███████╗██║  ██║███████║██║ ╚═╝ ██║██║  ██║
${CYAN}╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝${RESET}"

echo -e "\
${BLUE} █████╗ ██████╗  ██████╗██╗  ██╗██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗${CYAN}    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗
${BLUE}██╔══██╗██╔══██╗██╔════╝██║  ██║██║     ██║████╗  ██║██║   ██║╚██╗██╔╝${CYAN}    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
${BLUE}███████║██████╔╝██║     ███████║██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ ${CYAN}    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║
${BLUE}██╔══██║██╔══██╗██║     ██╔══██║██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ ${CYAN}    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║
${BLUE}██║  ██║██║  ██║╚██████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗${CYAN}    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
${BLUE}╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝${MAGENTA}    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝${RESET}"


echo -e "${MAGENTA}__________________________________________________________________________"
echo -e "${MAGENTA}__________________________________________________________________________"
echo -e "${MAGENTA}__________________________________________________________________________${RESET}"



show_menu() {

    while true; do

        echo -e "\n${CYAN}================ MENÚ DE INSTALACIÓN ================${RESET}"
        echo -e "${BLUE}1)${RESET} Instalar KDE Plasma"
        echo -e "${BLUE}2)${RESET} Instalar aplicaciones Flatpak"
        echo -e "${BLUE}3)${RESET} Instalar drivers de video"
        echo -e "${BLUE}4)${RESET} Instalar servicios"
        echo -e "${RED}5)${RESET} Salir"
        echo -e "${RED}6)${RESET} Reiniciar PC"
        echo -e "${CYAN}======================================================${RESET}"

        echo -ne "${YELLOW}Seleccione una opción: ${RESET}"
        read option

        case $option in

            1)
                echo -e "\n${CYAN}==> Ejecutando instalación KDE Plasma...${RESET}"

                if [ -f "./scripts/kde-plasma.sh" ]; then
                    chmod +x ./scripts/kde-plasma.sh
                    ./scripts/kde-plasma.sh
                else
                    echo -e "${RED}[FAIL] No existe ./scripts/kde-plasma.sh${RESET}"
                fi
            ;;

            2)
                echo -e "\n${CYAN}==> Instalando aplicaciones Flatpak...${RESET}"

                if [ -f "./scripts/flatpak-app.sh" ]; then
                    chmod +x ./scripts/flatpak-app.sh
                    ./scripts/flatpak-app.sh
                else
                    echo -e "${RED}[FAIL] No existe ./scripts/flatpak-app.sh${RESET}"
                fi
            ;;

            3)
                echo -e "\n${CYAN}==> Instalando drivers de video...${RESET}"

                if [ -f "./scripts/gpu.sh" ]; then
                    chmod +x ./scripts/gpu.sh
                    ./scripts/gpu.sh
                else
                    echo -e "${RED}[FAIL] No existe ./scripts/gpu.sh${RESET}"
                fi
            ;;

            4)
                echo -e "\n${CYAN}==> Configurando servicios...${RESET}"

                if [ -f "./scripts/services.sh" ]; then
                    chmod +x ./scripts/services.sh
                    ./scripts/services.sh
                else
                    echo -e "${RED}[FAIL] No existe ./scripts/services.sh${RESET}"
                fi
            ;;

            5)
                echo -e "\n${GREEN}Saliendo del instalador...${RESET}"
                exit 0
            ;;

            6)
                echo -e "\n${YELLOW}Reiniciando el equipo...${RESET}"
                reboot
            ;;

            *)
                echo -e "\n${RED}[ERROR] Opción inválida: $option${RESET}"
                echo -e "${YELLOW}Seleccione una opción entre 1 y 6.${RESET}"
                sleep 2
            ;;

        esac

    done
}


show_menu