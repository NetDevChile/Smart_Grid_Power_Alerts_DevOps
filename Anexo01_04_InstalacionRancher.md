# Instalación de Rancher

Basado en [8], se configura Helm para preparar e instalar la versión estable de Rancher en _master_:

```bash
$ helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
```

Se crea un `namespace` de nombre `cattle-system`, exigido por Rancher:

```bash
$ kubectl create namespace cattle-system
```

En ésta guía se asume que se usarán los certificados generados por el propio Rancher, por lo que se deben ejecutar los siguiente comandos, siempre en _master_:

```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

$ helm repo add jetstack https://charts.jetstack.io

$ helm repo update

$ helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1
```

Corroborar que hay pods de gestión de certificados:

```
$ kubectl get pods --namespace cert-manager
```

> Nota: En Kubernetes, un _pod_ es una abstracción que puede interpretarse como una aplicación mínima desplegada en un nodo dentro del _cluster_. Es el servicio de Kubernetes quien determina el nodo en que se despliega un _pod_ al momento de su instalación

Se procede a instalar Rancher:

```
$ helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set bootstrapPassword=admin
```

Espere pacientemente. Puede revisar el avance el _job_ con el siguiente comando:

```
$ kubectl -n cattle-system rollout status deploy/rancher
```

Una vez finalizada la instalación, al no contar con un servidor de nombres de dominio, modificamos el archivo _hosts_ de nuestra máquina para poder acceder a la interfaz web de Rancher. Antes de eso, necesitamos saber la IP del nodo donde se instaló Rancher. Se puede saber con el siguiente comando:

```
$ kubectl get pods -o wide -n cattle-system
```

En el caso de Windows, el archivo _hosts_ se encuentra en `C:\Windows\System32\drivers\etc`, en cambio, en sistemas basados en Linux, se encuentra en `/etc/hosts`. En ambos tipos de sistemas se necesita que el editor de texto sea ejecutado con permisos de administración

Al archivo `hosts`, añadir la siguiente línea:

```
<IP del nodo donde se instaló Ranchaer> rancher.my.org
```

Por ejemplo:

```
192.168.1.101 rancher.my.org
```

Guardar y abrir la url `https://rancher.my.org/dashboard/?setup=admin` en cualquier navegador moderno

**[Volver al README](/README.md), al [paso 3](/Anexo01_03_CreacionCluster.md), o ir al [paso 5](/Anexo01_05_ConfiguracionRancher.md)**
