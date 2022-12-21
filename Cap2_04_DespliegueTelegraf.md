# Telegraf

## Imágen de Telegraf de NetDev

### Modificación de la imágen original de Docker Hub

Se creó una imágen propia a partir de la original de Telegraf, versión 1.24, debido la necesidad de incluir definiciones de tipo de datos _MIBS_ para el _plugin_ del protocolo de comunicación _SNMP_. Es por ésto que, en el caso de Telegraf, no usamos la imágen oficial del _hub_ de Docker Hub, si no que una creada por NetDev

# El despliegue

El archivo YAML del despliegue de Telegraf se puede [descargar aquí](yamls/02_telegraf.yaml)

Consideraciones del archivo YAML del despliegue de Telegraf:

- Como se comentó previamente, la imágen a utilizar es `smartgridsystembynetdevchile/telegraf-netdev:v1`
- Se crea un punto de montaje en `/etc/telegraf` que permite asociar el despliegue al archivo `telegraf.conf` definido como recurso de tipo _ConfigMap_, lo que posibilita tener control de la configuración de Telegraf desde la interfaz de usuario web de Rancher

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

A continuación, puede ver imágenes (capturas de pantalla) del sistema funcionando haciendo clic [aquí](Cap2_05_Imagenes.md)

**[Volver al README](/README.md)**, al [paso 3](/Cap2_03_DespliegueInfluxdb.md)
