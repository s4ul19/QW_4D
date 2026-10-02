# Cuasienergias de estados concentrados en el borde

`AnalyzeBoundaryEigenstates`, `PlotBoundarySpectrum` y `EigenstateAtEnergy`
son ahora funciones publicas del paquete QWMisc. Se cargan con
`Get[FileNameJoin[{NotebookDirectory[], "scripts", "load_project.wl"}]]`
desde `FunctionsTester.nb`. El archivo anterior
`analizar_borde.wl` sigue siendo un cargador compatible del analisis de
frontera. `QWMisc/BoundarySpectrum.wl` carga el paquete; la implementación
interna vive en `QWMisc/Private/BoundarySpectrum.wl`.

El IPR espacial mide concentracion, pero no indica su posicion. Para cada
eigenvector normalizado se calcula la probabilidad espacial
`p_n(r) = Sum[Abs[psi_n(r, a)]^2, a]` y se suma en una franja exterior:
`W_n(w) = Sum[p_n(r), r con distancia al borde < w]`.

La frontera se define mediante la vecindad del shift: un sitio pertenece
a ella si falta al menos uno de sus cuatro vecinos cardinales. La distancia
cuenta pasos por sitios existentes hasta la frontera mas cercana. Asi se
incluyen fronteras internas, como el obstaculo circular del Sinai.
`BoundaryWidth -> 2` incluye los sitios de frontera (distancia 0) y sus
vecinos interiores inmediatos (distancia 1). En un rectangulo se obtienen
las mismas capas y resultados que en la primera version del analisis.

En esta biblioteca, `GenerateRectangleBasis[30, 30]` incluye las coordenadas
enteras desde 0 hasta 30: hay 31 por 31 sitios, 961 posiciones y 3844 amplitudes.
Dos capas exteriores contienen 232 posiciones. Un estado uniforme tiene
`W_n(2) = 232/961 = 0.241415...`; un peso mucho mayor indica preferencia por
esa region. La seleccion inicial `W_n(2) >= 0.6` es un criterio exploratorio,
no una definicion universal. Conviene revisar anchos y umbrales.

## Ejecutar despues de tu Eigensystem

```wolfram
Get[FileNameJoin[{NotebookDirectory[], "scripts", "load_project.wl"}]];

(* Coherente con U psi = Exp[-I epsilon] psi. *)
eigenenergies = -Arg[eigenvals];

borde = AnalyzeBoundaryEigenstates[grid, eigenvals, eigenvecs,
  BoundaryWidth -> 2, BoundaryThreshold -> 0.6];

Dataset[borde["Candidates"]]
borde["CandidateEnergies"]
PlotBoundarySpectrum[borde]
```

La funcion no recalcula el espectro. Cada fila conserva `Index`, el indice
original del eigenvector, incluso despues de ordenar por cuasienergia.
`Energy` usa la convencion `lambda = Exp[-I epsilon]`, por lo que es
`-Arg[lambda]`. Si antes se usaba `Arg[eigenvals]`, todos los signos cambian.
[Documentacion de Arg](https://reference.wolfram.com/language/ref/Arg.html).

`BoundaryWeight` suma probabilidad en las capas exteriores. `CornerWeight`
suma probabilidad en cuatro cuadrados de `CornerWidth` por `CornerWidth`
sitios, uno por esquina (valor inicial: 3). Son dos regiones distintas y
sus pesos no deben sumarse: se superponen. `IPR` es el IPR espacial del
estado normalizado. `MeanBoundaryDistance` es la distancia media al
contorno, en pasos del grafo. `CornerWeight` y `UniformCornerWeight` se
devuelven como `Missing["NotApplicable"]` para geometria no rectangular;
`CornerWidth` solo se utiliza en rectangulos completos.

Un peso alto en las esquinas sugiere concentracion en ellas. Un estado
puede ocupar varias esquinas simultaneamente. Para distinguirlo de uno
extendido por los lados hay que inspeccionar tambien su mapa espacial.
La concentracion espacial por si sola no establece el origen topologico
del estado.

## Visualizar un candidato

Para buscar por cuasienergia, entrega explicitamente los eigenpares:

```wolfram
result = EigenstateAtEnergy[0.2, eigenvals, eigenvecs];
result["Energy"]
result["Distance"]
DiscreteProbabilityPlot[grid, result["State"],
  InputType -> "State", ImageSize -> Large]
```

La funcion selecciona el estado mas cercano de la lista suministrada,
usando distancia angular (identifica `-Pi` con `Pi`). No necesita la variable
global `eigenenergies`, ni calcula nuevamente los eigenpares. Devuelve
`Index`, `Energy`, `Distance`, `State` normalizado e `IPR` espacial.
Si hay un empate, devuelve el primer indice. La dimension de moneda
predeterminada es 4; para otra dimension usa la opcion simbólica
`CoinDimension -> 2`, por ejemplo. La busqueda no filtra estados de borde;
para inspeccionar uno de ellos se puede usar una energia de
`borde["CandidateEnergies"]`.

Si el kernel ya contiene las antiguas funciones en el contexto global, definidas
en un notebook o por el cargador anterior, ejecuta esta celda de carga una
vez para evitar que intercepten las funciones publicas nuevas. Conserva
las variables `grid`, `eigenvals` y `eigenvecs`:

```wolfram
Quiet[Remove["Global`AnalyzeBoundaryEigenstates",
  "Global`PlotBoundarySpectrum", "Global`EigenstateAtEnergy"], Remove::rmnsm];
