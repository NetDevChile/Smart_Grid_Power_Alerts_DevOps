# Influxdb

Influx es una base de datos para series de tiempo. Lo primero que el contenedor de la aplicación necesita es declarar algunas variables sensibles llamadas secretos (desde ahora en adelante _secrets_)

> Nota: En Kubernetes, un _secret_ es un objeto que contiene datos sensibles de configuración, tales como contraseñas, _tokens_, llaves, etc. Al usarlos, evitas poner información sensible en el código o en la especificación de la imágen del contenedor

Los _secrets_ se pueden definir mediante la interfaz de Rancher o por línea de comandos.

## Definición _secrets_ de Influxdb mediante línea de comandos

Ingresar el siguiente comando en _master_:

```
kubectl create secret generic influxdb-creds \
  --from-literal=INFLUXDB_DATABASE=localDB \
  --from-literal=INFLUXDB_USERNAME=admin \
  --from-literal=INFLUXDB_PASSWORD=admin \
  --from-literal=INFLUXDB_HOST=influxdb
```

## Creación de los _PersistentVolumes_ (_PV_) y _PersistentVolumeClaims_ (_PVC_) para Influxdb

Hacer clic en _Create_ y especificar los datos como en la imágen a continuación

![Creación volumen](/imgs/07_volumen-influx.PNG "Creación volumen")

![Creación PVC](/imgs/09_pvc-influx.PNG "Creación PVC")

## Despliegue de Influxdb

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: default
  annotations:
  creationTimestamp: null
  generation: 1
  labels:
    app: influxdb
  name: influxdb
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: influxdb
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: influxdb
    spec:
      containers:
        - envFrom:
            - secretRef:
                name: influxdb-creds
          image: docker.io/influxdb:1.6.4
          imagePullPolicy: IfNotPresent
          name: influxdb
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          volumeMounts:
            - mountPath: /var/lib/influxdb
              name: var-lib-influxdb
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
        - name: var-lib-influxdb
          persistentVolumeClaim:
            claimName: pvc-influx
```

## Exposición de influxdb como servicio

```
kubectl expose deployment influxdb --port=8086 --target-port=8086 --protocol=TCP --type=ClusterIP
```

# Telegraf

## Exposición del telegraf como servicio

```
kubectl expose deployment telegraf --port=8125 --target-port=8125 --protocol=UDP --type=NodePort
```

# Grafana

## Secrets de grafana

```
kubectl create secret generic grafana-creds \
  --from-literal=GF_SECURITY_ADMIN_USER=admin \
  --from-literal=GF_SECURITY_ADMIN_PASSWORD=admin
```

## Exposición de grafana como servicio

```
kubectl expose deployment grafana --type=LoadBalancer --port=3000 --target-port=3000 --protocol=TCP
```

**[Volver al README](/README.md)**
