#!/bin/bash

cert="/etc/letsencrypt/live/doldrey.com/cert.pem"
apache="apache2"
nginx="nginx"

#funcion obtener fecha certificado
fecha_exp() {
    openssl x509 -enddate -noout -in "$cert" | sed 's/notAfter=//'
}

#funcion reinicio servicios
restart() {
    echo "Reiniciando servicios"
    sudo systemctl restart "$apache"
    sudo systemctl restart "$nginx"
    echo "Completado"
}

#pasar fecha actual y fecha expiracion en segundos
fecha_actual=$(date +%s)
fecha_cert=$(date -d "$(fecha_exp)" +%s)

#calcular diferencica entre las dos fechas
dif_tiempo=$((fecha_cert - fecha_actual))

if [ "$dif_tiempo" -le 0 ]; then
    echo "El certificado ha caducado."
    sleep 60
    restart
else
    echo "El certificado caduca en $((dif_tiempo / 86400)) dias"
fi