# Creación de un NFS (Network File System)

Los microservicios son un patrón de diseño de software que busca empacar el software en contenedores livianos y desacoplados. Los contenedores no persisten nativamente los datos en su sesión de uso, por lo que es necesario crear unidades de almacenamiento fuera del contenedor que permitan evitar pérdida de datos e información de la ejecución de un contenedor. Esto último corresponde a los volúmenes, que podrían ser, desde partes de un disco local en la máquina que corre el contenedor, a unidades de red o discos en la nube

Para evitar perder los datos en la actual arquitectura de _cluster_ que estamos levantando, se propone almacenar los datos del funcionamiento de las aplicaciones a desplegar (grafana, telegraf e influxDB) en un NFS propio

## ¿Qué es un NFS?

Es básicamente una unidad de red, a la cual todos los dispositivos que puedan acceder puedan almacenar datos. En nuestro caso, queremos que los contenedores almacenen los datos y éstos no se pierdan al momento de re-desplegar el microservicio

## Como crear un NFS

Usaremos una máquina virtual _Ubuntu Server 22.04.1 LTS_ para habilitarla como servidor NFS, basado en la guía [6]

Ingresar los siguientes comandos para instalar el kernel NFS y configurar el servicio. Primero, nos aseguramos que el sistema esté con el repositorio actualizado

```
$ sudo apt update
```

Se instala el kernel NFS

```
$ sudo apt install nfs-kernel-server
```

Se crea el directorio que se desee compartir en red con otras máquinas virtuales y contenedores, y se fijan permisos

```
$ sudo mkdir -p /mnt/nfs_share
$ sudo chown -R nobody:nogroup /mnt/nfs_share/
$ sudo chmod 777 /mnt/nfs_share/
```

Se configura el acceso en su editor favorito (ej: nano, vi, emacs, etc.), permitiendo que sólo las máquinas del rango de IP deseado puedan acceder a la unidad en red de nuestro nuevo NFS:

```
sudo nano /etc/exports
```

Añadir en la última línea del archivo:

```yaml
/mnt/nfs_share 192.168.1.104/24(rw,sync,no_subtree_check)
```

Se compromete la configuración, y se reinicia el servicio:

```
$ sudo exportfs -a
$ sudo systemctl restart nfs-kernel-server
```

Se otorga acceso, mediante configuración del _firewall_, a todos los clientes del rango de IP deseado:

```
$ sudo ufw allow from 192.168.1.0/24 to any port nfs
```

> Nota: Antes de habilitar el _firewall_. Ejecute el siguiente comando para no perder acceso mediante el servicio SSH:
>
> ```
> sudo ufw allow ssh
> ```

Se habilita el _firewall_ y se chequean las reglas

```
sudo ufw enable
sudo ufw status
```

**[Volver al README](/README.md), al [paso 1](/Anexo01_01_PreparacionMaquinasVirtuales.md), o ir al [paso 3](/Anexo01_03_CreacionCluster.md)**
