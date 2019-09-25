# Provision de un servicio L3VPN

## Introducción

Un servicio habitual en una operadora es la provisión de una L3VPN full-mesh.

Con este tipo de servicio se proporciona una conexión privada entre diferentes sedes.

Para proporcionar el servicio es necesario definir:
* route-distinguiser: campo de 8 bytes que permite crear direcciones únicas VPNv4 al añadirlo a un prefijo IPv4.
* route-target: community extendida que dicta la política de qué prefijos forman parte de una VPN.

En nuestro caso utilizaremos el siguiente formato:
* RD = {{ dirección_lo0 }}:{{ vrf.id }}
* route-target = {{ as=65001 }}:{{ vrf.id }}

El identificador de VPN que utilizaremos será el `1`.

La plantilla en IOS para configurar esta vpn sería:
* Configuración de la vrf:

```
!-- definición de la vrf
vrf definition {{ vrf.name }}
 rd {{ system.id }}:{{ vrf.id }}
 !
 address-family ipv4 {{ vrf.name }}
  route-target export 65001:{{ vrf.id }}
  route-target import 65001:{{ vrf.id}}
 exit-address-family
!
!-- definición en BGP 
router bgp 65001
  address-family ipv4 vrf {{ vrf.name }}
  redistribute connected
 exit-address-family
!
```

* Configuración de vecinos en la vrf:
```
!-- configuración de la interfaz en la vrf
interface {{ intf.name }}
 vrf forwarding {{ intf.name }}
 ip address {{ intf.address }} {{ intf.mask }}
!
!-- configuración del vecino BGP
!-- definición en BGP 
router bgp 65001
 address-family ipv4 vrf {{ vrf.name }}
  neighbor {{ intf.nbr_address }} remote-as 65002
  neighbor {{ intf.nbr_address }} activate
  neighbor {{ intf.nbr_address }} as-override
  neighbor {{ intf.nbr_address }} timers 5 15
 exit-address-family
 !
!
```

En JUNOS las plantillas equivalentes serían:
* Configuración de la vrf:

```
!-- configuración de la routing instance
set routing-instances {{ vrf.name }} instance-type vrf
set routing-instances {{ vrf.name }} route-distinguisher {{ system.id }}:{{ vrf.id }}
set routing-instances {{ vrf.name }} vrf-target target:65001:{{ vrf.id }}
set routing-instances {{ vrf.name }} protocols bgp group CLIENTES type external
set routing-instances {{ vrf.name }} protocols bgp group CLIENTES peer-as 65002
set routing-instances {{ vrf.name }} protocols bgp group CLIENTES as-override
```



* Configuración de vecinos
```
!-- configuración de la interfaz
set interfaces {{ intf.name }} family inet address {{ intf.address }}/{{ intf.prefix_len}}
set interfaces {{ intf.name }} family inet address {{ intf.address }}/{{ intf.prefix_len}}
!-- adición de la interfaz a la vrf
set routing-instances {{ vrf.name }} interface {{ intf.name }
!-- configuración del vecino BGP
set routing-instances {{ vrf.name }} protocols bgp group CLIENTES neighbor {{ intf.nbr_address }}

```

## Datos para la configuración de un servicio L3VPN

Una vez entendidas las plantillas de configuración, vamos a aplicarlos para crear una VP en los routers `ios1`, `ios2` e `ios4`.

Nuestros datos serán:

```yaml
ios1:
  vrf:
    name: L3VPN
    id: 1
    interfaces:
    - name: ethernet1/3
      address: 30.1.1.1
      mask: 255.255.255.0
      prefix_len: 24
      nbr_address: 30.1.1.100
ios2:
  vrf:
    name: L3VPN
    id: 1
    interfaces:
    - name: ethernet1/3
      address: 30.1.2.1
      mask: 255.255.255.0
      prefix_len: 24
      nbr_address: 30.1.2.100
ios4:
  vrf:
    name: L3VPN
    id: 1
    interfaces:
    - name: ethernet1/2
      address: 30.1.2.1
      mask: 255.255.255.0
      prefix_len: 24
      nbr_address: 30.1.4.100
```

Con estos datos se pretende construir la topología adjunta:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage2-diagram.png)


## Ejecución en rundeck

Al igual que en la lección anterior continuaremos utilizando rundeck para la configuración, aunque más abajo se pueden utilizar *snippets* de configuración para realizar la misma configuración.

Refrescamos la ventana de rundeck y comprobamos los nuevos trabajos que nos aparecen:


![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage2-jobs.png)

