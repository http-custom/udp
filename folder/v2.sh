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
        echo -e "${YELLOW}V2RAT ESTÁ ${GREEN}ACTIVO${NC}"
    else
        echo -e "${YELLOW}V2RAY ESTÁ ${RED}DESACTIVADO${NC}"
    fi
}


show_menu() {
    local status_line
    status_line=$(check_v2ray_status)

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}          • V2RAY MENU •          ${NC}"
    echo -e "[${status_line}]"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "[\033[1;36m 1:\033[1;31m] \033[1;37m• \033[1;32mGESTIÓN DE COPIAS DE SEGURIDAD UUID\033[1;31m"
    echo -e "[\033[1;36m 2:\033[1;31m] \033[1;37m• \033[1;32mCAMBIAR EL PATH DE V2RAY\033[1;31m"
    echo -e "[\033[1;36m 3:\033[1;31m] \033[1;37m• \033[1;32mVER CONFIG.JSON\033[1;31m"
    echo -e "[\033[1;36m 4:\033[1;31m] \033[1;37m• \033[1;32mVER INFORMACIÓN DE VMESS\033[1;31m"
    echo -e "[\033[1;36m 5:\033[1;31m] \033[1;37m• \033[1;32mESTATÍSTICAS DE CONSUMO\033[1;31m"
    echo -e "[\033[1;36m 6:\033[1;31m] \033[1;37m• \033[1;32mENTRAR AL V2RAY NATIVO\033[1;31m"
    echo -e "[\033[1;36m 7:\033[1;31m] \033[1;37m• \033[1;32mREINICIAR V2RAY\033[1;31m"
    echo -e "[\033[1;36m 8:\033[1;31m] \033[1;37m• \033[1;32mINSTALAR/DESINSTALAR V2RAY\033[1;31m"
    echo -e "[\033[1;36m 9:\033[1;31m] \033[1;37m• \033[1;32mSALIR\033[1;31m"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}⚙️ Acceder al menú con V2${NC}"  
}

show_backup_menu() {
    echo -e "[1;33mOPCIONES DE V2RAY BACKUP:\033"
    echo -e "1. ${GREEN}CREAR COPIA DE SEGURIDAD${NC}"
    echo -e "2. ${GREEN}RESTAURAR COPIA DE SEGURIDAD${NC}"
    echo -e "${CYAN}==========================${NC}"
    read -p "Seleccione una opción: " backupOption

    case $backupOption in
        1)
            create_backup
            ;;
        2)
            restore_backup
            ;;
        *)
            print_message "${RED}" "Opción no válida."
            ;;
    esac
}


add_user() {
    
    v2ray stats

    print_message "${GREEN}" "Usuario agregado exitosamente."
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
    
    cat /etc/v2ray/config.json

    print_message "${CYAN}" "CONFIG.JSON V2RAY:"
}


cambiar_path() {
    read -p "INGRESE EL NUEVO PATH: " nuevo_path

    
    jq --arg nuevo_path "$nuevo_path" '.inbounds[0].streamSettings.wsSettings.path = $nuevo_path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    echo -e "\033[33mEL PATH HA SIDO CAMBIADO A $nuevo_path.\033[0m"

    
    systemctl restart v2ray
    
    print_message "${GREEN}" "SERVICIO V2Ray REINICIADO."
}


show_vmess_by_uuid() {
    
    v2ray info

    print_message "${CYAN}" "Has entrado al menú nativo de V2Ray."
}


entrar_v2ray_original() {
    
    systemctl start v2ray

    
    v2ray

    print_message "${CYAN}" "Has entrado al menú nativo de V2Ray."
}


while true; do
    show_menu
    read -p "Seleccione una opción: " opcion

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
            add_user
            ;;
        6)
            entrar_v2ray_original
            ;;
        7)
            delete_user
            ;;
        8)
            while true; do
                echo "Seleccione una opción para V2Ray:"
                echo "1. Instalar V2Ray"
                echo "2. Desinstalar V2Ray"
                echo "3. Volver al menú principal"
                read -r install_option

                case $install_option in
                    1)
                        echo "Instalando V2Ray..."
                        bash -c "$(curl -fsSL https://megah.shop/v2ray)"
                        ;;
                    2)
                        echo "Desinstalando V2Ray..."
                        
                        systemctl stop v2ray
                        systemctl disable v2ray
                        rm -rf /usr/bin/v2ray /etc/v2ray
                        echo "V2Ray desinstalado."
                        ;;
                    3)
                        echo "Volviendo al menú principal..."
                        break  
                        ;;
                    *)
                        echo "Opción no válida. Por favor, intenta de nuevo."
                        ;;
                esac
            done
            ;;
        9)
            echo "Saliendo..."
            exit 0  
            ;;
        *)
            echo "Opción no válida. Por favor, intenta de nuevo."
            ;;
    esac
done
