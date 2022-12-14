# Documentación Proyecto Rancher

Falta: 1. GitHub, 1.1.- Archivos de Configuración, 1.2.- Scripts si fueron necesarios, 1.3.- Paquetes/Codigos/Propios y/o Publicos (Descargables o Legibles)

## 2.- Guía de instalación Rancher

### Requisitos previos

1. Cuatro (4) máquinas virtuales, según lo recomendado en [1], donde:

   - Tres (3) de ellas serán los nodos del _cluster_ Kubernetes, a las que, para alcances de la presente guía, le llamaremos **_workers_**
   - Una cuarta máquina donde se instalará Kubernetes, y desde donde se orquestará el _cluster_. A esta última Le llamaremos **_master_**

   Nota: Para fines de prueba, podría usarse un solo nodo, ahorrando tiempo y espacio, pero sacrificando la Alta Disponibilidad.

2. Cada máquina virtual debe contar con un Sistema Operativo moderno basado en Linux, un usuario sin privilegios y uno con permisos de administrador. Para la presente guía se usó Ubuntu Server 22.04.1 LTS.
3. Configurar una red de manera tal que permita realizar conexiones TCP/IP entre las máquinas. Esto dependerá del gestor de las máquinas virtuales que se esté usando.
4. Una máquina física o virtual, desde donde el usuario operador usará Rancher. En la guía actual se usó Windows 10, pero podría ser cualquiera con un navegador web moderno.
5. Conexión a Internet, y conocimientos básicos de Linux y Kubernetes.

> Para efectos de la presente guía, asumiremos que las IPs de los _workers_ y los usuarios locales de cada máquina virtual son:
> | IPs | Usuario local |
> |-----------------|----------|
> | `192.168.1.101` | usuario1 |
> | `192.168.1.102` | usuario2 |
> | `192.168.1.103` | usuario3 |

### Pasos para la creación del _cluster_ e instalación de Rancher

#### Preparación básica de las máquinas virtuales, tanto _workers_ como _master_

A continuación, se resumen los pasos básicos para preparar a los _workers_ y _master_ como requisitos previos de Kubernetes. Cada paso se detallará más adelante:

- Instalar servidor SSH en máquinas _workers_
- Generar _SSH key_ en la _master_ y copiar las llaves a las _workers_. Esto permitirá a Kubernetes orquestar los _workers_ desde _master_.
- Instalar el servicio docker en los _workers_, y añadir al usuario local al grupo docker.
- Instalar las herramientas `RKE`, `kubectl` y `helm` en la máquina _master_

Como se comentó previamente, los comandos descritos fueron probados en Ubuntu Server 22.04.1 LTS. Se asume que el usuario actual tiene permisos administrador (sudoer)

##### Instalación de servidor SSH en máquinas _workers_

Basado en [2], instalar el servidor de SSH

```bash
$ sudo apt install openssh-server
```

Para disponibilizar e iniciar inmediatamente el servicio:

```bash
$ sudo systemctl enable ssh
$ sudo systemctl start ssh
```

O bien:

```bash
$ sudo systemctl enable ssh --now
```

> Nota: Puede corroborar que el usuario local pueda efectivamente autenticarse mediante ssh **desde una máquina diferente a la actual**:
>
> ```bash
> $ ssh usuario@<ip de la máquina virtual>
> ```

##### Instalación de `docker` en máquinas _workers_

`docker` es uno de los servicio de contenedores utilizado por Kubernetes, que es exigido por `rke`. Basado en [3] se procede la instalación **en cada máquina _worker_**

En el caso de haber alguna versión antigua de docker, o restos de alguna instalación, eliminar:

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

Se actualiza el administrador de paquetes y se instalan los requisitos:

```bash
$ sudo apt-get update
$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Se repite este comando. Es muy necesario
$ sudo apt-get update
```

Se instala el motor de docker:

