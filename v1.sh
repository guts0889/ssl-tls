#!/bin/bash

cert="/etc/letsencrypt/live/doldrey.com/cert.pem"
apache="apache2"
nginx="nginx"

# Función para obtener las fechas de expiración de todos los certificados en un archivo
fechas_exp() {
    # Extrae las fechas de expiración de cada certificado
    openssl crl2pkcs7 -nocrl -certfile "$cert" | openssl pkcs7 -print_certs -noout | \
    grep 'notAfter=' | sed 's/notAfter=//'
}

# Función para reiniciar servicios
restart() {
    echo "Reiniciando servicios"
    sudo systemctl restart "$apache"
    sudo systemctl restart "$nginx"
    echo "Completado"
}

# Obtener la fecha actual en segundos
fecha_actual=$(date +%s)

# Inicializar la variable para la última fecha de expiración
ultima_fecha_cert=0

# Procesar todas las fechas de expiración
for fecha in $(fechas_exp); do
    fecha_cert=$(date -d "$fecha" +%s)
    # Verificar si esta fecha es posterior a la última registrada
    if [ "$fecha_cert" -gt "$ultima_fecha_cert" ]; then
        ultima_fecha_cert=$fecha_cert
    fi
done

# Calcular diferencia entre la última fecha de expiración y la fecha actual
dif_tiempo=$((ultima_fecha_cert - fecha_actual))

if [ "$dif_tiempo" -le 0 ]; then
    echo "El certificado ha caducado."
    restart
else
    echo "El certificado caduca en $((dif_tiempo / 86400)) días"
fi
