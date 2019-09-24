# Provisión de un nuevo PE
## Introdución - Provisión de un nuevo PE

El objeto de esta lección es verificar cómo se puede utilizar la automatización para insertar un nuevo equipo en la red MPLS.

La adición de un nuevo equipo tendría las siguientes etapas:
1. Preconfiguración completa del nuevo equipo.
2. Configuración de enlaces de los equipos P a los que se conecta.
3. Configuración del protocolo IGP (OSPF).
4. Configuración de protocolo de distribución de etiquetas (LDP)
5. Configuración de BGP contra los reflectores de rutas.
6. Acceso al nuevo equipo y comprobaciones en el mismo

En cada paso es necesario ir comprobando que se ha cumplimentado correctamente.

> Herramientas: Abrir rundeck en una nueva ventana, para ello ejecutar el siguiente snippet y acceder a rundeck con la url que genera el siguiente snippet.

```
echo https://labs.jt.satec.es/$SYRINGE_FULL_REF
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('rundeck-cli', this)">Run this snippet</button>


![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-snippet.png)

El usuario y contraseña es `admin/admin`.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-login.png)


A continuación se describen todos los pasos necesarias para la integración con su configuración asociada. Esta configuración se puede ejecutar desde esta guía, pero el objetivo es realizarla con rundeck. Por tanto estos *snippets* quedan como referencia.

## Parte 0: Rundeck

Una vez abierto Rundeck abriremos el projecto **SATEC**.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-main.png)

### 0.1: revisión de trabajos configurados en rundeck

Al abrirlo en la barra de al izquierda veremos las diferentes opciones que nos ofrece. En particular la sección de `jobs`, donde se definen y ejecutan los trabajos de rundeck.

Presionamos en jobs para ver los que están definidos.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-jobs.png)

Todos los trabajos definidos están numerados:
* del `000` al `003`: trabajos individuales que se corresponden con la preconfiguración de `ios1`.
* del `004` al `012`: trabajos individuales que se corresponden con la configuración y comprobaciones necesarias para la integración de `ios1` contra `ios2`.
* del `013` al `021`: trabajos individuales que se corresponden con la configuración y comprobaciones necesarias para la integración de `ios1` contra `vqfx3`.
* del `022` al `025`: trabbajos individuales para al verfiicación de la correcta integración de `ios1`.
* `100`: trabajo compuesto que englobal todos los trabajos del `013` al `021`.

Si presionamos en el botón que aparece en el extremo derecho de cada tarea y seleccionamos editar podemos ver la apariencia que tiene un trabajo.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-edit-job.png)

Dentro de la configuración del trabajo hay varias pestañas:
* Details: nombre y descripción del trabajo.
* workflow: pasos que se ejecutan en cada trabajo.
* Nodes: en qué equipos se ejecuta el trabajo.
* Schedule: cuándo se ejecuta el trabajo.
* Notifications: a quién se notifica el resultado de la ejecución.
* Other: otros parámetros de ejecución.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-edit-job-details.png)

En la pestaña `workflow` vemos los pasos de los que consta el trabajo.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-edit-job-workflow.png)

En este caso el trabajo consta de dos pasos o steps:
1. un primero que ejecuta multiples comandos en el equipo y realiza capturas de la salida.
2. un segundo que verifica el resultado de la ejecución.

Si presionamos en el primer paso nos aparecerán los detalles del mismo. En nuestro caso los comandos que se van a enviar al equipo para su ejecución.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-edit-job-step.png)

### Ejecución de trabajos del `000` al `003`

Después de revisar los trabajos volvemos al apartado `jobs` para su ejecución.

Puesto que la preconfiguración se corresponde con los trabajos del `000` al `004` los ejecutaremos secuencialmente.

Para ejecutar un trabajo se presiona el botón de "play" a la izquierda del mismo.


![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-run-job-play.png)


Aparecerá una segunda ventana con las opciones de ejecución. Por defecto al ejecutar un trabajo el navegador te lleva a la pestaña de `activity` para ver el resultado de la ejecueción. Si desplegamos el botón `Run Job Now` veremos que permite:
* activar los debugs de ejecución del trabajo (desactivados por defecto).
* ir a ver el resultado de la ejecución (activado por defecto).

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-run-job-run-now.png)

Durante la ejecución se puede verificar el estado de cada uno de los `steps` que se están ejecutando. Una vez finalizada la ejecución muestra el resumen de la ejecución.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-activity-result-summary.png)

Si pinchamos en el trabajo nos despliega el resultado de ejecución de cada paso individual:

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-activity-result-step-summary.png)

Si pinchamos en cualquiera de los steps vemos los logs de ejecución del mismo.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-activity-result-step.png)


Ejecutamos todos los trabajo del `000` al `003` siguiendo el procedimiento anterior.

### Ejecución de trabajos del `004` al `012`

Estos trabajos los ejecutamos también de uno en uno y de forma correlativa.

Podemos ir revisando los logs de ejecución para verificar que efectivamente el resultado de todas las pruebas es correcto.


### Ejecución del trabajo `100`

El trabajo `100` es un trabajo especial. Los pasos que lo componen son a su vez otros trabajo, en particular los que van del `013` al `021`.

Rundeck permite de esta forma una gran modularidad en la composición de las tareas. No sólo permite agrupar tareas de esta formas, sino flujos de control que indiquen qué debe realizarse en caso de fallar una paso dentro de una tarea.

Este tipo de tareas más complejas, junto con la adición de plantillas y parámetros, son lo que permite facilitar la automatización de tareas.

![snippet](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-rundeck-activity-100-result.png)


### Verificaciones finales: `022` a `024`

Para finalizar ejecutamos de forma individual los trabajos que verifican en `ios1` que éste ha sido integrado correctamente.



## Parte 1: Preconfiguración completa del nuevo equipo

En despliegues grandes es habitual enviar todos los equipos preconfigurados, de forma que durante la integración del nuevo equipo sólo es necesario configurar en extremos remotos.

Esta configuración se realiza habitualmente en base a plantillas.

El equipo que se va a insertar en red es `ios1`.

![lesson1](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage1-diagram)


Primero se comprueba la configuración inicial del equipo:

```
enable
satec
term mon
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


