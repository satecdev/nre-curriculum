# Troubleshooting

## Punto de partida

Los pilares en los que se los procedimientos de *troubleshooting* en una red en producción de servicios verificados son dos:
* La verificación de conectividades.
* La comparación de un servicio o equipo que funciona con el defectuoso.

A partir de la información obtenida el ingeniero de red debe correlarla y obtener conclusiones.

La verificación de conectividades depende de los entornos puede ser tediosa. Cuando se notifica un fallo de comunicación del tipo *"No llego al servidor X desde la oficina Y"* en un servicio normalmente: 
* Comprobaciones locales de conectividad:
    * Conectividad del router PE con el router CE.
    * Conectividad del router PE con el *endpoint* de ese site (si no está detrás de un firewall).
    * Conectividad desde el CE con el *endpoint* si es posible.
* Comprobaciones entre los dispositivos de red:
    * Conectividad PE-PE
    * Conectividad CE local con PE remoto
    * Etc.. 
Estas comprobaciones en ocasiones es necesario realizarlas con diferentes tamaños de paquetes.

Aparte de estas verificaciones se suelen realizar otras comprobaciones estándar, tales como:
* ¿Están los prefijos en las respectivas tablas de rutas?
* ¿Se anuncian los prefijos al core?
* ¿Se anuncian los prefijos del PE al CE?

Para problemas simples la correlación de la información anterior suele proporcionar el origen del problema.

En problemas complejos pueden ser necesarias más comprobaciones.

## Automatización de comprobaciones

El objeto de la automazión de las comprobaciones es doble:
* La obtención de información relevante para su análisis y presentación en un formato visual sencillo.
* En base a la información obtenida analizarla y presentar una posible causa.

Si una red está correctamente inventariada existen sistemas desde los que se puede obtener la información necearia para realizar todas las pruebas:
* En qué PEs están conectadas las sedes de cliente.
* Cuáles son los parámetros de configuración de un servicio:
    * si es un L3VPN los rd y rt.
    * si es un servicio de internet cuáles son los prefijos de cliente.
    * Etc..
* Etc...  

A partir de esa información se puede generar una matriz de pruebas que realice un sistema automático.

El siguiente paso sería dotar de mayor inteligencia a ese sistema para que se comporte como un *sistema experto*

# Laboratorio de troubleshooting.

## Preparación del laboratorio

Todos los problemas que se van a reportar son de comunicación entre los sites 1 y 4 en la L3VPN. 
En el laboratorio se asume que la herramienta de automatización ha obtenido del inventario todos los datos necesarios para realizar las pruebas.

Se realizarán las siguientes pruebas de conectividad:
* **Conectividad Local**:
  * ping de `ios1` a CE local
  * ping de `ios4` a CE local
  * ping de `ios1` a loopback CE local
  * ping de `ios4` a loopback CE local
* **Conectividad en el core de red**:
  * ping de `ios1` a `ios4` en la L3VPN.
  * ping de `ios1` a `ios2` en la L3VPN.
  * ping de `ios4` a `ios1` en la L3VPN.
  * ping de `ios4` a `ios2` en la L3VPN.
  * ping de `ios2` a `ios1` en la L3VPN.
  * ping de `ios2` a `ios4` en la L3VPN
  * ping entre las loopbacks de LSPs de `ios1` a `ios4` en tabla global.
  * ping entre las loopbacks de LSPs de `ios4` a `ios1` en tabla global.
  * traceroute entre las loopbacks de LSPs de `ios1` a `ios4` en tabla global.
  * traceroute entre las loopbacks de LSPs de `ios4` a `ios1` en tabla global.
  * traceroute de `ios1` a `ios4` en la L3VPN.
  * traceroute de `ios1` a `ios2` en la L3VPN.
  * traceroute de `ios2` a `ios1` en la L3VPN.
  * traceroute de `ios2` a `ios4` en la L3VPN.
  * traceroute de `ios4` a `ios1` en la L3VPN
  * traceroute de `ios4` a `ios2` en la L3VPN
