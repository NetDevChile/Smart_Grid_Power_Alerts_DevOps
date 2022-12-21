# Telegraf

## Imágen de Telegraf de NetDev

### Modificación de la imágen original de Docker Hub

Se creó una imágen propia a partir de la original de telegraf (v1.24) debio a que se debió incluir datos de tipo _MIBS_ para el _plugin_ del protocolo de comunicación SNMP. Es por ésto que, en el caso de telegraf, no usamos la imágen oficial del _hub_ de Docker, si no una creada por NetDev

El archivo YAML del despliegue de _telegraf_ se puede [descargar aquí](yamls/02_telegraf.yaml)

## Alternativa a la imágen de NetDev

En caso de no poder acceder a la imágen de NetDev, o si se deseara usar una nueva versión de telegraf que apareciera en el futuro, es posible usar una imágen original de telegraf desde Docker Hub

Luego de hacer _pull_, se debe iniciar el contendedor, acceder por consola y correr el siguiente _script_:

```sh
cd /usr/share/snmp/mibs && \
    wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/NetDevChile/MIBS/main/mibs.zip && wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/NetDevChile/MIBS/main/7za && \
    chmod +x ./7za && \
    ./7za x mibs.zip
```

El _script_ anterior hace lo siguiente:

- Cambia la ruta actual de la consola a /usr/share/snmp/mibs
- Descarga las especificaciones adicionales _MIBS_ en un archivo comprimido de tipo `zip`
- Descarga la herramienta pre-compilada `7zip`, que permite comprimir y descomprimir archivos
- Descomprimir el archivo `zip` usando `7zip`

El _script_ se puede [descargar aquí](/scripts/descarga_unzip_mibs.sh)

**[Volver al README](/README.md)**, al [paso 3](/Cap2_03_DespliegueInfluxdb.md)
