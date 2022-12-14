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

**[Volver al README](/README.md), o ir al [paso 4](/04_InstalacionRancher.md)**
