# Puesta en marcha del _cluster_

Para iniciar el _cluster_ desde _master_, se debe crear un archivo de configuración de formato yml. Cree un archivo `cluster.yml` definiendo 3 nodos del _cluster_ a partir de las máquinas _worker_.

> Nota: En kubernetes, un nodo es una máquina virtual o física donde se desplegarán aplicaciones y trabajos del _cluster_.

Basado en [7], y asumiendo las IPs y usuario del inicio de la guía, el archivo de configuración `cluster.yml` del _cluster_ tendía el siguiente contenido:

```yaml
nodes:
  - address: 192.1681.101
    user: usuario1
    role: [controlplane, worker, etcd]
  - address: 192.1681.102
    user: usuario2
    role: [controlplane, worker, etcd]
  - address: 192.1681.103
    user: usuario3
    role: [controlplane, worker, etcd]
```

Se levanta el _cluster_:

```bash
$ rke up --config ./cluster.yml
```

> Nota importante: Para que `kubectl` lea la configuración del nuevo _cluster_ se recomienda fijar la variable de entorno `KUBECONFIG` y así evitar añadir la ruta como parámetro de configuración cada vez que se llame `kubectl`:
>
> ```bash
> $ export KUBECONFIG=$(pwd)/kube_config_cluster.yml
> ```
>
> Esta configuración se perderá si cierra sesión, por lo que se sugiere >anexarlo al archivo `.bashrc` en el _home_ de su usuario en _master_

Corroborar el funcionamiento del cluster:

```bash
$ kubectl get nodes
```

Si todo está bien, ahora tenemos operativo un _cluster_ de tipo Kubernetes de 3 nodos. Ahora podemos instalar Rancher en este _cluster_

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

Una vez finalizada la instalación, como no se cuenta con un servidor de nombres de dominio, modificamos el archivo hosts de nuestra máquina para poder acceder a la interfaz web de Rancher. Antes de eso, necesitamos saber la IP del nodo donde se instaló Rancher. Se puede saber con el siguiente comando:

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

Resolución de problemas y limpieza

# `WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml, please start server with --write-kubeconfig-mode to modify kube config permissions error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied`

Este mensaje de error nos indica que no tenemos permisos para acceder a la configuración inicial de `kubectl`, por lo que, probablemente, falta fijar la variable de entorno `KUBECONFIG` para que lea la de nuestro _cluster_. Por ejemplo:

```
export KUBECONFIG=/home/<usuario máquina master>/kube_config_cluster.yml
```

# Borrar el _cluster_ para comenzar de nuevo

Si se desea borrar el cluster, y comenzar todo de nuevo, usar el siguiente comando:

```
kubectl config delete-cluster <nombre del cluster>
```

**[Volver al README](/README.md), o ir al [paso 4](/04_ConfiguracionRancher.md)**