Get[FileNameJoin[{NotebookDirectory[], "scripts", "load_project.wl"}]];
```

Despues ejecuta la celda de analisis o seleccion. La celda de carga se
ejecuta separadamente, para que los nombres de las nuevas funciones se
resuelvan al evaluar las siguientes celdas.

```wolfram
If[borde["Candidates"] =!= {},
  candidato = First[MaximalBy[borde["Candidates"], #["BoundaryWeight"] &]];
  DiscreteProbabilityPlot[grid, eigenvecs[[candidato["Index"]]],
    InputType -> "State",
    PlotLabel -> Row[{"epsilon = ", candidato["Energy"],
      "; peso de borde = ", candidato["BoundaryWeight"]}],
    ImageSize -> Large]
]
```

Para elegir otro, usa una fila de `borde["Candidates"]` y su `Index`.
Los indices del CSV pertenecen a la diagonalizacion que genero ese CSV;
el analisis sobre tus eigenvectores actuales da los indices de tu sesion.

## Alcance y comprobacion

Se requiere una rejilla finita de coordenadas enteras distintas, con
cualquier orden de `grid["Coords"]`, y amplitudes consecutivas de moneda
en cada sitio. Se admiten rectangulos, Sinai y otras geometrías con esta
misma vecindad de cuatro direcciones.
La funcion comprueba dimensiones y normaliza cada vector. Tambien admite
un subconjunto de eigenpares correspondientes.

Se verificaron el signo y el orden de las energias, la distincion entre
concentracion central, lateral y de esquina, la invariancia al reescalar
el vector, el peso de un estado uniforme, los indices originales y la
seleccion vacia. No se requiere establecer un umbral de IPR para detectar
concentracion en el borde.

En un subespacio exactamente degenerado, las combinaciones que devuelve
Eigensystem pueden mezclar estados con distintas distribuciones espaciales.
Si esto ocurre, se puede diagonalizar el proyector de borde dentro de ese
subespacio usando una base ortonormal.

## Sinai

En esta biblioteca `GenerateSinaiBasis[L, R]` recibe la semilongitud del
cuadrado y el radio del obstaculo, no ancho y alto. Genera el dominio de
un octavo `0 <= y <= x <= L`, con `x^2 + y^2 >= R^2`.
`GenerateFullSinaiBasis[L, R]` genera el dominio completo.

El analisis incluye toda la frontera del dominio empleado por el shift:
el arco del obstaculo, la pared `x = L` y los cortes `y = 0` y `y = x`.
Estos dos ultimos se tratan como paredes reflectivas en este operador;
la rutina no presupone una reduccion de simetria del operador completo.

Si ya calculaste los eigenpares del Sinai, solo recarga la funcion:

```wolfram
Get[FileNameJoin[{NotebookDirectory[], "scripts", "load_project.wl"}]];
borde = AnalyzeBoundaryEigenstates[grid, eigenvals, eigenvecs,
  BoundaryWidth -> 2, BoundaryThreshold -> 0.7];
If[AssociationQ[borde],
  Column[{Dataset[borde["Candidates"]], borde["CandidateEnergies"],
    PlotBoundarySpectrum[borde]}]
]
```

No es necesario repetir `Eigensystem`. `borde["UniformBoundaryWeight"]`
da la fraccion geometrica correspondiente a la nueva rejilla; no se
debe reutilizar el 24.1% del ejemplo rectangular.

Para `GenerateSinaiBasis[60, 45]` se verificaron 1059 sitios, 135 sitios
de frontera y 262 sitios en las dos primeras capas; la referencia uniforme
es `262/1059 = 0.247403...`. La deteccion de frontera se contrasto con las
desigualdades que definen la region. Tambien se comprobaron una frontera
interna con un agujero de un sitio, las distancias de todas sus capas,
los eigenpares de un Sinai pequeno y las comprobaciones del rectangulo
de la version anterior. No se repitio la diagonalizacion de tu Sinai grande.

## Archivos del ejemplo numerico

- `espectro_seed23_L30.csv`: todos los eigenestados y sus medidas.
- `candidatos_seed23_L30.csv`: las filas con `BoundaryWeight >= 0.6`.
- `resumen_seed23_L30.json`: moneda usada, parametros y errores numericos.
- `borde_seed23_L30.png` y `.svg`: peso de borde e IPR frente a cuasienergia.

La moneda se reproduce con `SeedRandom[23]` y el producto de Kronecker de
dos muestras independientes de `CircularOrthogonalMatrixDistribution[2]`,
la definicion de `RandomMatrix["oo"]` en `QWMisc.wl`.

Se obtuvieron 44 candidatos con dos capas y umbral 0.6. Algunos de los
estados de mayor concentracion aparecen alrededor de las cuasienergias
`-2.315950874`, `-0.190274582`, `0.825641781` y `2.951318073`.
Los pesos de borde de estos ejemplos son aproximadamente 0.951, 0.941,
0.941 y 0.951. Hay parejas de energias muy cercanas, conservadas por
separado en el CSV.

Los candidatos se agrupan en los siguientes rangos; estos extremos no
representan intervalos continuos en los que toda energia sea un eigenvalor:

| Cuasienergia minima | Cuasienergia maxima | Cantidad |
| ---: | ---: | ---: |
| -2.473877 | -2.276828 | 10 |
| -0.358080 | -0.006758 | 12 |
| 0.642126 | 0.993448 | 12 |
| 2.912195 | 3.109244 | 10 |

Con el mismo umbral 0.6 aparecen 8 candidatos usando una capa y 118 usando
tres capas. Esta sensibilidad muestra por que la franja debe elegirse
y documentarse junto con el criterio de seleccion.

La diagonalizacion se realizo con Wolfram 15.0.1. El error maximo de modulo
de los eigenvalores respecto a 1 fue `4.53*10^-14`; el residuo maximo
`Norm[U psi_n - lambda_n psi_n]` de los 22 eigenpares inspeccionados
(algunos indices se repiten) fue `6.29*10^-14`.
