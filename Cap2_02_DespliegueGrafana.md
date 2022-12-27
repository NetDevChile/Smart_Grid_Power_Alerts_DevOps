# Grafana

Se procederá a detallar cómo desplegar Grafana [10] en el _cluster_.

## Persistencia (_PV_ y _PVC_)

Con el _StorageClass_ creado en la sección anterior de la guía, ahora se debe crear un _PersistentVolumeClaim_ que permite indicarle al orquestador del _cluster_ las necesidades de espacio, que clase de almacenamiento corresponde y para asociarlo, posteriormente, a un despliegue.

### _PVC_

El _PVC_ para el despligue de Grafana es el siguiente:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
    - kubernetes.io/pvc-protection
  name: netdev-grafana-pvc
  namespace: netdev-rubin-2022
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: rook-ceph-block
  volumeMode: Filesystem
  volumeName: pvc-2f7a2eb2-d9ce-4f91-bef8-7b96165f7323
```

Puede descargar la declaración en un archivo YAML [aquí](/yamls/04_PVC_grafana.yaml).

### _Secrets_

Se creó un recurso de tipo _secret_ para almacenar:

- Usuario administrador
- Contraseña del usuario administrador

de Grafana. El archivo YAML del _secret_ se puede descargar [aquí](/yamls/10_secret_grafana.yaml)

### _ConfigMap_

Se creó un recurso de tipo _ConfigMap_ para el archivo de configuración inicial de Grafana `grafana.ini`. Se puede descargar [aquí](yamls/12_cm-grafana.yaml)

### El _deployment_

El despliegue de Grafana se encuentra en archivo YAML que puede descargar [aquí](/yamls/03_grafana.yaml).

Es posible ver en su estructura:

- Nombre y _namespace_: `grafana` y `netdev-rubin-2022`. Este último debe estar creado previamente.
- La imágen del contenedor del repositorio oficial de Docker Hub: `grafana/grafana:9.3.2`.
- El punto de montaje `/var/lib/grafana` asociado al _PVC_ `netdev-grafana-pvc`. Es en aquella ruta que Grafana, por omisión, crea una base de datos en un fichero para persistir los datos.

### La creación del _service_

Para poder acceder, mediante un navegador web, a la interfaz de usuario de Grafana, se debe desplegar un servicio que indique al _cluster_ que habrá un acceso al _pod_ del despligue en un puerto específico.

El archivo YAML del servicio es el siguiente:

```yaml
apiVersion: v1
kind: Service
  name: nd-grafana
  namespace: netdev-rubin-2022
spec:
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 31463
    port: 3000
    protocol: TCP
    targetPort: http-grafana
  selector:
    app: grafana
  sessionAffinity: None
  type: LoadBalancer
```

Puede descargar el archivo YAML [aquí](/yamls/08_servicioGrafana.yaml).

### Prueba

En un navegador web, ingresar en la dirección la IP del _pod_ del despliegue, incluyendo el puerto de la sub sección anterior. Si todo marcha bien, debiese cargar la página de autenticación de Grafana, como en la siguiente imágen, donde el usuario y contraseña son `admin` para ambos campos. Luego de autenticarse, Grafana le pedira a ud. que ingrese una nueva contraseña que dejamos a vuestro criterio.

![PVC de Grafana](/imgs/13_grafana_UI.PNG "PVC de Grafana")

**[Volver al README](/README.md), al [paso 1](/Cap2_01_DespliegueApps.md), o ir al [paso 3](/Cap2_03_DespliegueInfluxdb.md)**

## Sección complementaria

### Usando un NFS para persistir

En caso de haber usado un NFS como fue el caso del laboratorio en NetDev, se debe hacer clic en la sección _Storage_ en el menu de la izquierda en la vista del _cluster_ "local". Luego en _PersistentVolumes_ hacer clic en el botón _"Create"_.

Aparecerá un formulario. En la lista "_Volume Plugin_" escoger la opción _"NFS Share"_ y en "_Capacity_" ingresar un tamaño de _gigabytes_ de capacidad de almacenamiento a vuestro criterio, donde, aproximadamente, 2 GB debiese ser suficiente para la mayoría de los escenarios

Usaremos una ruta exclusiva para Grafana en nuestro servidor NFS creado anteriormente. Ésta es `/mnt/nfs_share/grafana`. Además, debemos indicar la IP del servidor NFS. En el caso de la presente guía es `192.168.1.104`. Ingrese tambien una descripción y nombre de volumen que sea corto, explícito, y fácil de recordar. Por ejemplo, "volumen_grafana" o "pv_grafana".

Posterior a la creación, la vista al seleccionar y ver el detalle del volumen es como la figura a continuación:

![PV de Grafana](/imgs/10_pv_grafana.PNG "PV de Grafana")

Para el caso del _PVC_, debemos crear uno que se asignara al despligue de Grafana en su archivo YAML, y que se vinculará con su _PV_ que le corresponde.

Hacer clic en _PersistentVolumeClaims_, también en la sección _Storage_, y luego en _"Create"_. Ingrese _namespace_, nombre y descripción a vuestro criterio. Finalmente, seleccione _"Use an existing Persistent Volume"_, y el _PV_ recientemente creado en la lista titulada "_Persistent Volume_" a mano derecha del formulario

La siguiente imágen es como debiese quedar luego de que el _PVC_ ha sido ingresado:

![PVC de Grafana](/imgs/11_pvc_grafana.PNG "PVC de Grafana")

Luego, se hace el despliegue del _software_. Hacer clic en _Workload_ en el menu de la izquierda, y luego en el botón _Create_. A continuación, en _Deployment_. Rancher nos ofrecerá completar un formulario, pero es más eficiente hacer clic en el botón _Edit as YAML_ y copiar & pegar el siguiente código que contiene la definición de Grafana, y su conexión con el _PVC_ creado en la sub sección anterior

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

Otra manera alternativa del último paso, es hacerlo mediante la herramienta `kubectl`:

```
kubectl expose deployment grafana --type=LoadBalancer --port=3000 --target-port=3000 --protocol=TCP
```