## Parte 2: Configuración de enlaces de los equipos P a los que se conecta.

Después de la sección anterior los equipos ya están preconfigurados.

El siguiente paso sería la comprobación de la comunicación con los equipos troncales. En un entorno real equivaldría a:
* Realización del cableado extremo a extremo, con o sin tramo de transmisión.
* Verificación de que el enlace físico levanta (en nuestro caso no aplica)
* Comprobación de conectividad IP en el enlace (batería de pings)

Vamos a configurar primero el enlace contra `ios2`:

* Primero verificamos la configuración de la interfaz que se tiene que utilizar `ethernet1/0`:
```
enable
satec
term mon
term len 0
show interface e1/0
show run interface e1/0

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* Aplicamos la nueva configuración en la interfaz:
```
conf t
interface Ethernet1/0
 no shut
 ip address 10.1.12.2 255.255.255.0
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* Una vez configurado el nuevo enlace verificamos el estado del enlace y si hay conectividad en él.
```
show run interface e1/0
show interface ethernet1/0
ping 10.1.12.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

Realizamos ahora las mismas acciones en `vqfx3`:

* Primero verificamos la configuración de la interfaz que se tiene que utilizar `em3`:
```
show configuration interface em3
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

* Aplicamos la nueva configuración en la interfaz:
```
configure
set interfaces em3 unit 0 family inet address 10.1.13.3/24
show | compare
commit and-quit
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

* Una vez configurado el nuevo enlace verificamos el estado del enlace y si hay conectividad en él.
```
show configuration interface em3
ping 10.1.13.1 rapid count 5
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>


## Parte 3: Configuración del protocolo IGP (OSPF).

Depués de conseguir la conectividad el siguiente paso es la integración en el IGP, para que el nuevo equipo sea visible en la red.

### Configuración en `ios2`
Configuramos primero en `ios2`:

* Aplicamos la nueva configuración en la interfaz:
```
conf t
interface Ethernet1/0
 ip ospf network point-to-point
 ip ospf 1 area 0
!
router ospf 1
 no passive-interface Ethernet1/0
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* Comprobamos que levanta la sesión y que se ve la dirección de loopback del equipo `ios1`
```
show ip ospf neighbor
show ip route 10.1.0.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

### Configuración en `vqfx3`

* Aplicamos la nueva configuración en la interfaz:
```
configure
set protocols ospf area 0.0.0.0 interface em3.0 interface-type p2p
show | compare
commit and-quit
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

* Comprobamos que levanta la sesión y que se ve la dirección de loopback del equipo `ios1`
```
show ospf neighbor
show route 10.1.0.1 exact
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>


## Parte 4: Configuración de protocolo de distribución de etiquetas (LDP)
El protocolo elegido es LDP.


### Configuración en `ios2`
Configuramos primero en `ios2`:

* Aplicamos la nueva configuración en la interfaz:
```
conf t
interface Ethernet1/0
 mpls ip
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* Comprobamos que levanta la sesión contra`ios1`
```
show mpls ldp neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

### Configuración en `vqfx3`

* Aplicamos la nueva configuración en la interfaz:
```
configure
set interfaces em3 unit 0 family mpls
set protocols ldp interface em3.0
show | compare
commit and-quit
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

* Comprobamos que levanta la sesión contra `ios1`
```
show ldp neighbor
show ldp session
show ldp database session 10.1.0.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

## Parte 5: Configuración de BGP contra los reflectores de rutas.

El último punto para que el equipo quede completamente integrado en la red y listo para prestar servicio es levantar las sesiones contra los reflectores. En esta topología los reflectores son:
* `ios2`
* `vqfx3`


### Configuración en `ios2`
Configuramos primero en `ios2`:

* Aplicamos la nueva configuración de bgp:
```
conf t

router bgp 65001
 neighbor 10.1.0.1 peer-group RR-CLIENT
 !
 address-family ipv4
  neighbor 10.1.0.1 activate
 exit-address-family
 !
 address-family vpnv4
  neighbor 10.1.0.1 activate
 exit-address-family
 !
!
end
wr
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* Comprobamos que levanta la sesión contra `ios1`. Las sesiones bgp tardan en levantar, por lo que puede ser necesario repetir el comando varias veces.
```
show bgp all
show bgp all summary | i 10.1.0.1
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

### Configuración en `vqfx3`

* Aplicamos la nueva configuración de bgp:
```
configure
set protocols bgp group RR-CLIENTS neighbor 10.1.0.1
show | compare
commit and-quit
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

* Comprobamos que levanta la sesión contra `ios1`.Las sesiones bgp tardan en levantar, por lo que puede ser necesario repetir el comando varias veces.
```
show bgp summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>


## Parte 6: Acceso al nuevo equipo y comprobaciones en el mismo

Finalmente accedemos al nuevo equipos y realizamos las comprobaciones habituales:

* OSPF
```
show ip ospf neighbor
show ip ospf database
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* MPLS:
```
show mpls ldp neighbor
show mpls forwarding
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* BGP:
```
show bgp all summary
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* connectividad MPLS:
```
traceroute 10.1.0.4 source 10.1.0.1 probe 1 timeout 1 
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>




