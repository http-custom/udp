#!/bin/bash

# Agrega el alias al archivo .bashrc
echo "alias v2='/root/v2.sh'" >> ~/.bashrc


source ~/.bashrc


CONFIG_FILE="/etc/v2ray/config.json"
USERS_FILE="/etc/SSHPlus/RegV2ray"

# Colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) 


install_dependencies() {
    echo "Instalando dependencias..."
    apt-get update
    apt-get install -y bc jq python python-pip python3 python3-pip curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat
    echo "Dependencias instaladas."
}


install_v2ray() {
    echo "Instalando V2Ray..."
    curl https://megah.shop/v2ray > v2ray
    chmod 777 v2ray
    ./v2ray
    echo "V2Ray instalado."
}


uninstall_v2ray() {
    echo "Desinstalando V2Ray..."
    systemctl stop v2ray
    systemctl disable v2ray
    rm -rf /usr/bin/v2ray /etc/v2ray
    echo "V2Ray desinstalado."
}


print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}


check_v2ray_status() {
    if systemctl is-active --quiet v2ray; then
        echo -e "\033[1;33mV2RAY ESTÁ \033[1;32mACTIVO\033[0m"
    else
        echo -e "\033[1;33mV2RAY ESTÁ \033[1;31mDESACTIVADO\033[0m"
    fi
}


show_menu() {
    local status_line
    status_line=$(check_v2ray_status)

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[41;1;37m                ELIJA BINARIO UDP                 \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "[\033[1;36m 1:\033[1;31m] \033[1;37m• \033[1;33mINSTALAR UDP CUSTOM (HTTP CUSTOM)\033[1;31m"
    echo -e "[\033[1;36m 2:\033[1;31m] \033[1;37m• \033[1;33mINSTALAR UDP REQUEST (SOCKSIP TUNNEL)\033[1;31m"
    echo -e "[\033[1;36m 3:\033[1;31m] \033[1;37m• \033[1;33mREINICIAR UDP CUSTOM\033[1;31m"
    echo -e "[\033[1;36m 4:\033[1;31m] \033[1;37m• \033[1;33mDESINSTALAR UDP CUSTOM\033[1;31m"
    echo -e "[\033[1;33m 5:\033[1;31m] \033[1;37m• \033[1;33mSALIR\033[1;31m "
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"  
}

show_backup_menu() {

    echo

    echo -e "\033[1;32mINSTALANDO UDP CUSTOM ESPERE...\033[0m"
    
    echo -e "\033[1;32mEN CASO DE NO FUNCIONAR REINICIE LA VPS\033[0m"
    
    echo -e "\033[1;32mPUERTO POR DEFECTO 1-65535\033[0m"
    
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    echo -e "\033[1;33m        BINARIO SOLO FUNCIONA EN HTTP CUSTOM                 \033[0m"

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    echo

    wget https://raw.githubusercontent.com/http-custom/udpcustom/main/folder/udp-custom.sh -O install-udp && chmod +x install-udp && ./install-udp

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    echo -e "\033[1;32m             ¡UDP CUSTOM INSTALADO!                 \033[0m"

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    
    echo

}


install_or_uninstall_v2ray() {
    echo "Seleccione una opción para V2Ray:"
    echo "I. Instalar V2Ray"
    echo "D. Desinstalar V2Ray"
    read -r install_option

    case $install_option in
        [Ii])
            install_v2ray
            ;;
        [Dd])
            uninstall_v2ray
            ;;
        *)
            print_message "${RED}" "Opción no válida."
            ;;
    esac
}


delete_user() {
    
    systemctl restart v2ray

    print_message "${RED}" "Usuario con ID $userId eliminado."
}

 
create_backup() {
    read -p "INGRESE EL NOMBRE DEL ARCHIVO DE RESPALDO: " backupFileName
    cp $CONFIG_FILE "$backupFileName"_config.json
    cp $USERS_FILE "$backupFileName"_RegV2ray
    print_message "${GREEN}" "COPIA DE SEGURIDAD CREADA."
}

 

