# Ticket 03: fallo de conectividad con del site 1 con el site 4

Como primer paso abrimos rundeck.

La url de rundeck la obtenemos en la ejecución del siguiente snippet:

** INSERT RUNDECK SNIPPET **

La url obtenida se copia y pega en un navegador y se accede a ella.

** INSTRUCCIONES DE RUNDECK **

Tras la ejecución de la prueba veamos los resultados de forma tabulada:

* Sesiones BGP

|equipo|Estado|
|:---:|:---:|
|ios1|ok|
|ios2|ok|
|ios4|ok|

* Tabla BGP

|equipo|30.0.0.1|30.0.0.2|30.0.0.4|
|:---:|:---:|:---:|:---:|
|ios1|ok|ok|ok|
|ios2|ok|ok|ok|
|ios4|ok|ok|ok|

* Conectividad en L3VPN

|equipo|ios1 l3vpn|Ios2 l3vpn|ios4 l3vpn|ce1 local|ce2 local|ce4 local|ce1 lbk|ce2 lbck|ce4lbk|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|ios1 l3vpn|ok|ok|**X**|ok|n/a|n/a|ok|ok|**X**|
|ios2 l3vpn|ok|ok|**X**|n/a|ok|n/a|ok|ok|**X**|
|ios4 l3vpn|**x**|**x**|ok|n/a|n/a|ok|ok|ok|ok|

* Conectividad en tabla global via ping

|equipo|ios1|ios2|ios4|
|:---:|:---:|:---:|:---:|
|ios1|ok|ok|ok|
|ios2|ok|ok|ok|
|ios4|ok|ok|ok|

* Conectividad en tabla global via traceroute

|equipo|ios1|ios2|ios4|
|:---:|:---:|:---:|:---:|
|ios1|ok|ok|ok|
|ios2|ok|ok|ok|
|ios4|*ok*|ok|ok|

En este caso el plano de control es correcto extremo a extremo y hay conectividad en la tabla global.

Si revisamos los traceroute que en la tabla global, se puede observar que no se está imponiendo ninguna etiqueta MPLS en sentido `ios4` -> `ios1`, cuando debería haber al menos una.


```
term len 0
term mon
enable
satec
traceroute 10.1.0.1 source 10.1.0.4 probe 1 timeout 1

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>


Por tanto:

* como la conectividad entre `ios1` e `ios2` funciona correctamente entonces el problema debe estar entre `ios2` e `ios4`.
* Revisamos en ambos equipos el estado de LDP entre ellos:



**`ios2`**
```
term len 0
term mon
enable
satec
show mpls interfaces
show mpls ldp neighbor

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


**`ios4`**
```
show mpls interfaces
show mpls ldp neighbor

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

MPLS no está corriendo en la interfaz `ethernet1/0` de `ios4`. Habilitamos el protocolo y repetimos las pruebas.


**`ios4`**
```
conf t
interface ethernet1/0
 mpls ip
!
end
wr

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>



```
show mpls interfaces
show ldp neighbor

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>


Verificamos que el camino a `ios1` ya está etiquetado:

```
traceroute 10.1.0.1 source 10.1.0.4 probe 1 timeout 1

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Comprobamos la conectividad en la vpn desde `ios1`:

```
ping vrf L3VPN 30.0.0.4

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>