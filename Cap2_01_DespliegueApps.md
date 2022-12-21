# Despliegue de aplicaciones (Grafana, Influxdb y Telegraf)

A continuación se entregan detalles de como desplegar los _software_ [Grafana](https://grafana.com/), [InfluxDB](https://www.influxdata.com/) y [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) en el cluster, con sus correspondientes _Secrets_, _PersistentVolumes_ (_PV_), _PersistentVolumeClaims_ (_PVC_) y _Services_.

1. [Despliegue de Grafana](/Cap2_02_DespliegueGrafana.md)
2. [Despliegue de Influxdb](/Cap2_03_DespliegueInfluxdb.md)
3. [Despliegue de Telegraf](/Cap2_04_DespliegueTelegraf.md)

> Nota: En Kubernetes, un _deployment_ es una declaración que ordena al _cluster_ a desplegar un _software_ contenedorizado. En la práctica, se define un archivo YAML (que veremos en la siguiente sección) que declara meta información del despliegue, entre ella, nombre, volúmenes, variables de entorno, mapeo de puertos, y, probablemente lo más importante, una imágen de un micro servicio (en nuestro caso, una imágen Docker alojada en Docker Hub) a ser desplegada en uno o más _pods_ de nuestro _cluster_. Rancher, por su parte, permite monitorear los despliegues y conectarse a ellos mediante una consola.

**[Volver al README](/README.md), o ir al [paso 2](/Cap2_02_DespliegueGrafana.md)**

---

## Sección complementaria educativa: Uso del formato YAML

Rancher permite declarar despliegues, volúmenes, secretos, mapeos de configuración y muchos otros recursos, mediante formularios web que facilitan el proceso. Sin embargo, una vez que se domina la herramienta es más rápido y eficiente trabajar directamente con el resultado del formulario: una definción en formato YAML.

> Nota: "YAML es un formato de serialización de datos legible por humanos. Es un acrónimo recursivo que significa _YAML Ain't Markup Language_"(\*). Podría decirse que es una alternativa a XML o JSON más comprensible por las personas.

A continuación, y a modo de ejemplo, desplegaremos una imágen de Alpine, un sistema Linux muy liviano orientado a la seguridad. Su definción como _deploymnent_ en formato YAML es el siguiente:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine
spec:
  selector:
    matchLabels:
      app: alpine
  template:
    metadata:
      labels:
        app: alpine
    spec:
      containers:
        - image: alpine:latest
          name: alpine
```

[Descargar](/yamls/01_ejemplo.yaml)

Las entradas clave son:

- _kind_: Indica a Kubernetes que se trata de un despliegue de aplicación. Otras opciones para la entrada _kind_ podrían ser _Secret_, _PersistentVolume_, _DaemonSet_ y otros recursos.
- _image_ (dentro de _containers_) : Indica a Kubernetes la imágen a descargar e inicializar. En nuestro caso, se traduce que imágen de Docker Hub se debe hacer _pull_

El primer botón de la barra superior, como se ve en la imágen a continuación, permite cargar archivos o copiar & pegar texto que respete el formato YAML

![Botones barra superior](/imgs/14_botones_arriba.PNG "Botones barra superior")

En la imágen a continuación, se ve como se puede pegar el texto, asignando un _namespace_ a criterio del usuario

![Imágen pegar YAML](imgs/cap02_01_copyPasteYAML.PNG)

> NOTA: En kubernetes, un _namespace_ es un conjunto abstracto de recursos del _cluster_ que permite mantenerlos en orden

(\*) Basado en el artículo de Wikipedia en español, visitado el 20/12/2022
