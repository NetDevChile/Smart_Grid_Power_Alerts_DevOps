# Configuración de Rancher

En esa sección de la guía, realizaremos las siguientes configuraciones:

1. Creación de un volumen persistente (desde ahora en adelante _PersistentVolume_) conectado al NFS
2. Creación de una petición de volumen persistente (desde ahora en adelante _PersistentVolumeClaim_)

## Creación de _PersistentVolume_

Ingresar a Rancher, y seleccionar el _cluster_ local

![Cluster local](/imgs/02_bienvenida_rancher.PNG "Cluster local")

Se mostrará el detalle del _cluster_. A mano izquierda, seleccionar la sección _Storage_

![Cluster local](/imgs/03_detalle_cluster.PNG "Cluster local")

Seleccionar _PersistentVolume_

![Persistent Volumes](/imgs/04_persistentVolumes.PNG "Persistent Volumes")

Añadir un nuevo _PersistentVolume_

![Nuevo persistent Volumes](/imgs/05_agregaPersistentVolume.PNG "Nuevo persistent Volumes")

Ingresar un nombre y descripción. Seleccionar _NFS Share_ como _plugin_ de volumen y la capacidad que dependerá del tamaño de nuestro NFS. Para fines de la guía nuestro NFS tiene aproximadamente 15 GB de almacenamiento. Luego, ingrese los datos correspondientes a nuestro servidor NFS: en _path_ `/mnt/nfs_share`, en _server_ `192.168.1.105`

![Nuevo persistent Volumes con datos](/imgs/06_agregaDatosPersistenVolume.PNG "Nuevo persistent Volumes con datos")

**[Volver al README](/README.md), o ir al [paso 5](/05_InstalacionRancher.md)**
