#!/bin/bash

while true; do
  echo "BIENVENIDO AL MENÚ PARA VER CONECTADOS"
  echo "Seleccione una opción:"
  echo "1. Ver conectados en el puerto 80"
  echo "2. Ver conectados en el puerto 443"
  echo "3. Salir"

  read -p "Opción: " opcion

  case $opcion in
    1)
      PSIPHON_PORT_8080=$(sudo netstat -tn | awk '$4 ~ /:8080$/ {print $5}' | cut -d: -f1 | sort | uniq -c | wc -l)
      echo "CONEXIONES EN EL PUERTO 8080 DE PSIPHON: $PSIPHON_PORT_8080"
      ;;
    2)
      PSIPHON_PORT_80=$(sudo netstat -tn | awk '$4 ~ /:80$/ {print $5}' | cut -d: -f1 | sort | uniq -c | wc -l)
      echo "CONEXIONES EN EL PUERTO 80 DE PSIPHON: $PSIPHON_PORT_80"
      ;;
    3)
      echo "Saliendo del script..."
      break
      ;;
    *)
      echo "Opción inválida"
      ;;
  esac

  echo
done