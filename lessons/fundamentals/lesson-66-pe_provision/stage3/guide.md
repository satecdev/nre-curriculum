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
traceroute vrf L3VPN 30.1.4.1 probe 1 timeout 1
!-- conectividad con ios2 en L3VPN
traceroute vrf L3VPN 30.1.2.1 probe 1 timeout 1
!-- conectividad con ios4 en GRT
ping 10.1.0.4 repeat 2 timeout 1 source loopback0
!-- traceroute con ios4 en GRT
traceroute 10.1.0.4 timeout 1 probe 1 source loopback0
!-- ping contra loopback CE site4 en L3VPN
ping vrf L3VPN 30.0.0.4 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.2 repeat 2 timeout 1
!-- traceroute contra loopback CE site4 en L3VPN
traceroute vrf L3VPN 30.0.0.4 probe 1 timeout 1
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1
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
traceroute vrf L3VPN 30.1.1.1 probe 1 timeout 1
!-- conectividad con ios2 en L3VPN
traceroute vrf L3VPN 30.1.2.1 probe 1 timeout 1
!-- conectividad con ios1 en GRT
ping 10.1.0.1 repeat 2 timeout 1 source loopback0
!-- traceroute con ios1 en GRT
traceroute 10.1.0.1 timeout 1 probe 1source loopback0
!-- ping contra loopback CE site1 en L3VPN
ping vrf L3VPN 30.0.0.1 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.2 repeat 2 timeout 1
!-- traceroute contra loopback CE site1 en L3VPN
traceroute vrf L3VPN 30.0.0.1 probe 1 timeout 1
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1
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
traceroute vrf L3VPN 30.1.1.1 probe 1 timeout 1
!-- conectividad con ios4 en L3VPN
traceroute vrf L3VPN 30.1.4.1 probe 1 timeout 1
!-- ping contra loopback CE site1 en L3VPN
ping vrf L3VPN 30.0.0.1 repeat 2 timeout 1
!-- ping contra loopback CE site2 en L3VPN
ping vrf L3VPN 30.0.0.4 repeat 2 timeout 1
!-- traceroute contra loopback CE site1 en L3VPN
traceroute vrf L3VPN 30.0.0.1 probe 1 timeout 1
!-- traceroute contra loopback CE site2 en L3VPN
traceroute vrf L3VPN 30.0.0.4 probe 1 timeout 1
!-- verificación prefijos 30.0.0.1
show bgp vpnv4 unicast vrf L3VPN 30.0.0.1
!-- verificación prefijos 30.0.0.2
show bgp vpnv4 unicast vrf L3VPN 30.0.0.2
!-- verificación prefijos 30.0.0.4
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4


```

## Ticket 01: fallo de conectividad con del site 1 con el site 4

Como primer paso abrimos rundeck.

La url de rundeck la obtenemos en la ejecución del siguiente snippet:

**INSERT RUNDECK SNIPPET**

La url obtenida se copia y pega en un navegador y se accede a ella.

**INSTRUCCIONES DE RUNDECK**

Tras la ejecución de la prueba veamos los resultados de forma tabulada:

* Sesiones BGP

| equipo | Estado |
| :---: | :---: |
| ios1 | ok |
| ios2 | ok |
| ios4 | **X** |

* Tabla BGP

| equipo | 30.0.0.1 | 30.0.0.2 | 30.0.0.4 |
| :---: | :---: | :---: | :---: |
| ios1 | ok | ok | **X** |
| ios2 | ok | ok | **X** |
| ios4 | ok | ok | **X** |

* Conectividad en L3VPN

| equipo | ios1 l3vpn | Ios2 l3vpn | ios4 l3vpn | ce1 local | ce2 local | ce4 local | ce1 lbk | ce2 lbck | ce4lbk | 
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| ios1 l3vpn | ok | ok | ok | ok | n/a | n/a | ok | ok | **X** |
| ios2 l3vpn | ok | ok | ok | n/a | ok | n/a | ok | ok | **X** |
| ios4 l3vpn | ok | ok | ok | n/a | n/a | ok | ok | ok | **X** |

* Conectividad en tabla global via ping

| equipo | ios1 | ios2 | ios4 |
| :---: | :---: | :---: | :---: |
| ios1 | ok | ok | ok |
| ios2 | ok | ok | ok |
| ios4 | ok | ok | ok |

* Conectividad en tabla global via traceroute

| equipo | ios1 | ios2 | ios4 |
| :---: | :---: | :---: | :---: |
| ios1 | ok | ok | ok |
| ios2 | ok | ok | ok |
| ios4 | ok | ok | ok |

Vemos que con la primera batería de prueba bastaría para comprobar que el problema reside en que la sesión BGP no levanta en ios4, aún teniendo ping local.

Si verificamos la configuración de al interfaz `Ethernet1/2` de `ios4` se puede ver que la dirección IP asignada no es consistente con el diagrama. Corregimos la configuración:

```
term len 0
term mon
enable
satec
conf t
int ethernet1/2
 ip address 30.1.4.1 255.255.255.0
end
wr

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Esperamos a que levante la sesión BGP:

```
show bgp vpnv4 unicast vrf L3VPN summary

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Una vez levantado podemos volver a repetir las pruebas.