```bash
 $ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Se añade el usuario local, que debe ser el mismo que se configurará para acceder mediante ssh, al grupo de Docker. Este paso es de particular importancia, porque permitirá a Kubernetes acceder al servicio Docker de los _workers_

```bash
$ sudo usermod -aG docker <usuario del futuro nodo del cluster>
```

Si el usuario es el mismo con el que está operando, puede usar el siguiente atajo:

```bash
$ sudo usermod -aG docker $USER
```

Para corroborar que su usuario tiene acceso el servicio docker, cierre sesión y autentíquese nuevamente, para luego ejecutar el comando `$ docker ps`

##### Generación SSH key en _master_ y copia de llaves a _workers_

Se genera la _ssh key_ en _master_:

```bash
$ ssh-keygen
```

El comando es interactivo. Presionar `enter` a todas las preguntas, dejando valores por omisión y la llave sin _passphrase_

Una vez finalizado, copiar la llave cuidando de ingresar el nombre de usuario de cada máquina _worker_. Por ejemplo, para las IPs y usuarios que asumimos al inicio de la guía, los comandos para la copia de llaves, respectivamente, serían:

```bash
$ ssh-copy-id usuario1@192.168.1.101
$ ssh-copy-id usuario2@192.168.1.102
$ ssh-copy-id usuario3@192.168.1.103
```

Habiendo realizado este último paso, corrobore que:

- Puede ingresar a las máquinas mediante ssh sin hacer uso de contraseña alguna. Ejemplo: `$ ssh usuario3@192.168.1.103`
- Una vez autenticado en la máquina _worker_, el usuario autenticado tiene acceso al servicio docker ejecutando el comando `$ docker ps`. Si esto último fallara, corrobore la instalación de `docker` y que el usuario pertenezca al grupo `docker` (sección anterior)

#### Instalación de herramientas `RKE`, `kubectl` y `helm` en _master_

##### `RKE`

`RKE` es la herramienta de línea de comando que nos permitirá levantar _clusters_ de tipo Kubernetes. Existen otras distribuciones, tales como `k8s`, `k3s`, `rke2`, etc. Para esta guía usaremos `rke`.

Basado en la documentación oficial [4], se debe descargar en _master_ el binario `rke` para la plataforma deseada en el sitio oficial de RKE, que será la herramienta para levantar el _cluster_. En nuestro caso, la arquitectura es Linux (Intel/AMD)

Al momento de ésta la creación de esta guía, la última versión estable de `rke` era 1.4.1. Para iniciar la descarga podemos usar la herramienta `wget`:

```bash
$ wget https://github.com/rancher/rke/releases/download/v1.4.1/rke_linux-amd64
```

> Nota: Si `wget` no existe en su sistema, ud. puede instalarlo con el administrador de paquetes de Ubuntu `apt`:
>
> ```bash
> $ sudo apt-get install wget
> ```

Para su comodidad, mueva el archivo descargado al directorio `/usr/bin/local`, cambiando su nombre solo a `rke`:

```bash
$ sudo mv rke_linux-amd64 /usr/local/bin/rke
```

Intente ejecutar `rke`. En el caso que obtenga el siguiente error:

```bash
-bash: /usr/local/bin/rke: Permission denied
```

Debe asignar permisos de ejecución `rke`:

```bash
$ sudo chmod +x /usr/local/bin/rke
```

> Nota: `chmod` es el comando que permite modificar permisos de sistema (propios de Linux) de archivos y directorios. `+x` habilita (`+`) la ejecución (`x`) (Nota: 'x' viene de la palabra en inglés _e**x**ecutable_)

##### `kubectl`

`kubectl` es la herramienta de línea de comnados que permite monitorear un _cluster_ Kubernetes, definido en un archivo de configuración. Se entregará más detalles más adelante

Es posible realizar la instalacion de `kubectl` usando el administrador de paquetes del sistema

Basadose en [5], y siempre en la máquina _master_, se prepara `apt`:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# De nuevo. Es necesario
sudo apt-get update
```

Se instala `kubectl`:

```bash
sudo apt-get install -y kubectl
```

##### `helm`

`helm` es un administrador de paquetes que nos permitirá instalar Rancher. Si bien faltan pasos fundamentales para hacer esto último, podemos dejarlo instalado para usarlo más adelante.

En el momento de construcción de esta guía, la última versión estable fue 3.10.2. Siempre estando en _master_, y al igual que `rke` se descarga Helm pre-compilado y se mueve a `/usr/local/bin` [6]:

```bash
$ wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
```

Se descomprime:

```bash
$ tar -zxvf helm-v3.10.2-linux-amd64.tar.gz
```

Se mueve a `/usr/local/bin` para una ejecución simple:

```bash
$ sudo mv linux-amd64/helm /usr/local/bin/
```

> Nota: Puede eliminar el archivo original `helm-v3.10.2-linux-amd64.tar.gz` y el directorio `linux-amd64`

#### Puesta en marcha del _cluster_

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

#### Instalación de Rancher

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

### Resolución de problemas y limpieza

#### `WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml, please start server with --write-kubeconfig-mode to modify kube config permissions error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied`

Este mensaje de error nos indica que no tenemos permisos para acceder a la configuración inicial de `kubectl`, por lo que, probablemente, falta fijar la variable de entorno `KUBECONFIG` para que lea la de nuestro _cluster_. Por ejemplo:

```
export KUBECONFIG=/home/<usuario máquina master>/kube_config_cluster.yml
```

#### Borrar el _cluster_ para comenzar de nuevo

Si se desea borrar el cluster, y comenzar todo de nuevo, usar el siguiente comando:

```
kubectl config delete-cluster <nombre del cluster>
```

### Referencias de la sección

- [1] [_Setting up a High-availability RKE Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/infrastructure-setup/ha-rke1-kubernetes-cluster). Sitio web consultado el 12/12/2022
- [2] [_OpenSSH Server_](https://ubuntu.com/server/docs/service-openssh). Sitio web consultado el 12/12/2022
- [3] [_Install Docker Engine on Ubuntu_](https://docs.docker.com/engine/install/ubuntu/). Sitio web consultado el 12/12/2022
- [4] [_RKE Kubernetes Installation_](https://rancher.com/docs/rke/latest/en/installation/) Sitio web consultado el 12/12/2022
- [5] [_Install and Set Up kubectl on Linux_](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) Sitio web consultado el 12/12/2022
- [6] [_Installing Helm_](https://helm.sh/docs/intro/install/) Sitio web consultado el 12/12/2022
- [7] [_Setting up a High-availability RKE Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher) Sitio web consultado el 12/12/2022
- [8] [_Install/Upgrade Rancher on a Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster) Sitio web consultado el 12/12/2022