* **Conectividad contra CEs pasando por la red**:
  * ping de `ios1` a CE de site4
  * ping de `ios1` a CE de site2
  * ping de `ios4` a CE de site1
  * ping de `ios4` a CE de site2
  * ping de `ios2` a CE de site1
  * ping de `ios2` a CE de site4
  * traceroute de `ios1` a CE de site4
  * traceroute de `ios1` a CE de site2
  * traceroute de `ios4` a CE de site1
  * traceroute de `ios4` a CE de site2
  * traceroute de `ios2` a CE de site1
  * traceroute de `ios2` a CE de site4
Se realizarán también las siguientes comprobaciones de routing:
  * Verificación de estado de sesión BGP `ios1` - CE
  * Verificación de estado de sesión BGP `ios4` - CE
  * Verificación de prefijo 30.0.0.1 en `ios1`
  * Verificación de prefijo 30.0.0.4 en `ios1`
  * Verificación de prefijo 30.0.0.1 en `ios4`
  * Verificación de prefijo 30.0.0.4 en `ios4`
  * Verificación de prefijo 30.0.0.1 en `ios2`
  * Verificación de prefijo 30.0.0.4 en `ios2`

Si agrupamos las pruebas por equipos tendríamos:

* `ios1`
```
!-- conectividad local enlace en L3VPN
ping vrf L3VPN 30.1.1.100 repeat 2 timeout 1
!-- conectividad local loopback CE en L3VPN
ping vrf L3VPN 30.0.0.1 repeat 2 timeout 1
!-- conectividad con ios4 en L3VPN
ping vrf L3VPN 30.1.4.1 repeat 2 timeout 1
!-- conectividad con ios2 en L3VPN
ping vrf L3VPN 30.1.2.1 repeat 2 timeout 1
!-- conectividad con ios4 en L3VPN
traceroute vrf L3VPN 30.1.4.1 probe 1 timeout 1 ttl 0 5
!-- conectividad con ios2 en L3VPN
traceroute vrf L3VPN 30.1.2.1 probe 1 timeout 1 ttl 0 5
!-- conectividad con ios4 en GRT
ping 10.1.0.4 repeat 2 timeout 1 source loopback0
!-- traceroute con ios4 en GRT
traceroute 10.1.0.4 timeout 1 probe 1 source loopback0 ttl 0 5
!-- ping contra loopback CE site4 en L3VPN
ping vrf L3VPN 30.0.0.4 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.2 repeat 2 timeout 1
!-- traceroute contra loopback CE site4 en L3VPN
traceroute vrf L3VPN 30.0.0.4 probe 1 timeout 1 ttl 0 5
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1 ttl 0 5
!-- verificación sesión BGP
show bgp vpnv4 unicast vrf L3VPN summary
!-- verificación prefijos 30.0.0.1
show bgp vpnv4 unicast vrf L3VPN 30.0.0.1
!-- verificación prefijos 30.0.0.2
show bgp vpnv4 unicast vrf L3VPN 30.0.0.2
!-- verificación prefijos 30.0.0.4
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4

```


* `ios4`
```
!-- conectividad local enlace en L3VPN
ping vrf L3VPN 30.1.4.100 repeat 2 timeout 1
!-- conectividad local loopback CE en L3VPN
ping vrf L3VPN 30.0.0.4 repeat 2 timeout 1
!-- conectividad con ios1 en L3VPN
ping vrf L3VPN 30.1.1.1 repeat 2 timeout 1
!-- conectividad con ios2 en L3VPN
ping vrf L3VPN 30.1.2.1 repeat 2 timeout 1
!-- conectividad con ios1 en L3VPN
traceroute vrf L3VPN 30.1.1.1 probe 1 timeout 1 ttl 0 5
!-- conectividad con ios2 en L3VPN
traceroute vrf L3VPN 30.1.2.1 probe 1 timeout 1 ttl 0 5
!-- conectividad con ios1 en GRT
ping 10.1.0.1 repeat 2 timeout 1 source loopback0
!-- traceroute con ios1 en GRT
traceroute 10.1.0.1 timeout 1 probe 1source loopback0 ttl 0 5
!-- ping contra loopback CE site1 en L3VPN
ping vrf L3VPN 30.0.0.1 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.2 repeat 2 timeout 1
!-- traceroute contra loopback CE site1 en L3VPN
traceroute vrf L3VPN 30.0.0.1 probe 1 timeout 1 ttl 0 5
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1 ttl 0 5
!-- verificación sesión BGP
show bgp vpnv4 unicast vrf L3VPN summary
!-- verificación prefijos 30.0.0.1
show bgp vpnv4 unicast vrf L3VPN 30.0.0.1
!-- verificación prefijos 30.0.0.2
show bgp vpnv4 unicast vrf L3VPN 30.0.0.2
!-- verificación prefijos 30.0.0.4
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4
```

