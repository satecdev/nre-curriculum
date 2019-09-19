# Ticket 02: fallo de conectividad con del site 1 con el site 4

## Ejecución de pruebas en rundeck

Como primer paso abrimos rundeck y ejecutamos las pruebas XXX


Tras la ejecución de la prueba veamos los resultados de forma tabulada:

![stage4](https://cdn1.imggmi.com/uploads/2019/9/19/0b6cd74d901af28a7ba1532637fac7f5-full.png)


## Análisis de los resultados

Con la batería de pruebas vemos:
* `ios4`: conoce todos los prefijos.
* Los otros dos routers no conocen los prefijos de `ios4`
* No hay conectividad en la VPN desde `ios1` e `ios2` a `ios4`.

Parece que es un problema en la definición de la L3VPN.

Si verificamos en detalle los route-target de los prefijos vemos que los de `ios4`se están generando con un route target incorrecto:

```
term len 0
term mon
enable
satec
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



Esperamos a que levante la sesión BGP:

```
show bgp all summary

```
<button type="button" class="btn btn-primary btn-sm" onclick="runSnippetInTab('ios4', this)">Run this snippet</button>



Una vez levantado podemos volver a repetir las pruebas.