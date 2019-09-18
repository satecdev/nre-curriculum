# Configuración de maqueta
## Part 1 - Obtención de información

En esta lección veremos cómo obtener la información más relevante de los equipos utilizando herramientas de automatización

En primer lugar, verificamos el estado de adyacencias ospf en los diferentes routers:
* `ios1`:
```
show ip ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios1', this)">Run this snippet</button>

* `ios2`:
```
show ip ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios2', this)">Run this snippet</button>

* `vqfx3`:
```
show ospf neighbor
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('vqfx3', this)">Run this snippet</button>

