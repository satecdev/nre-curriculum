# Ticket 03: fallo de conectividad con del site 1 con el site 4

## Ejecución de pruebas en rundeck

Como primer paso abrimos rundeck y ejecutamos la batería de pruebas.


## Análisis de los resultados

Se ejecutan las mismas pruebas que en el ticket anterior.


El resultado final tiene que ser similar a éste:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-job-400-fail.png)


El resultado de la ejecución del trabajo se muestra a continuación de forma tabulada.

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-tshoot.png)


En este caso el plano de control es correcto extremo a extremo y hay conectividad en la tabla global.

Si revisamos los traceroute que en la tabla global, se puede observar que no se está imponiendo ninguna etiqueta MPLS en sentido `ios4` -> `ios1`, cuando debería haber al menos una.


```
enable
satec
term len 0
term mon
traceroute 10.1.0.1 source 10.1.0.4 probe 1 timeout 1 ttl 0 5

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>


Por tanto:

* como la conectividad entre `ios1` e `ios2` funciona correctamente entonces el problema debe estar entre `ios2` e `ios4`.
* Revisamos en ambos equipos el estado de LDP entre ellos:



**`ios2`**
```
enable
satec
term len 0
term mon
show mpls interfaces
show mpls ldp neighbor

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>


![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-snippet-ios2-fail.png)


**`ios4`**
```
show mpls interfaces
show mpls ldp neighbor

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>


![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-snippet-ios4-fail.png)


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
show mpls ldp neighbor

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

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-snippet-ios4-correct.png)




Una vez levantada la sessión ldp podemos volver a repetir las pruebas, que ahora serán exitosas:

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage5-job-400-success.png)
