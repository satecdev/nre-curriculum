# Ticket 02: fallo de conectividad con del site 1 con el site 4

## Ejecución de pruebas en rundeck

Se ejecutan las mismas pruebas que en el ticket anterior.


El resultado de la ejecución del trabajo se muestra a continuación de forma tabulada.

![stage2](https://raw.githubusercontent.com/satecdev/nre-curriculum/satec-lesson-66-pe_provision/lessons/fundamentals/lesson-66-pe_provision/resources/images/stage4-tshoot.png)


## Análisis de los resultados

Con la batería de pruebas vemos:
* `ios4`: conoce todos los prefijos.
* Los otros dos routers no conocen los prefijos de `ios4`
* No hay conectividad en la VPN desde `ios1` e `ios2` a `ios4`.

Parece que es un problema en la definición de la L3VPN.

Si verificamos en detalle los route-target de los prefijos vemos que los de `ios4` se están generando con un route target incorrecto. `65002:1` en vez de `65001`:

```
enable
satec
term len 0
term mon
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

```
show run vrf L3VPN

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>

Corregimos el route-target y repetimos las pruebas (para acelerar el update del prefijo reiniciamos bgp):

```

conf t
vrf definition L3VPN
 address-family ipv4
  no route-target export 65002:1
  route-target export 65001:1
end
clear ip bgp *
wr

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>



Esperamos a que levante la sesión BGP y verificamos el prefijo.

```
show bgp all summary
show bgp vpnv4 unicast vrf L3VPN 30.0.0.4
```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>



Una vez levantado podemos volver a repetir las pruebas.