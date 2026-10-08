# Presentación para el Dr. Juan Luis François Lacouture

Proyecto Beamer en formato 16:9, en español. La presentación empieza
directamente con el modelo matemático y sigue con un índice navegable.

## Archivos

- `main.tex`: presentación editable y apéndice de consulta.
- `main.pdf`: presentación completa compilada.
- `presentacion_breve.pdf`: únicamente el recorrido principal.
- `Imgs/`: copias de las figuras originales utilizadas. El proyecto se puede
  mover o compartir sin depender de la carpeta original.
- `recortes.tex`: selección de paneles temporales y de eigenestados mediante
  recortes de LaTeX, conservando rótulos, ejes y escalas.
- `preparar_figuras.py`: permite actualizar las copias desde `../Imgs/`.
- `figuras.txt`: inventario de las figuras incluidas.

## Compilación

Desde esta carpeta:

```sh
make
make breve
```

También se puede compilar `main.tex` con pdfLaTeX dos veces. Se requieren
Beamer y los paquetes habituales de TeX Live/MacTeX. Para omitir el apéndice
en el PDF principal, cambiar `\apendicetrue` por `\apendicefalse` en `main.tex`.

## Recorrido

Modelo y reflexión, monedas, estadística espectral, IPR espacial,
entrelazamiento moneda-posición, promedio temporal, densidad espacial del
IPR de eigenestados y L1. Termina con las conclusiones.

Las columnas enfrentan rectángulo (izquierda) y Sinai (derecha). El orden espectral es
`g, gpg, oo, uoou, o, b, ubu, u, upu, p`. Las gráficas comparativas de IPR y
entropía conservan los colores y las leyendas de las figuras originales.

El recorrido principal tiene 35 diapositivas. Incluye la sección III.A del
artículo, «Reducción a caminatas unidimensionales», y muestra P(s), P(r) y SFF
para la moneda de Grover `g` en ambos estadios. La sección L1 muestra los
intervalos `(0,0.1)` y `(0.9,1)`, primero para rectángulo y después para Sinaí. El PDF completo tiene
además 50 diapositivas de apoyo, con los diez intervalos de L1
ordenados de menor a mayor dentro de cada geometría: primero todo el
rectángulo y después todo Sinaí. Al final del bloque espectral se incluye
una tabla de lectura cualitativa de los indicadores espectrales por geometría. El apéndice conserva
DoS para nueve monedas, P(r) y SFF para diez, y los mapas adicionales, para consultar el detalle según la
conversación.
El apéndice espectral comienza con las fórmulas de P(s), P(r) y SFF.

La segunda diapositiva es un índice con enlaces a cada sección. El enlace
«Índice» del pie permite volver a ella desde cualquier diapositiva. La
versión breve omite las entradas del apéndice.

## Precisiones sobre las fuentes

- Texto y resultados: `../main.tex` y `../Imgs/`.
- Definiciones de las nueve monedas aleatorias: `../../QWProgramming/QWMisc.wl`,
  función `RandomMatrix`. La moneda `g` es la matriz fija de Grover `G`.
  Las conjugaciones son `V C V†`.
- Regla de reflexión y orden de direcciones: implementación de
  `BuildShiftOperators4State` en `QuantumWalks/Billiards/Common.wl`.
- Se usa el orden tensorial posición ⊗ moneda, como en el código. Las notas
  originales escriben moneda ⊗ posición. Ambos se relacionan por el cambio
  de orden de los factores, siempre que se cambien los operadores de forma
  consistente.
- P(s), P(r) y SFF incluyen las diez monedas. La diapositiva P(s) de `p`
  muestra debajo `Ps_pModif`, tanto para rectángulo como para Sinai.
  Estas figuras excluyen el primer bin (96.74% y 49.61%, respectivamente)
  y muestran los espaciamientos restantes con media 1, según sus rótulos.
  DoS de `p` permanece en el apéndice; P(r) y SFF de `p` aparecen en el
  recorrido principal y en el apéndice.
- Los mapas de promedio temporal son resultados a tiempo finito. Las
  fuentes no especifican el horizonte T de esas figuras. Se define el
  límite de Cesàro sin afirmar convergencia de los mapas guardados.
- Los paneles de eigenestados no imprimen el nombre de la moneda. Por eso
  la presentación no añade una atribución que las figuras no permiten
  comprobar. Los mapas son ejemplos, no una comparación controlada a
  igual tamaño e igual eigenfase.
- Hay una discrepancia en el tamaño del Sinai de los mapas de eigenestados:
  `../main.tex` dice L=65, R=25, mientras que el panel llega hasta 60 y la
  celda correspondiente de `FunctionsTester.nb` usa L=60, R=25. La
  presentación conserva los ejes de la figura y evita repetir el tamaño
  contradictorio.
- Las líneas 2/N y 3/N del IPR y la referencia COE del SFF se conservan
  como aparecen en las figuras originales, sin convertirlas en un ajuste
  nuevo ni asignar automáticamente una clase de simetría a cada moneda.
- En las leyendas originales de IPR y entropía, las monedas se agrupan
  como «integrables» y «caóticas». Esas etiquetas se conservan como parte
  de la figura, pero la presentación no presupone que la clase espectral
  de una moneda sea independiente de la geometría. P(s) muestra diferencias
  entre rectángulo y Sinai para gpg y oo.
- En el SFF, D designa el número de niveles efectivamente analizados,
  que puede diferir de 4N si el cálculo filtra niveles o separa sectores.

La fecha de la reunión se fijó al 5 de octubre de 2026, según «mañana» en
la solicitud. Se puede editar en la primera diapositiva.
