# Capturas de pantalla del sistema en ambiente productivo

## Vistas previas y diagramas _"as-built"_

### Rancher

La siguiente vista previa evidencia el despliegue y funcionamiento de plataforma Rancher en servidor de desarrollo RKE1, superando la arquitectura impuesta por el cliente. El desarrollo fue realizado con la finalidad de no modificar la arquitectura de recursos que tienen en su nuevo sistema de alta disponibilidad, el cual es un servidor de desarrollo de Rubin llamado Rancher/RKE1, tal fue solicitado vía correo electrónico. Los recursos de hardware entregados para ello fueron correctamente utilizados.

Imágen del _dashboard_ en funcionamiento dentro de Rancher/RKE1:

![Preview](imgs/16_preview_rancher.PNG)

Arquitectura _"as-built"_ de lo recientemente descrito:

![final_asbuild](imgs/17_asbuilt_rancher.PNG)

### Máq. virtual VSphere/VMware

Además, se cuenta con la instalación del sistema en su máquina virtual VSphere/VMware, fue realizada durante la instalación Rancher. Se utilizó la imagen VMware que desarrollada por NetDev para ustedes y que actualmente se encuentre funcionando en su servidor de producción de Rubin, con especial consideración respecto a la seguridad y la adaptabilidad del desarrollo.

Imágen del _dashboard_ en funcionamiento dentro de VSphere/VMware, junto a su respectiva arquitectura interna _"as-built"_:

![Preview](imgs/18_preview_vmware.PNG)
![asbuild](imgs/19_asbuilt_vmware.PNG)

### Micro-sistema de emergencia y pruebas de funcionamiento

![Preview](imgs/20_preview_alertas.PNG)
![asbuild](imgs/21_asbuilt_alertas.PNG)

## Imágenes de los recursos del _cluster_ en Rancher

### _Secrets_

![Secrets](/imgs/funcionando_01_secrets.jpeg)

### _PVCs_

![PVC](/imgs/funcionando_02_pvcs.jpeg)

### _ConfigMaps_

![CM](/imgs/funcionando_03_cmaps.jpeg)

### _Services_

![Services](/imgs/funcionando_04_services.jpeg)

### _Pods_

![Pods](/imgs/funcionando_05_pods.jpeg)

**[Volver al README](/README.md)**
