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



install_dependencies()
{

    if ! command -v whiptail &>/dev/null; then


        echo -e "${YELLOW}==> Instalando whiptail...${RESET}"


        pacman -S --noconfirm --needed newt >/dev/null 2>&1



        if command -v whiptail &>/dev/null; then

            echo -e "${GREEN}[ OK ] whiptail instalado${RESET}"

        else

            echo -e "${RED}[FAIL] No se pudo instalar whiptail${RESET}"

            exit 1

        fi


    fi

}



check_flatpak()
{


echo -e "\n${CYAN}==> Verificando Flatpak...${RESET}"


if command -v flatpak &>/dev/null; then


    echo -e "${GREEN}[ OK ] Flatpak disponible${RESET}"


else


    echo -e "${RED}[FAIL] Flatpak no está instalado${RESET}"

    exit 1


fi


}



check_flathub()
{


echo -e "\n${CYAN}==> Verificando repositorio Flathub...${RESET}"



if flatpak remotes | grep -q "^flathub"; then


    echo -e "${GREEN}[ OK ] Flathub disponible${RESET}"


else


    echo -e "${YELLOW}==> Agregando Flathub...${RESET}"



    flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo



    if flatpak remotes | grep -q "^flathub"; then


        echo -e "${GREEN}[ OK ] Flathub agregado${RESET}"


    else


        echo -e "${RED}[FAIL] Error agregando Flathub${RESET}"

        exit 1


    fi


fi


}




declare -A FLATPAKS=(

["Google Chrome"]="com.google.Chrome"
["Brave Browser"]="com.brave.Browser"
["Discord"]="com.discordapp.Discord"
["Teams"]="com.github.IsmaelMartinez.teams_for_linux"
["OnlyOffice"]="org.onlyoffice.desktopeditors"
["Spotify"]="com.spotify.Client"
["Telegram"]="org.telegram.desktop"
["Bitwarden"]="com.bitwarden.desktop"
["Zoom"]="us.zoom.Zoom"
["LibreOffice"]="org.libreoffice.LibreOffice"
["qBittorrent"]="org.qbittorrent.qBittorrent"
["Kdenlive"]="org.kde.kdenlive"
["GIMP"]="org.gimp.GIMP"
["Krita"]="org.kde.krita"
["Inkscape"]="org.inkscape.Inkscape"

)



declare -A DESCRIPTION=(

["Google Chrome"]="Navegador web de Google"
["Brave Browser"]="Navegador privado con bloqueo de anuncios"
["Discord"]="Chat, comunidades y llamadas"
["Teams"]="Cliente Microsoft Teams no oficial"
["OnlyOffice"]="Suite ofimatica compatible con MS Office"
["Spotify"]="Cliente oficial de musica streaming"
["Telegram"]="Mensajeria instantanea segura"
["Bitwarden"]="Administrador de contrasenas"
["Zoom"]="Videoconferencias y reuniones online"
["LibreOffice"]="Suite ofimatica libre"
["qBittorrent"]="Cliente BitTorrent ligero"
["Kdenlive"]="Editor de video KDE"
["GIMP"]="Editor de imagenes avanzado"
["Krita"]="Pintura digital e ilustracion"
["Inkscape"]="Editor de graficos vectoriales"

)



get_name_from_id()
{


local ID="$1"



for NAME in "${!FLATPAKS[@]}"
do


    if [ "${FLATPAKS[$NAME]}" = "$ID" ]; then


        echo "$NAME"

        return


    fi


done


echo "$ID"


}





flatpak_menu()
{

local OPTIONS=()


for APP in "${!FLATPAKS[@]}"
do

    OPTIONS+=(

        "${FLATPAKS[$APP]}"

        "${APP} - ${DESCRIPTION[$APP]}"

        "OFF"

    )

done



SELECTED=$(whiptail \
--title "Aplicaciones Flatpak" \
--separate-output \
--checklist \
"Seleccione aplicaciones para instalar:" \
35 110 25 \
"${OPTIONS[@]}" \
3>&1 1>&2 2>&3)


}



install_flatpaks()
{


if [ -z "$SELECTED" ]; then


    echo -e "${YELLOW}[INFO] No se seleccionaron aplicaciones${RESET}"

    return


fi




while read -r APP
do


    [ -z "$APP" ] && continue



    NAME=$(get_name_from_id "$APP")



    echo -e "\n${CYAN}==> Verificando ${NAME}...${RESET}"



    if flatpak info "$APP" &>/dev/null; then


        echo -e "${GREEN}[ OK ]${RESET} ${NAME} ya instalado"

        continue


    fi



    echo -e "${CYAN}==> Instalando ${NAME}...${RESET}"



    flatpak install -y flathub "$APP"



    if flatpak info "$APP" &>/dev/null; then


        echo -e "${GREEN}[  OK  ]${RESET} ${NAME}"


    else


        echo -e "${RED}[FAIL ]${RESET} ${NAME}"


    fi



done <<< "$SELECTED"



}




update_flatpaks()
{


echo -e "\n${CYAN}==> Actualizando aplicaciones Flatpak...${RESET}"



flatpak update -y >/dev/null 2>&1



if [ $? -eq 0 ]; then


    echo -e "${GREEN}[ OK ] Flatpak actualizado${RESET}"


else


    echo -e "${RED}[FAIL] Error actualizando Flatpak${RESET}"


fi


}





clear


echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${MAGENTA}        Instalación de aplicaciones Flatpak          ${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"



check_root


install_dependencies


check_flatpak


check_flathub



echo


flatpak_menu


install_flatpaks


update_flatpaks



echo


echo -e "${MAGENTA}====================================================${RESET}"
echo -e "${GREEN}Proceso Flatpak finalizado${RESET}"
echo -e "${MAGENTA}====================================================${RESET}"