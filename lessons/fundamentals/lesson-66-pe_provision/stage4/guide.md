# Troubleshooting

## Ticket 02: fallo de conectividad con del site 1 con el site 4

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
|ios1|ok|ok|**X**|
|ios2|ok|ok|**X**|
|ios4|ok|ok|ok|

* Conectividad en L3VPN

|equipo|ios1 l3vpn|Ios2 l3vpn|ios4 l3vpn|ce1 local|ce2 local|ce4 local|ce1 lbk|ce2 lbck|ce4lbk|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|ios1 l3vpn|ok|ok|**X**|ok|n/a|n/a|ok|ok|**X**|
|ios2 l3vpn|ok|ok|**X**|n/a|ok|n/a|ok|ok|**X**|
|ios4 l3vpn|**X**|**X**|ok|n/a|n/a|ok|**X**|**X**|ok|

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
|ios4|ok|ok|ok|



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