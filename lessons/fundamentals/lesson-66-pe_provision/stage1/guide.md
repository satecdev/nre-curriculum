# Configuración de maqueta
## Part 1 - Obtención de información

En esta lección veremos cómo obtener la información más relevante de los equipos utilizando herramientas de automatización

En primer lugar, verificamos el estado de adyacencias ospf en los diferentes routers:
* `ios11`:
```
show ip ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios11', this)">Run this snippet</button>

* `ios21`:
```
show ip ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios21', this)">Run this snippet</button>

* `vqfx31`:
```
show ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx31', this)">Run this snippet</button>


Una vez verificadas las adyacencias verificamos la tabla de rutas de los diferentes equipos.

* `ios11`

```
show ip route 
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios11', this)">Run this snippet</button>

* `ios21`

```
show ip route 
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios21', this)">Run this snippet</button>


* `vqfx31`

```
show route | no-more
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx31', this)">Run this snippet</button>

