# Creación y preparación del _cluster_

## Esquema general de la arquitectura

Se propone la creación de cinco (5) máquinas virtuales, donde se requiere:

- Tres (3) de ellas, basandose en lo recomendado en [1], serán los nodos del _cluster_ Kubernetes, a las que, para alcances de la presente guía, le llamaremos **_workers_**
- Una cuarta máquina donde se instalará Kubernetes. Es de donde se orquestará el _cluster_. A esta última Le llamaremos **_master_**
  > Nota: Para fines de prueba, podría usarse un solo nodo, ahorrando tiempo y espacio, pero sacrificando la Alta Disponibilidad.
- Una quinta máquina que actuará como NFS (_Network File System_) basado en [Ubuntu](https://ubuntu.com/)
- Cada máquina virtual debe contar con un Sistema Operativo moderno basado en Linux, un usuario sin privilegios y uno con permisos de administrador. Para la presente guía se usó **_Ubuntu Server 22.04.1 LTS_**.
- Una configuración de red que permita realizar conexiones TCP/IP entre las máquinas. Esto dependerá del gestor de las máquinas virtuales que se esté usando (como por ejemplo VWare, VirtualBox, Hypervisor, etc.).
- Una máquina física o virtual, desde donde el usuario operador usará Rancher. En la guía actual se usó Windows 10, pero podría ser cualquiera con un navegador web moderno.
- Conexión a Internet, y conocimientos básicos de Linux y Kubernetes.

> Para efectos de la presente guía, asumiremos que las IPs de los _workers_ y los usuarios locales de cada máquina virtual son:
> | IPs | Usuario local | Rol |
> |-----------------|----------|----------|
> | `192.168.1.100` | usuario | _master_ |
> | `192.168.1.101` | usuario1 | _worker_ |
> | `192.168.1.102` | usuario2 | _worker_ |
> | `192.168.1.103` | usuario3 | _worker_ |
> | `192.168.1.104` | usuario | NFS |

Se propone un ambiente [Kubernetes](https://kubernetes.io/es/), usando la distribución [RKE](https://www.rancher.com/products/rke), en máquinas virtuales Linux basadas en [Ubuntu Server](https://ubuntu.com/download/server)

A continuación, se resumen los pasos básicos para preparar a los _workers_ y _master_ como requisitos previos de Kubernetes. Cada paso se detallará más adelante:

1. [Instalar servidor SSH en máquinas _workers_.](#instalación-de-servidor-ssh-en-máquinas-workers)
2. [Generar _SSH key_ en la _master_ y copiar las llaves a las _workers_.](#generación-ssh-key-en-master-y-copia-de-llaves-a-workers)
3. [Instalar el servicio docker en los _workers_, y añadir al usuario local al grupo docker.](#instalación-de-docker-en-máquinas-workers)
4. [Instalar las herramientas `RKE`, `kubectl` y `helm` en la máquina _master_](#instalación-de-herramientas-rke-kubectl-y-helm-en-master)

Los pasos 1 y 2 permitirán a Kubernetes orquestar los _workers_ desde _master_, y el 3 desplegar contenedores.

Como se comentó previamente, los comandos descritos fueron probados en _Ubuntu Server 22.04.1 LTS_. Se asume que el usuario actual tiene permisos administrador (_sudoer_).

## Instalación de servidor SSH en máquinas _workers_

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

### _Script_ de la sección

El _script_ para automatizar esta sección se [encuentra aquí](/scripts/instalacion_openssh.sh). Contiene una sección para instalar, habilitar y configurar el _firewall_ mediante la herramienta `ufw`.

## Instalación de `docker` en máquinas _workers_

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

### _Script_ de la sección

El _script_ para automatizar esta sección se [encuentra aquí](/scripts/instalacion_docker.sh).

## Generación SSH key en _master_ y copia de llaves a _workers_

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

# Instalación de herramientas `RKE`, `kubectl` y `helm` en _master_

## `RKE`

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

## `kubectl`

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

## `helm`

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

### _Script_ de la sección

El _script_ para automatizar esta sección se [encuentra aquí](/scripts/instalacion_herramientas_CLI.sh).

**[Volver al README](/README.md), o ir al [paso 2](/Anexo01_02_CreacionNFS.md)**
