# QWProgramming

Desde `FunctionsTester.nb`, la primera celda carga la copia local de las
bibliotecas con `scripts/load_project.wl`. `LoadDependencies.wl` ofrece una entrada
compatible al mismo cargador. Las rutas de carga y exportación son relativas al
notebook. **JA_libs se mantiene fuera del repositorio EPS_QW y no se distribuye
con este proyecto.**

El cargador respeta `JA_LIBS_PATH` si está definida. En caso contrario busca
`JA_libs` junto al proyecto y en sus dos directorios superiores. Para
`Desktop/EPS_QW/QWProgramming`, encuentra la biblioteca externa en
`Desktop/JA_libs`. Extrae su paclet ForScience a una carpeta temporal si hace
falta y carga las fuentes locales, sin descargar ni instalar dependencias.

Para usar otra ubicación, en el kernel de Mathematica:

```wolfram
SetEnvironment["JA_LIBS_PATH" -> "/ruta/a/JA_libs"];
```

La carpeta debe contener `QuantumWalks`, `QMB` y
`ForScience-0.88.45.paclet`. También puede configurarse la variable en la terminal
antes de iniciar Mathematica. La regla `.gitignore` protege frente a la inclusión
accidental de una carpeta local `JA_libs`.

La API pública y sus ayudas usan inglés. `EntropiaMoneda` y `EjecutarEnNodo`
siguen disponibles como alias de `CoinEntanglementEntropy` y `EvaluateOnNode`.
Las opciones del proyecto son símbolos (`CoinDimension`, `Stride`, `RandomSeed`,
`InputType`, `ProbabilityScale`, `BoundaryWidth`, etc.). Las cadenas antiguas
siguen funcionando; `"FrameStride"` es un alias de `Stride`. Si se dan un símbolo
y su alias, prevalece el símbolo.

## Operador y cuasienergía

```wolfram
root = NotebookDirectory[];
Get[FileNameJoin[{root, "scripts", "load_project.wl"}]];
grid = GenerateRectangleBasis[8, 5];
coin = RandomMatrix["upu", RandomSeed -> 23];
u = QWEvolutionOperator[grid, coin];
epsilon = QWEigenphases[grid, coin];
```

La convención común es `U psi = Exp[-I epsilon] psi`, por tanto
`epsilon = -Arg[lambda]` en la rama `[-Pi, Pi]`. Los valores `-Pi` y `Pi`
representan el mismo punto; `EigenstateAtEnergy` usa distancia circular.
`QWPr` incluye el espaciamiento de cierre; se retiró `ExtraerRatiosR`.

`QWEvolutionOperator` infiere la dimensión de la moneda. Para dimensión 4
construye `S.C`, con `C = KroneckerProduct[IdentityMatrix[N], coin]`.
Para dimensión 2 construye la caminata dividida `Sy.C.Sx.C`, aplicando la moneda
antes de cada desplazamiento. El resultado conserva la representación dispersa.

## Dinámica y referencias espectrales

```wolfram
data = QWDynamicsData[grid, coin,
  RandomSeed -> 11, IPRSteps -> 200, EntropySteps -> 200,
  DistributionSteps -> 500, Stride -> 2, ReturnData -> True];
data["IPR"]       (* {{0, IPR(0)}, ..., {200, IPR(200)}} *)
data["Entropy"]   (* {{0, S(0)}, ..., {200, S(200)}} *)
data["LimitDistribution"]

sff = QWSFF[epsilon, RMTEnsembles -> {1, 2}, ReturnData -> True];
sff["RMTReferences"]["CUE"]
```

`QWDynamicsData` usa `ComputeSpatialIPREvolution`,
`ComputeEntanglementEntropyEvolution` y `LimitDistribution`. Conserva un estado
por evolución y normaliza las probabilidades. La inicialización automática
requiere un sitio interior con cuatro vecinos; en rejillas sin interior se
proporciona explícitamente el estado inicial. Las semillas explícitas preservan
el flujo aleatorio de la sesión.

IPR y entropía incluyen el tiempo cero. La IPR usa tiempo lineal y escala vertical
logarítmica; la entropía usa escalas lineales para poder mostrar valores cero.
El promedio temporal es de duración finita y muestrea `0, Stride, 2 Stride, ...`
sin incluir un último paso que no sea múltiplo de `Stride`.

El SFF muestra COE y CUE por defecto, con `RMTEnsembles` configurable entre
índices de Dyson 0, 1 y 2. Esto permite comparar referencias sin atribuir una
clase de simetría a una moneda concreta. `RMT` mantiene la serie COE de la interfaz
anterior y `RMTReferences` contiene las referencias seleccionadas.

`ComputeSurvivalProbability` calcula fidelidad normalizando ambos estados y
valida también matrices cuyas filas son los estados finales.

## Pruebas y notebooks

Los tests originales están en `tests/NotebookTests.wlt`, con fixtures pequeños e
independientes del notebook; `tests/QWMisc.wlt` añade regresiones para los cambios
y `tests/NotebookIntegrity.wlt` verifica estructura, rutas y cargadores.
La suite completa contiene 104 pruebas.
Para ejecutarlos sin interfaz:

```sh
wolframscript -file tests/run.wls
```

Si `wolframscript` no encuentra el kernel en macOS:

```sh
/Applications/Wolfram.app/Contents/MacOS/WolframKernel -noprompt -script tests/run.wls
```

En un notebook puede usarse `TestReport["tests/NotebookTests.wlt"]` desde la
carpeta del proyecto. Las celdas antiguas de tests llaman a este archivo.
`scripts/clean_notebooks.wls` borra salidas, mensajes y etiquetas de ejecución
antes de guardar cambios. Conviene cerrar o guardar los notebooks abiertos antes
de ejecutarlo, para que una sesión abierta no sobrescriba la limpieza.

Los scripts de `presentaciones/` buscan secciones por título y recuperan las
figuras guardadas. Antes de exportar, evalúa y guarda las secciones correspondientes
del notebook. Los scripts devuelven `$Failed` ante datos faltantes sin cerrar el
kernel del notebook.

## Mazinger

Los notebooks de Mazinger cargan la implementación compartida de las tareas SSH.
La ruta remota se construye en cada trabajador desde `QW_PROJECT_ROOT`; si la
variable de entorno no está definida, usa `FileNameJoin[{$HomeDirectory, "QW"}]`.
Esa carpeta debe contener `JA_libs/QuantumWalks`. Las tareas de espectro remoto
usan las funciones de JA_libs disponibles en el nodo.
