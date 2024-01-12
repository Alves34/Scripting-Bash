#!/bin/bash

# Ejercicio: Copia de seguridad automatizada

# Pedir al usuario la ruta del directorio a respaldar
while true; do
    read -p "Bienvenido a esta copia de Seguridad Automatizada. Proporcione la ruta a respaldar (por ejemplo: /home/user/BBDD): " ruta_a_respaldar

    if [ -e "$ruta_a_respaldar" ]; then
        echo "La ruta existe."
        break  # Salir del bucle si la ruta es válida
    else
        echo "La ruta no existe. Vuelva a insertar la ruta."
    fi
done

# Verificar la existencia del directorio de respaldo
while true; do
    read -p "Ingrese la ruta donde desea respaldar el directorio: " ruta_respaldo

    if [ -e "$ruta_respaldo" ]; then
        echo "La ruta existe."
        break
    else
        echo "La ruta no existe. Vuelva a insertarla o créela."
    fi
done

# Realizar la copia de seguridad
rsync -av --progress --delete "$ruta_a_respaldar/" "$ruta_respaldo"
echo "Copia de seguridad completada con éxito."

# Preguntar al usuario si desea encriptar el directorio guardado
read -p "¿Deseas encriptar el directorio guardado (Y/N): " encriptar

if [ "$encriptar" = "Y" ]; then
    # Solicitar contraseña para la encriptación
    read -s -p "Ingresa la contraseña de encriptación: " contraseña
    echo # Agregar un salto de línea después de la entrada de la contraseña
    
    # Verificar si se ingresó una contraseña
    if [ -z "$contraseña" ]; then
        echo "Error: La contraseña no puede estar vacía. Saliendo..."
        exit 1
    fi
    
    # Añadir el código para encriptar el directorio usando GPG con la contraseña proporcionada
    gpg --symmetric --batch --yes --passphrase "$contraseña" -o "$ruta_respaldo/directorio_encriptado.gpg" "$ruta_respaldo"
    echo "Directorio encriptado con éxito."
else
    echo "No se realizará la encriptación. Saliendo..."
fi
