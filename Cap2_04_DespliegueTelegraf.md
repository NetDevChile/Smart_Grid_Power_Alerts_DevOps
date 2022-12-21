# Telegraf

## Modificación de la imágen original de Docker Hub

Se tuvo que usar una imágen propia a partir de la original de telegraf (v1.24) debio a que se debió incluir datos de tipo _mibs_ para el _plugin_ del protocolo de comunicación SNMP. Es por ésto que, en el caso de telegraf, no usamos la imágen oficial del _hub_ de Docker, si no una creada por NetDev

El archivo YAML del despliegue de _telegraf_ se puede [descargar aquí](yamls/02_telegraf.yaml)

**[Volver al README](/README.md)**, al [paso 3](/Cap2_03_DespliegueInfluxdb.md)
