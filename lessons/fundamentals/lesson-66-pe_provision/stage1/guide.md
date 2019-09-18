# Provisión de un nuevo PE
## Introdución - Provisión de un nuevo PE

El objeto de esta lección es verificar cómo se puede utilizar la automatización para insertar un nuevo equipo en la red MPLS.

La adición de un nuevo equipo tendría las siguientes etapas:
1. Preconfiguración completa del nuevo equipo.
2. Configuración de enlaces de los equipos P a los que se conecta.
3. Configuración del protocolo IGP (OSPF).
4. Configuración de protocolo de distribución de etiquetas (LDP)
5. Configuración de BGP contra los reflectores de rutas.

En cada paso es necesario ir comprobando que se ha cumplimentado correctamente.

## Parte 1: Preconfiguración completa del nuevo equipo

En despliegues grandes es habitual enviar todos los equipos preconfigurados, de forma que durante la integración del nuevo equipo sólo es necesario configurar en extremos remotos.

Esta configuración se realiza habitualmente en base a plantillas.

El equipo que se va a insertar en red es `ios1`.

Primero se comprueba la configuración inicial del equipo:

```
enable
satec
term len 0
show running
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>


A partir de aquí cargamos toda la configuración:
```
conf t
!-- configuración de interfaz de loopback
interface Loopback0
 ip address 10.1.0.1 255.255.255.255
 ip ospf 1 area 0
!
!-- configuración de interfaces mpls de core
interface Ethernet1/0
 ip address 10.1.12.1 255.255.255.0
 ip ospf network point-to-point
 ip ospf 1 area 0
 mpls ip
!
interface Ethernet1/1
 ip address 10.1.13.1 255.255.255.0
 ip ospf network point-to-point
 ip ospf 1 area 0
 mpls ip
!
!-- configuración de IGP
router ospf 1
 passive-interface default
 no passive-interface Ethernet1/0
 no passive-interface Ethernet1/1
!
!-- configuración de BGP
router bgp 65001
 bgp router-id 10.1.0.1
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor CLIENTE peer-group
 neighbor CLIENTE remote-as 65002
 neighbor IBGP peer-group
 neighbor IBGP remote-as 65001
 neighbor IBGP password 7 0518071B244F
 neighbor IBGP update-source Loopback0
 neighbor 10.1.0.2 peer-group IBGP
 neighbor 10.1.0.3 peer-group IBGP
!
 address-family ipv4
  neighbor CLIENTE send-community
  neighbor CLIENTE default-originate
  neighbor IBGP send-community
  neighbor IBGP next-hop-self
  neighbor 20.1.1.100 activate
  neighbor 10.1.0.2 activate
  neighbor 10.1.0.3 activate
 exit-address-family
 !
 address-family vpnv4
  neighbor IBGP send-community both
  neighbor 10.1.0.2 activate
  neighbor 10.1.0.3 activate
 exit-address-family
 !
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

Por último comprobamos la configuración del equipo, y cómo ninguno de los protocolos funciona.


* Comprobación de la configuración
```
show running
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* Comprobación estándar
```
show ip ospf neighbor
show mpls ldp neighbor
show bgp all summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>
