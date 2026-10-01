# Recursos y diagonalizaciones en Mazinger

Mediciones del 30 de septiembre de 2026. La disponibilidad de RAM y carga cambian con los trabajos de otros usuarios.

## Hardware y disponibilidad

| Nodo | Núcleos físicos / hilos | RAM total GiB | Disponible GiB | Carga de 1 minuto |
|---|---:|---:|---:|---:|
| nodo1 | 20 / 20 | 31.1 | 25.7 | 0.00 |
| nodo2 | 20 / 40 | 31.0 | 19.8 | 4.20 |
| nodo3 | 16 / 32 | 125.5 | 80.9 | 31.07 |
| nodo4 | 8 / 16 | 62.5 | 60.5 | 0.06 |

Los hilos de Hyper-Threading no equivalen a núcleos físicos adicionales. Nodo3 estaba ocupado; conviene consultar la carga antes de usarlo. No se encontraron squeue, sinfo o qstat en PATH; esto no descarta otras políticas de asignación.

## Kernels y límites

Los kernels son procesos que se lanzan al pedirlos. Wolfram reportó Infinity para $MaxLicenseProcesses y $MaxLicenseSubprocesses en los cuatro nodos. Esto no autoriza usar recursos ilimitados. Los límites consultados del usuario no impusieron un máximo finito de memoria ni de CPU. Todos los procesos comparten la RAM del nodo; no hay una porción fija por kernel.

El subkernel de la prueba en nodo4 reportó un hilo MKL y un hilo paralelo. Los kernels principales tienen ajustes distintos; no debe suponerse que cada proceso siempre usa un solo núcleo.

## Mediciones con QuantumWalks

Operador de evolución rectangular con moneda unitaria aleatoria 4 × 4, precisión máquina compleja, matriz densa empacada y todos sus autovalores. GenerateRectangleBasis[a-1,b-1] genera a × b posiciones. La dimensión del operador es N = 4ab.

| Rectángulo de posiciones | N | Tiempo Eigenvalues s | Pico RSS MiB |
|---|---:|---:|---:|
| 10 × 10 | 400 | 0.39 | 213.3 |
| 16 × 16 | 1024 | 4.15 | 247.1 |
| 20 × 20 | 1600 | 11.21 | 328.5 |
| 24 × 24 | 2304 | 30.02 | 414.0 |

Cada resultado tuvo N autovalores numéricos. Los trabajos se ejecutaron secuencialmente en el mismo subkernel: RSS es el máximo acumulado del proceso e incluye bibliotecas. Se conservó la matriz densa mientras se calcularon los autovalores. El tiempo excluye conexión e inicialización. No se probaron tamaños superiores a 2304.

## Planificación provisional

Una matriz compleja de precisión máquina ocupa aproximadamente 16 N² bytes. La diagonalización necesita memoria adicional. Para planificar inicialmente proponemos reservar por proceso M(N) = 0.5 GiB + 96 N² bytes. Es una estimación con margen a partir de estas pruebas; no es una cota garantizada. Otros cálculos, precisiones o paquetes pueden consumir más.

| N | Reserva provisional por proceso GiB | Dos procesos GiB |
|---|---:|---:|
| 2304 | 0.97 | 1.95 |
| 4000 | 1.93 | 3.86 |
| 8000 | 6.22 | 12.44 |
| 10000 | 9.44 | 18.88 |

La concurrencia k requiere aproximadamente k M(N), más el kernel principal y otros procesos. Como precaución inicial puede emplearse como presupuesto la mitad de la RAM disponible, siempre sujeto a la asignación que indique el administrador. Esa mitad no es una cuota reservada. Evitar swap para diagonalizaciones.

Recomendación inicial: nodo4, dos kernels, tamaños ya medidos; aumentar a cuatro solo con CPU y RAM disponibles y la asignación del administrador. En nodo1 también hay margen para una prueba inicial de dos kernels. Nodo2 tiene menos RAM disponible y nodo3 estaba muy ocupado. No se ha medido cuál concurrencia maximiza rendimiento.

La lista puede contener muchas realizaciones: con k kernels solo se ejecutan hasta k trabajos simultáneos y los demás esperan. ParallelMap distribuye matrices independientes; no divide una diagonalización entre los kernels. Retornar solamente los autovalores reduce el volumen de resultados.

El coste de todos los autovalores de una matriz densa crece aproximadamente como N³: duplicar N puede multiplicar el tiempo por ocho y la memoria por cuatro. Si solo se requiere parte del espectro, estudiar Eigenvalues con una cantidad solicitada y métodos para matrices dispersas.

## Consulta manual

Desde el Mac, para cada nodo:

```sh
ssh robot 'ssh nodo4 '''hostname; free -h; uptime''''
```

Para observar procesos propios desde el nodo:

```sh
ps -u "$USER" -o pid,comm,%cpu,rss --sort=-rss
```

RSS se expresa en KiB. Se realizaron consultas y cálculos temporales; no se modificó la configuración del cluster.

Referencias: [Eigenvalues](https://reference.wolfram.com/language/ref/Eigenvalues.html), [rendimiento de álgebra lineal](https://reference.wolfram.com/language/tutorial/LinearAlgebraPerformance.html).
