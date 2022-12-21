# Resolución de problemas

## Sobre los _PowDevs_

> En construcción. Disculpe

## Sobre Rancher

## 1. WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml...

En caso de recibir el siguiente error durante la manipulación del _cluster_ mediante Rancher o por línea de comando (con la herramienta `kubectl`):

> `WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml, please start server with --write-kubeconfig-mode to modify kube config permissions error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied`

significa que no se cuenta con los permisos para acceder a la configuración inicial de `kubectl`. La razón más probables es que falte fijar la variable de entorno `KUBECONFIG` para que lea la de nuestro _cluster_. Por ejemplo:

```
export KUBECONFIG=/<ruta del sistema oprativo>/kube_config_cluster.yml
```

Donde se debe reemplazar <ruta del sistema oprativo> por la ruta donde se encuentra el archivo de configuración del _cluster_ que se genera al levantarlo. Para efectos de la presenta guía, el archivo se crea al momento de ejecutar el comando `rke up`

## 2. Para borrar el _cluster_ para comenzar de nuevo

Si se desea borrar el cluster, y comenzar todo de nuevo, usar el siguiente comando:

```
kubectl config delete-cluster <nombre del cluster>
```

**[Volver al README](/README.md)**
