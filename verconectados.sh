#!/bin/bash

while true; do
  echo "BIENVENIDO AL MENÚ PARA VER CONECTADOS"
  echo "SELECCIONE UNA OPCIÓN:"
  echo "1. VER CONECTADOS EN EL PUERTO 80"
  echo "2. VER CONECTADOS EN EL PUERTO 8080"
  echo "3. SALIR"

  read -p "Opción: " opcion

  case $opcion in
    1)
      V2RAY_PORT_80=$(sudo netstat -tn | awk '$4 ~ /:80$/ {print $5}' | cut -d: -f1 | sort | uniq -c | wc -l)
      echo "CONEXIONES EN EL PUERTO 80 DE V2RAY: $V2RAY_PORT_80"
      ;;
    2)
      V2RAY_PORT_8080=$(sudo netstat -tn | awk '$4 ~ /:8080$/ {print $5}' | cut -d: -f1 | sort | uniq -c | wc -l)
      echo "CONEXIONES EN EL PUERTO 8080 DE V2RAY: $V2RAY_PORT_8080"
      ;;
    3)
      echo "SALIENDO DEL SCRIPT..."
      break
      ;;
    *)
      echo "OPCIÓN INVÁLIDA"
      ;;
  esac

  echo
done