En este caso tenemos los siguientes:
* `000` - `002`: Trabajos de configuración de la vrf L3VPN en `ios1`, `ios2` e `ios4`.
* `003`: trabajo compuesto que ejecuta los tres trabajos anteriores.
* `101` - `103`: Trabajos que comprueba que la conectividad pe-ce y el routing configurado en `ios1` es correcto.
* `100`: trabajo que aglutina las comprobaciones de `ios1`
* `201` - `202`: Trabajos que comprueba que la conectividad pe-ce y el routing configurado en `ios2` es correcto.
* `200`: trabajo que aglutina las comprobaciones de `ios2`
* `301` - `303`: Trabajos que comprueba que la conectividad pe-ce y el routing configurado en `ios4` es correcto.
* `300`: trabajo que aglutina las comprobaciones de `ios4`
* `400`: trabajo que contine pings entre todos los sites y que se ejecuta por igual en los tres equipos ios que forman parte de la L3VPN.

 El trabajo `400` introduce el concepto de un mismo trabajo que se ejecute en varios equipos a la vez.

 Para poder realizar esto es necesario definirlo en la pestaña `nodes` al editar el trabajo.

 En la siguiente imagen se ve la configuración de esta tarea en particular.


![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage2-jobs-400.png)

En este punto podemos ejecutar los trabajos individuales de forma correlativa, o ejecutar los trabajos compuestos.

La ejecución del trabajo 400 nos mostrará que se están ejecutacando los mismos pasos en los tres equipos:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage2-jobs-400-activity-detail.png)



## Paso 1: Configuración en ios1

A continuación se describen todos los pasos necesarioas para la integración con su configuración asociada. Esta configuración se puede ejecutar desde esta guía, pero el objetivo es realizarla con rundeck. Por tanto estos *snippets* quedan como referencia.


Primero introducimos la configuración en este equipo:

```
enable
satec
term len 0
term mon
conf t
vrf definition L3VPN
 rd 10.1.0.1:1
 !
 address-family ipv4
  route-target export 65001:1
  route-target import 65001:1
 exit-address-family
!
interface Ethernet1/3
 no shut
 vrf forwarding L3VPN
 ip address 30.1.1.1 255.255.255.0
!

router bgp 65001
 address-family ipv4 vrf L3VPN
  redistribute connected
  neighbor 30.1.1.100 remote-as 65002
  neighbor 30.1.1.100 activate
  neighbor 30.1.1.100 as-override
  neighbor 30.1.1.100 timers 5 15
 exit-address-family
 !
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

Realizamos verificaciones de la configuración:

* Tenemos conectividad en el enlace:
```
ping vrf L3VPN 30.1.1.100
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* **BGP:** Levanta la sesión:
```
!-- comprobación de que la sesión BGP levanta
show bgp vpnv4 unicast vrf L3VPN summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* **BGP:** Se aprenden prefijos:
```
!-- verificación de que se aprenden prefijos.
show bgp vpnv4 unicast vrf L3VPN
show ip route vrf L3VPN
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* **BGP:** Los prefijos están presentes en los reflectores de rutas (`ios2`, `vqfx3`)
 * `ios2`:

```
!-- verificación de que se aprenden prefijos.
show bgp vpnv4 unicast rd 10.1.0.1:1 
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button> 

 * `vqfx3`:

```
show route receive-protocol bgp 10.1.0.1 table L3VPN.inet.0 | no-more
show route protocol bgp next-hop 10.1.0.1 table L3VPN.inet.0 | no-more

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button> 


## Paso 2: Configuración en `ios4`

Primero introducimos la configuración en este equipo:

```
enable
satec
term len 0
term mon
conf t
vrf definition L3VPN
 rd 10.1.0.4:1
 !
 address-family ipv4
  route-target export 65001:1
  route-target import 65001:1
 exit-address-family
!
interface Ethernet1/2
 no shut
 vrf forwarding L3VPN
 ip address 30.1.4.1 255.255.255.0
!

router bgp 65001
 address-family ipv4 vrf L3VPN
  redistribute connected
  neighbor 30.1.4.100 remote-as 65002
  neighbor 30.1.4.100 activate
  neighbor 30.1.4.100 as-override
  neighbor 30.1.4.100 timers 5 15
 exit-address-family
 !
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Realizamos verificaciones de la configuración:

* Tenemos conectividad en el enlace:
```
ping vrf L3VPN 30.1.4.100
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

