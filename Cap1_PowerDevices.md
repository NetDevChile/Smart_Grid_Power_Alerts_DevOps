# Conceptos

## Alta Disponibilidad (AD, o _HA_ en inglés)

La alta disponibilidad, o "AD", se define como la capacidad que tiene un sistema para asegurar la continuidad de los servicios, incluso en situaciones donde ocurran deficiencias como inconvenientes a nivel de hardware, software, cortes de energía y demás

Cabe destacar también que la alta disponibilidad implica tener varias réplicas de cada uno de los servicios trabajando de forma simultánea, con el objetivo de que todas puedan recibir peticiones. En el caso de que alguna de las réplicas deje de estar disponible, el tráfico deberá llegar a las restantes, reduciendo o eliminando fallos.

La alta disponibilidad incluye una serie de características y propiedades que permiten su funcionamiento, como, por ejemplo, que funciona como un método de respuesta a errores para la infraestructura tecnológica, por lo que, normalmente, requiere configuraciones especializadas y un software.

En nuestro caso, el cliente logra AD con un _cluster_ gracias al orquestador de micro servicios **Kubernetes**

> Ref: Blog [keepcoding.io](https://keepcoding.io/blog/que-es-la-alta-disponibilidad-high-avialability/)

## PowDevs

Son equipos electrónicos, eléctricos, electromecánicos de diversos fabricantes y tipos (a lo que en la literatura se le llama _multivendor_) desde los cuales se obtiene, mediante protocolos de comunicación digitales, diversas métricas, como de potencia, parámetros eléctricos, frecuencias, etc. que permiten hacer diversos tipos de análisis (como por ejemplo, análisis espectral eléctrico), monitoreo y configuración de alarmas

Generalizando, un _PowDev_ es cualquier dispositivo que genere, almacene, consuma o preocese potencia eléctrica

Ejemplos de PowDev son: generadores, UPS, electromotores, etc.

# Esquema general del proyecto

En la imágen a continuación, se encuentra el esquema general del proyecto _Smart Grid_

![esquema_general](imgs/cap01_01_smart_grid_system.PNG)

**[Volver al README](/README.md), o ir al [capítulo 2: Despliegue de las aplicaciones](/Cap2_01_DespliegueApps.md)**
