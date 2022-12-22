# NUT

Network UPS Tools (tambipen conocido como _NUT_) es un conjunto de componentes de software diseñado para monitorear dispositivos de energía, como fuentes de alimentación ininterrumpida, unidades de distribución de energía, controladores solares y unidades de fuente de alimentación de servidores.

Se crearon archivos de configuración y _scripts_ para el uso de un servidor NUT, InfluxDB y envío de alarmas. Actualmente, este trabajo queda archivado y descartado para dar pie al uso del protocolo SNMP

## _Scripts_ archivados

Los _scripts_ deprecados son los siguientes:

- [ups_event.sh](</scripts/(deprecado)ups_event.sh>): Implementación de alarmas mediante envío de correo
- [mail.sh](</scripts/(deprecado)mail.sh>): _Script_ de envío de correos
- [influx_nut.py](</scripts/(deprecado)influx_nut.py>): _Daemon_ y librería para enviar estadísticas a InfluxDB
- [creacionDB_influx.sql](</scripts/(deprecado)creadionDB_influxdb.sql>): Creación de la base de datos en InfluxDB

## Archivos de configuración archivados

Los archivos deprecados son los siguientes:

- [influx_nut.json](</configs/(deprecado)influx_nut.json>): Configuración del servicio _NUT_ para almacenar datos en InfluxDB
- [influx_nut2.json](</configs/(deprecado)influx_nut2.json>): 2da versión de la configuración del servicio _NUT_ para almacenar datos en InfluxDB
- [upssched.conf](</configs/(deprecado)upssched.conf>): _UPS scheduler_
- [ups.conf](</configs/(deprecado)ups.conf>): Configuración _UPS_ en el servidor _NUT_
- [upsd.conf](</configs/(deprecado)upsd.conf>): Configuración de red del _daemon_ _NUT_
- [upsd.users](</configs/(deprecado)upsd.users>): Configuración de los usuarios del servidor _NUT_
- [upsmon.conf](</configs/(deprecado)upsmon.conf>): Configuración del monitoreo
- [config](</configs/(deprecado)mail.conf>): Configuración del _script_ de envío de correos
- [influxdb.conf](</configs/(deprecado)influxdb.conf>): Antigua configuración de InfluxDB

## Comandos útiles

Lista de comandos para manipular el servicio _NUT_:

```bash
service nut-server restart
service nut-monitor restart

systemctl status nut-server.service
systemctl status nut-monitor.service

journalctl -xe
```

**[Volver al README](/README.md)**