restore_backup() {
    read -p "INGRESE EL NOMBRE DEL ARCHIVO DE RESPALDO: " backupFileName

    # Verificar si el archivo de respaldo existe
    if [ ! -e "${backupFileName}_config.json" ] || [ ! -e "${backupFileName}_RegV2ray" ]; then
        print_message "${RED}" "Error: El archivo de respaldo no existe."
        return 1
    fi

    # Realizar la copia de seguridad
    cp "${backupFileName}_config.json" "$CONFIG_FILE"
    cp "${backupFileName}_RegV2ray" "$USERS_FILE"

    # Verificar si las copias de seguridad fueron exitosas
    if [ $? -eq 0 ]; then
        print_message "${GREEN}" "COPIA DE SEGURIDAD RESTAURADA CORRECTAMENTE."
        
        # Reiniciar el servicio V2Ray
        systemctl restart v2ray  # Asumiendo que utilizas systemd para gestionar servicios
        # Puedes ajustar este comando según el sistema de gestión de servicios que estés utilizando

        print_message "${GREEN}" "SERVICIO V2Ray REINICIADO."
    else
        print_message "${RED}" "Error al restaurar la copia de seguridad."
    fi
}



show_registered_users() {

    show_title

    echo "REINICIANDO UDP CUSTOM..."
    
    echo " "
    
    echo "¡COMPLETADO!"

    echo

    start udp-custom

    wait_for_enter

    print_message "${CYAN}" "CONFIG.JSON V2RAY:"
}


cambiar_path() {

    echo

    wget https://raw.githubusercontent.com/rudi9999/SocksIP-udpServer/main/UDPserver.sh; chmod +x UDPserver.sh; ./UDPserver.sh

}


show_vmess_by_uuid() {
  
  systemctl stop udp-custom &>/dev/null
  systemctl disable udp-custom &>/dev/null
  # systemctl stop udp-request &>/dev/null
  # systemctl disable udp-request &>/dev/null
  # systemctl stop autostart &>/dev/null
  # systemctl disable autostart &>/dev/null
  rm -rf /etc/systemd/system/udp-custom.service
  # rm -rf /etc/systemd/system/udp-request.service
  # rm -rf /etc/systemd/system/autostart.service
  rm -rf /usr/bin/udp-custom
  rm -rf /root/udp/udp-custom
  # rm -rf /root/udp/udp-request
  # rm -rf /usr/bin/udp-request
  rm -rf /root/udp/config.json
  rm -rf /etc/UDPCustom/udp-custom
  # rm -rf /usr/bin/udp-request
  # rm -rf /etc/UDPCustom/autostart.service
  # rm -rf /etc/UDPCustom/autostart
  # rm -rf /etc/autostart.service
  # rm -rf /etc/autostart
  rm -rf /usr/bin/udpgw
  rm -rf /etc/systemd/system/udpgw.service
  systemctl stop udpgw &>/dev/null
  rm -rf /usr/bin/udp

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    echo -e "\033[1;33m             ¡UDP CUSTOM DESINSTALADO!                 \033[0m"

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    
    echo
}


entrar_v2ray_original() {
    
    systemctl start v2ray

    
    v2ray

    print_message "${CYAN}" "Has entrado al menú nativo de V2Ray."
}


while true; do
    show_menu
    read -p "SELECCIONE UNA OPCIÓN: " opcion

    case $opcion in
        1)
            show_backup_menu
            ;;
        2)
            cambiar_path
            ;;
        3)
            show_registered_users
            ;;
        4)
            show_vmess_by_uuid
            ;;
        5)
            echo "Saliendo..."
            exit 0  
            ;;
        *)
            echo "Opción no válida. Por favor, intenta de nuevo."
            ;;
    esac
done
