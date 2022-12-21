# InfluxDB

InfluxDB es un motor de base de datos código abierto para series de tiempo (en la literatura se usa la sigla en inglés _TSBD_) desarrollado por la compañía [InfluxData](https://www.influxdata.com/), quienes también desarrollan Telegraf.

InfluxDB es uno de los motores que funciona de manera nativa con Grafana y Telegraf

## _PVC_

El _PVC_ para el despliegue de InfluxDB es el siguiente:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
    - kubernetes.io/pvc-protection
  name: netdev-influxdb
  namespace: netdev-rubin-2022
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Gi
  storageClassName: rook-ceph-block
  volumeMode: Filesystem
```

Puede descargar el archivo YAML, hacer clic [aquí](/yamls/05_PVC_influxdb.yaml)

### _Secrets_

Se crearó un recurso de tipo _secret_ para InfluxDB, para almacenar:

- El nomnbre de la base de datos
- El _host_, como nombre o IP v4
- Un usuario
- La contraseña del usuario del punto anterior

El archivo YAML del _secret_ se puede descargar [aquí](/)

## El despliegue

Para descargar el archivo YAML del despliegue de InfluxDB, hacer clic [aquí](/yamls/05_PVC_influxdb.yaml)

Algunas observaciones de interés:

- La imágen que se usa es `docker.io/influxdb:1.8`
- La ruta del punto de montaje, para la persistencia de los datos, es `/var/lib/influxdb` y se mapea con el _PVC_ `netdev-influxdb` creado recientemente

**[Volver al README](/README.md), al [paso 2](/Cap2_02_DespliegueGrafana.md), o ir al [paso 4](/Cap2_04_DespliegueTelegraf.md)**
