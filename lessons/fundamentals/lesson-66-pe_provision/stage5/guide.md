# Ticket 03: fallo de conectividad con del site 1 con el site 4

## Ejecución de pruebas en rundeck

Como primer paso abrimos rundeck y ejecutamos la batería de pruebas.


## Análisis de los resultados

Tras la ejecución de la prueba veamos los resultados de forma tabulada:

![stage5](https://cdn1.imggmi.com/uploads/2019/9/19/eb9562072d8d4bdb610a4bdcf6508077-full.png)



En este caso el plano de control es correcto extremo a extremo y hay conectividad en la tabla global.

Si revisamos los traceroute que en la tabla global, se puede observar que no se está imponiendo ninguna etiqueta MPLS en sentido `ios4` -> `ios1`, cuando debería haber al menos una.


```
term len 0
term mon
enable
satec
traceroute 10.1.0.1 source 10.1.0.4 probe 1 timeout 1 ttl 5

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
traceroute 10.1.0.1 source 10.1.0.4 probe 1 timeout 1 ttl 0 5

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Comprobamos la conectividad en la vpn desde `ios1`:

```
ping vrf L3VPN 30.0.0.4

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>