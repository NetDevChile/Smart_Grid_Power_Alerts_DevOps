# Resolución de problemas y limpieza

## 1. WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml...

> `WARN[0000] Unable to read /etc/rancher/k3s/k3s.yaml, please start server with --write-kubeconfig-mode to modify kube config permissions error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied`

Este mensaje de error nos indica que no tenemos permisos para acceder a la configuración inicial de `kubectl`, por lo que, probablemente, falta fijar la variable de entorno `KUBECONFIG` para que lea la de nuestro _cluster_. Por ejemplo:

```
export KUBECONFIG=/home/<usuario máquina master>/kube_config_cluster.yml
```

## 2. Para borrar el _cluster_ para comenzar de nuevo

Si se desea borrar el cluster, y comenzar todo de nuevo, usar el siguiente comando:

```
kubectl config delete-cluster <nombre del cluster>
```
