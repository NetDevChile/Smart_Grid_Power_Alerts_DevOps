# Despliegue de aplicaciones (Grafana, Influxdb y Telegraf)

A continuación se entrega detalles de como desplegar los software Grafana, Influxdb y Telegraf en el cluster, con sus correspondientes _Secrets_, _PersistentVolumes_ (_PV_), _PersistentVolumeClaims_ (_PVC_) y _Services_

# Grafana

Se procederá a explicar cómo desplegar Grafana en el _cluster_. Ésta sección está basada en la documentación oficial de Grafana [10]

## Persistencia (_PV_ y _PVC_)

Se crea un _PV_ y un _PVC_ que permita persistir los datos del _pod_ de Grafana.

### _PV_

Hacer clic en la sección _Storage_ en el menu de la izquierda en la vista del _cluster_ "local". Luego en _PersistentVolumes_ hacer clic en el botón _"Create"_.

Aparecerá un formulario. En la lista "_Volume Plugin_" escoger la opción _"NFS Share"_ y en "_Capacity_" ingresar un tamaño de _gigabytes_ de capacidad de almacenamiento a vuestro criterio, donde, aproximadamente, 2 GB debiese ser suficiente para la mayoría de los escenarios

Usaremos una ruta exclusiva para Grafana en nuestro servidor NFS creado anteriormente. Ésta es `/mnt/nfs_share/grafana`. Además, debemos indicar la IP del servidor NFS. En el caso de la presente guía es `192.168.1.104`. Ingrese tambien una descripción y nombre de volumen que sea corto, explícito, y fácil de recordar. Por ejemplo, "volumen_grafana" o "pv_grafana".

Posterior a la creación, la vista al seleccionar y ver el detalle del volumen es como la figura a continuación:

![PV de Grafana](/imgs/10_pv_grafana.PNG "PV de Grafana")

### _PVC_

Debemos crear un _PVC_ que será el que se asignará al despligue de Grafana en su archivo YAML, y que se vinculará con su _PV_.

Hacer clic en _PersistentVolumeClaims_, también en la sección _Storage_, y luego en _"Create"_. Ingrese _namespace_, nombre y descripción a vuestro criterio. Finalmente, seleccione _"Use an existing Persistent Volume"_, y el _PV_ recientemente creado en la lista titulada "_Persistent Volume_" a mano derecha del formulario

La siguiente imágen es como debiese quedar luego de que el _PVC_ ha sido ingresado:

![PVC de Grafana](/imgs/11_pvc_grafana.PNG "PVC de Grafana")

```
kubectl expose deployment grafana --type=LoadBalancer --port=3000 --target-port=3000 --protocol=TCP
```

### El _deployment_

Hacer clic en _Workload_ en el menu de la izquierda, y luego en el botón _Create_. A continuación, en _Deployment_. Rancher nos ofrecerá completar un formulario, pero es más eficiente hacer clic en el botón _Edit as YAML_ y copiar & pegar el siguiente código que contiene la definición de Grafana, y su conexión con el _PVC_ creado en la sub sección anterior

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: grafana
  name: grafana
  namespace: default
spec:
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      securityContext:
        fsGroup: 472
        supplementalGroups:
          - 0
      containers:
        - name: grafana
          image: grafana/grafana:9.1.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
              name: http-grafana
              protocol: TCP
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /robots.txt
              port: 3000
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 30
            successThreshold: 1
            timeoutSeconds: 2
          livenessProbe:
            failureThreshold: 3
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            tcpSocket:
              port: 3000
            timeoutSeconds: 1
          resources:
            requests:
              cpu: 250m
              memory: 750Mi
          volumeMounts:
            - mountPath: /var/lib/grafana
              name: grafana-pv
      volumes:
        - name: grafana-pv
          persistentVolumeClaim:
            claimName: pvc-grafana
```

Finalmente, hacer clic en _Create_ y esperar un minuto a que la plataforma despliegue Grafana en nuestro _cluster_

### La creación del _service_

Para poder acceder a Grafana, se necesita crear un _service_ que habilite un puerto que permita acceder a la interfaz de usuario de Grafana. Para ello, hacer clic en _Service Discovery_ y luego en el botón _Create_. A continuación, escoger la opción _Load Balancer_

Aparecerá un formulario, pero también nos da la opción de crear la configuración del servicio en formato _YAML_ al hacer clic en el botón, en la parte inferior, llamado _Edit as YAML_. Luego, podemos copiar & pegar la configuración que está a continuación:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: default
spec:
  ports:
    - port: 3000
      protocol: TCP
      targetPort: http-grafana
  selector:
    app: grafana
  sessionAffinity: None
  type: LoadBalancer
```

Hacer clic en _Create_. Como no contamos con un balanceador de carga configurado, el estado del servicio quedará en _Pending_. Sin embargo, podemos hacer uso de él sin problema.

Al hacer clic en el sevicio recién creado, se puede ver el nodo en que el servicio fue desplegado en el _cluster_ como en la siguient figura:

![PVC de Grafana](/imgs/12_servicio_grafana.PNG "PVC de Grafana")

Es importante tomar nota de la IP del nodo del despliegue, y del puerto que se indica en la columna _Node Port_ al hacer clic en la pestaña _Ports_ de la tabla informativa, ya que con estos podremos ingresar a la interfaz web de usuario de Grafana

### Prueba

En un navegador web, ingresar en la dirección la IP del nodo del despliegue, incluyendo el puerto de la sub sección anterior. Si todo marcha bien, debiese cargar la página de autenticación de Grafana, como en la siguiente imágen, donde el usuario y contraseña son `admin` para ambos campos. Luego de autenticarse, Grafana le pedira a ud. que ingrese una nueva contraseña que dejamos a vuestro criterio

![PVC de Grafana](/imgs/13_grafana_UI.PNG "PVC de Grafana")

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

**[Volver al README](/README.md)**