* **BGP**: sesión levantada
```
!-- comprobación de que la sesión BGP levanta
show bgp vpnv4 unicast vrf L3VPN summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

* **BGP**: se aprenden rutas.

```
!-- verificación de que se aprenden prefijos, tanto del vecino como de ios1
show bgp vpnv4 unicast vrf L3VPN
show ip route vrf L3VPN
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>


* **BGP**: Los prefijos están presentes en los reflectores de rutas (`ios2`, `vqfx3`)
  * `ios2`:

```
!-- verificación de que se aprenden prefijos.
show bgp vpnv4 unicast rd 10.1.0.4:1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button> 

   * `vqfx3`:

```
show route receive-protocol bgp 10.1.0.4 table L3VPN.inet.0 | no-more
show route protocol bgp next-hop 10.1.0.4 table L3VPN.inet.0 | no-more

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button> 

* **BGP**: Los prefijos están presentes en `ios1` :
```
!-- verificación de que se aprenden prefijos, tanto del vecino como de ios4
show bgp vpnv4 unicast vrf L3VPN
show ip route vrf L3VPN
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* **CONECTIVIDAD**: Conectividad en la L3VPN:
* `ios1`: ping
```
!-- prueba de conectividad
ping vrf L3VPN 30.0.0.4
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* `ios1`: traceroute
```
!-- prueba de conectividad
traceroute vrf L3VPN 30.0.0.4
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>



 * `ios4`: ping
```
!-- prueba de conectividad
ping vrf L3VPN 30.0.0.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

 * `ios4`: traceroute
```
!-- prueba de conectividad
traceroute vrf L3VPN 30.0.0.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>



## Paso 3: Configuración en `ios2`

Primero introducimos la configuración en este equipo:

```
enable
satec
term len 0
term mon
conf t
vrf definition L3VPN
 rd 10.1.0.2:1
 !
 address-family ipv4
  route-target export 65001:1
  route-target import 65001:1
 exit-address-family
!
interface Ethernet1/3
 no shut
 vrf forwarding L3VPN
 ip address 30.1.2.1 255.255.255.0
!

router bgp 65001
 address-family ipv4 vrf L3VPN
  redistribute connected
  neighbor 30.1.2.100 remote-as 65002
  neighbor 30.1.2.100 activate
  neighbor 30.1.2.100 as-override
  neighbor 30.1.2.100 timers 5 15
 exit-address-family
 !
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

Realizamos verificaciones de la configuración:

* **CONECTIVIDAD LOCAL:** Tenemos conectividad en el enlace:
```
ping vrf L3VPN 30.1.2.100
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* **BGP:** Levanta la sesión BGP:
```
!-- comprobación de que la sesión BGP levanta
show bgp vpnv4 unicast vrf L3VPN summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* **BGP:** Se aprendend prefijos:
```
!-- verificación de que se aprenden prefijos, tanto del vecino como de ios1 e ios4
show bgp vpnv4 unicast vrf L3VPN
show ip route vrf L3VPN
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


* **BGP:** Los prefijos están presentes en los reflectores de rutas ( `vqfx3`)
 * `vqfx3`:

```
show route receive-protocol bgp 10.1.0.2 table L3VPN.inet.0 | no-more
show route protocol bgp next-hop 10.1.0.2 table L3VPN.inet.0 | no-more

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button> 

* **BGP:** Los prefijos están presentes en `ios1` :
```
!-- verificación de que se aprenden prefijos, tanto del vecino como de ios4
show bgp vpnv4 unicast vrf L3VPN
show ip route vrf L3VPN
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* **Conectividad en la L3VPN:**
 * `ios1`: ping  
```
!-- prueba de conectividad
ping vrf L3VPN 30.0.0.2
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

 * `ios1`: traceroute
```
!-- prueba de conectividad
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>


 * `ios2`: ping contra site 1
```
!-- prueba de conectividad contra ios1
ping vrf L3VPN 30.0.0.1

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


 * `ios2`: traceroute contra site 1
```
!-- prueba de conectividad contra ios1
traceroute vrf L3VPN 30.0.0.1 probe 1 timeout 1


```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


 * `ios2`: ping contra site 4
```

!-- prueba de conectividad contra ios4
ping vrf L3VPN 30.0.0.4

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


 * `ios2`: traceroute contra site 4
```
!-- prueba de conectividad contra ios4
traceroute vrf L3VPN 30.0.0.4 probe 1 timeout 1

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>



 * `ios4`: ping contra site2
```
!-- prueba de conectividad
ping vrf L3VPN 30.0.0.2
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

 * `ios4`: traceroute contra site 2
```
!-- prueba de conectividad
traceroute vrf L3VPN 30.0.0.2 probe 1 timeout 1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