* `ios2`
```
!-- conectividad con ios1 en L3VPN
ping vrf L3VPN 30.1.1.1 repeat 2 timeout 1
!-- conectividad con ios4 en L3VPN
ping vrf L3VPN 30.1.4.1 repeat 2 timeout 1
!-- conectividad con ios1 en L3VPN
traceroute vrf L3VPN 30.1.1.1 probe 1 timeout 1 ttl 0 5
!-- conectividad con ios4 en L3VPN
traceroute vrf L3VPN 30.1.4.1 probe 1 timeout 1 ttl 0 5
!-- ping contra loopback CE site1 en L3VPN
ping vrf L3VPN 30.0.0.1 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.4 repeat 2 timeout 1
!-- traceroute contra loopback CE site1 en L3VPN
traceroute vrf L3VPN 30.0.0.1 probe 1 timeout 1 ttl 0 5
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.4 probe 1 timeout 1 ttl 0 5
!-- verificación prefijos 30.0.0.1
show bgp vpnv4 unicast vrf L3VPN 30.0.0.1
!-- verificación prefijos 30.0.0.2
show bgp vpnv4 unicast vrf L3VPN 30.0.0.2
!-- verificación prefijos 30.0.0.4
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4


```

## Ticket 01: fallo de conectividad con del site 1 con el site 4

En este caso tendremos 4 trabajos diferentes en rundeck:
* Trabajos `401` a `403` contienen los comandos y la verificaciones para cada equipo definidas en el apartado anterior.
* Trabajo `400`: ejecuta los tres trabajos anteriores de forma paralela

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-jobs.png)


Como primer paso abrimos rundeck y ejecutamos o bien el trabajo `400` o los otros tres de forma individual en paralelo. Tarda aproximadamente tres minutos en ejecutarse cada uno de los trabajos.

Si ejecutamos el trabajo 400 podemos ver en qué paso está la ejecución de cada trabajo:
![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-400-activity.png)

El resultado final tiene que ser similar a éste:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-400-fail.png)



El resultado de la ejecución del trabajo se muestra a continuación de forma tabulada.

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-tshoot.png)

Se puede verificar en la pestaña `activity` y ver qué paso particular ha fallado para cada job. El log de la ejecución de la prueba que ha fallado es siempre el paso anterior al que ha fallado, ya que cada verificación se divide en dos:
* [XXX][EXEC]: ejecución del comando de verificación.
* [XXX][TEST]: verificación de la ejecución del comando anterior.

A continuación se ven dos ejemplos:
* Verificación de ping que falla:
![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-result-failed.png)

* Verificación de ping que funciona:
![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-result-success.png)
Vemos que con la primera batería de prueba bastaría para comprobar que el problema reside en que la sesión BGP no levanta en ios4, aún teniendo ping local.

Si verificamos la configuración de al interfaz `Ethernet1/2` de `ios4` se puede ver que la dirección IP asignada no es consistente con el diagrama. Corregimos la configuración:

```
term len 0
term mon
enable
satec
show run interface ethernet1/2
conf t
int ethernet1/2
 ip address 30.1.4.1 255.255.255.0
end
wr

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Esperamos a que levante la sesión BGP ejecutando el siguiente snipppet hasta que veamos la sesión levantada.

```
show bgp vpnv4 unicast vrf L3VPN summary

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Una vez levantado podemos volver a repetir las pruebas. Se puede ejecutar desde la sección `jobs` o también se puede pedir a rundeck que repita un trabajo que ha fallado. Para hacer esto:
1. vamos a la pestaña activity.
2. señalamos el trabajo que ha fallado.
3. Elegimos la opción `Run again`

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-400-retry.png)

Finalmente, vemos que todo funciona correctamente:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage3-job-400-success.png)

