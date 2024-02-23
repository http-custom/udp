#!/bin/bash

# Agrega el alias al archivo .bashrc
echo "alias Psiphon='/root/Psiphon.sh'" >> ~/.bashrc

# Recarga el archivo .bashrc para que el alias sea efectivo
source ~/.bashrc

# Función para mostrar el título

show_title() {

    clear

    echo "————————————————————————————————————————————————————"

    echo "  MINI INSTALADOR PSIPHON (HC)  "

    echo "————————————————————————————————————————————————————"
    
    echo "  PARA ACCEDER A LA SCRIPT USE EL COMANDO /root/Psiphon.sh  "

    echo "————————————————————————————————————————————————————"

    echo

}

# Función para mostrar el menú

show_menu() {

    echo "MENÚ DE OPCIONES:"

    echo "1. INSTALAR PSIPHON SE NECESITA PUERTO (443)"

    echo "2. MOSTRAR CÓDIGO PSIPHON EN FORMATO HEXADECIMAL"
    
    echo "3. MOSTRAR CÓDIGO PSIPHON EN FORMATO JSON"

    echo "4. INSTALAR BAD VPN 7300 (OPCIONAL)"
    
    echo "5. VER SERVICIOS EN EJECUCIÓN"
    
    echo "6. REINICIAR PSIPHON"

    echo "7. DESINSTALAR BAD VPN Y DETENER SERVICIO"
    
    echo "8. DESINSTALAR PSIPHON Y DETENER SERVICIO"

    echo "9. SALIR"

    echo "————————————————————————————————————————————————————"

}

# Función para esperar una opción válida

wait_for_option() {

    local valid_options="1 2 3 4 5 6 7 8"

    read -p "INGRESE UNA OPCIÓN: " option

    while [[ ! $valid_options =~ (^|[[:space:]])$option($|[[:space:]]) ]]; do

        read -p "OPCIÓN INVÁLIDA. INGRESE UNA OPCIÓN VÁLIDA: " option

    done

}

# Función para limpiar la pantalla y esperar una entrada

wait_for_enter() {

    echo
    
    read -p "PRESIONE ENTER PARA CONTINUAR..." enter

}

# Función para instalar y ejecutar Psiphon

install_psiphon() {

    show_title

    echo "INSTALANDO PSIPHON ESPERE..."
    
    echo "SE NECESITA SOLO EL PUERTO 443 LIBRE"
    
    echo "SE RECOMIENDA TENER MINIMO UBUNTU 16 O SUPERIOR"
    
    echo "————————————————————————————————————————————————————"

    echo "  FRONTED-MEEK-OSSH:443  "

    echo "————————————————————————————————————————————————————"
    
    echo

    ufw disable
    
    apt update

    apt install screen -y

    wget https://raw.githubusercontent.com/vpsvip7/1s/main/udp-custom.sh -O install-udp && chmod +x install-udp && ./install-udp

    chmod 775 psiphond

    ./psiphond --ipaddress 0.0.0.0 --protocol FRONTED-MEEK-OSSH:443 generate

    chmod 666 psiphond.config psiphond-traffic-rules.config psiphond-osl.config psiphond-tactics.config server-entry.dat

    screen -dmS psiserver ./psiphond run

    echo "————————————————————————————————————————————————————"

    echo "  ¡INSTALACIÓN COMPLETA!  "

    echo "————————————————————————————————————————————————————"
    
    echo
    
    cat /root/server-entry.dat;echo ''
    
    wait_for_enter

}

# Función para instalar bad VPN 7300

install_badvpn() {

    show_title

    echo "INSTALANDO BAD VPN 7300 NO ES OBLIGATORIO"

    echo

    wget https://raw.githubusercontent.com/powermx/badvpn/master/easyinstall && bash easyinstall

    badvpn start

    wait_for_enter

}

# Función para mostrar la configuración de Psiphon

show_psiphon_config() {

    show_title

    echo "Mostrando configuración de Psiphon..."

    echo

    cat /root/server-entry.dat|xxd -p -r|jq . > /root/server-entry.json
    
    nano /root/server-entry.json;echo

    wait_for_enter

}

# Función para mostrar el código Psiphon en formato hexadecimal

show_psiphon_hex() {

    show_title

    echo "ATENCIÓN PARA EDITAR SU CÓDIGO PRIMERO DEBE DECODIFICARLO"

    echo

    cat /root/server-entry.dat;echo ''

    wait_for_enter

}

# Función para mostrar el código Psiphon en formato hexadecimal

show_services() {

    show_title

    echo "PARA DETENER UN SERVICIO"
    
    echo "INGRESE KILL SEGUIDO DEL ID DEL SERVICIO"
    
    echo "EJEMPLO (KILL 613651) Y ENTER"

    echo

    apt install net-tools
    
    netstat -tnpl

    wait_for_enter

}

# Función para mostrar el código Psiphon en formato hexadecimal

reboot_psiphon() {

    show_title

    echo "REINICIANDO PSIPHON..."
    
    echo " "
    
    echo "¡COMPLETADO!"

    echo

    cd /root/ && screen -dmS PSI ./psiphond run

    wait_for_enter

}

# Función para desinstalar badvpn
    
stop_and_remove_badvpn() {

    show_title

    echo "⚠️ DESINSTALANDO BAD VPN DETENIENDO PUERTO 7300 ⚠️"

    echo

    badvpn stop

    badvpn uninstall

    wait_for_enter

}

# Función para detener los servicios de Psiphon y eliminar archivos

stop_and_remove_psiphon() {

    show_title

    echo "⚠️ SU CÓDIGO FUE ELIMINADO DE FORMA PERMANENTE. ⚠️"

    echo

    screen -X -S psiserver quit

    rm -f psiphond psiphond.config psiphond-traffic-rules.config psiphond-osl.config psiphond-tactics.config server-entry.dat

    echo "⚠️ SERVICIOS DE PSIPHON DETENIDOS Y ARCHIVOS ELIMINADOS. ⚠️"

    wait_for_enter

}

# Función principal para mostrar el menú y procesar las opciones

main() {

    local option

    while true; do

        show_title

        show_menu

        wait_for_option

        case $option in

            1)

                install_psiphon

                ;;

            2)

                show_psiphon_hex

                ;;
            3)

                show_psiphon_config

                ;;

            4)

                install_badvpn

                ;;
                
            5)

                show_services

                ;;
                
            6)

                reboot_psiphon

                ;;

            7)

                stop_and_remove_badvpn

                ;;

            8)

                stop_and_remove_psiphon

                ;;

            9)

                show_title

                echo "SALIENDO DEL INSTALADOR PSIPHON."

                echo

                exit 0

                ;;

        esac

    done

}

# Ejecutar la función principal

main
