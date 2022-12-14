# Rancher + Telegraf + Grafana + InfluxDB

Este repositorio contiene una serie de guías para desplegar [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/), [Grafana](https://grafana.com/), [InfluxDB](https://www.influxdata.com/) y un [NFS](https://es.wikipedia.org/wiki/Network_File_System) basado en [Ubuntu](https://ubuntu.com/), en un ambiente [Kubernetes](https://kubernetes.io/es/), usando la distribución [RKE](https://www.rancher.com/products/rke), en máquinas virtuales Linux basadas en [Ubuntu Server](https://ubuntu.com/download/server)

## Esquema general de la arquitectura

![Esquema general](/imgs/01_esquema_general.PNG "Esquema general")

Se propone la creación de cinco (5) máquinas virtuales, donde se requiere:

- Tres (3) de ellas, basandose en lo recomendado en [1], serán los nodos del _cluster_ Kubernetes, a las que, para alcances de la presente guía, le llamaremos **_workers_**
- Una cuarta máquina donde se instalará Kubernetes, y desde donde se orquestará el _cluster_. A esta última Le llamaremos **_master_**
  > Nota: Para fines de prueba, podría usarse un solo nodo, ahorrando tiempo y espacio, pero sacrificando la Alta Disponibilidad.
- Una quinta máquina que actuará como NFS (Network File System)
- Cada máquina virtual debe contar con un Sistema Operativo moderno basado en Linux, un usuario sin privilegios y uno con permisos de administrador. Para la presente guía se usó Ubuntu Server 22.04.1 LTS.
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

## Secciones de la guía:

1. [Creación y preparación de las máquinas virtuales](/01_PreparacionMaquinasVirtuales.md)
2. [Creación del _NFS_](/02_CreacionNFS.md)
3. [Creación del _cluster_](/03_CreacionCluster.md)
4. [Instalación de Rancher](/04_ConfiguracionRancher.md)
5. [Configuración de Rancher](/05_InstalacionRancher.md)
6. [Resolución de problemas](/99_ResolucionProblemas.md)

## Referencias utilizadas a lo largo de la guía:

- [1] [_Setting up a High-availability RKE Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/infrastructure-setup/ha-rke1-kubernetes-cluster). Sitio web consultado el 12/12/2022
- [2] [_OpenSSH Server_](https://ubuntu.com/server/docs/service-openssh). Sitio web consultado el 12/12/2022
- [3] [_Install Docker Engine on Ubuntu_](https://docs.docker.com/engine/install/ubuntu/). Sitio web consultado el 12/12/2022
- [4] [_RKE Kubernetes Installation_](https://rancher.com/docs/rke/latest/en/installation/) Sitio web consultado el 12/12/2022
- [5] [_Install and Set Up kubectl on Linux_](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) Sitio web consultado el 12/12/2022
- [6] [_How to Install and Configure an NFS Server on Ubuntu 22.04_](https://linuxhint.com/install-and-configure-nfs-server-ubuntu-22-04/) Sitio web consultado el 14/12/2022
- [7] [_Installing Helm_](https://helm.sh/docs/intro/install/) Sitio web consultado el 12/12/2022
- [8] [_Setting up a High-availability RKE Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher) Sitio web consultado el 12/12/2022
- [9] [_Install/Upgrade Rancher on a Kubernetes Cluster_](https://docs.ranchermanager.rancher.io/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster) Sitio web consultado el 12/12/2022
