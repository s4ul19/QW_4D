# SFF del caminante bidimensional con moneda CUE(4)

Resultado universal esperado bajo la hipótesis de caos en clase unitaria:
`K(t) ≈ min(t / D, 1)`, con `D = 4N` y `t > 0`, después del régimen no universal.
El promedio exacto sobre la moneda homogénea no sigue esa fórmula a todos los tiempos.

- `derivacion_sff_cue.tex`: nota autónoma en español, compilada con el editor LaTeX de Codex.
- `sff_cue_2d.png` y `.svg`: SFF físico y contribuciones de tiempos cortos.
- `calcular_sff.py`: geometría, shift reflectivo, monedas Haar, eigenfases, momentos exactos y validación.
- `graficar_sff.py`: figura a partir de los dos tamaños guardados.
- `desplegar_sff.py`: diagnóstico separado con unfolding positivo de Fejér; 8 y 16 armónicos.
- `sinai_L16_R12/` y `sinai_L24_R18/`: CSV, resúmenes y archivos NPZ con todas las monedas, fases y realizaciones.
- `diagnostico_unfolding.json`: resultados del observable desplegado, separado del SFF físico.

La moneda se fija durante cada realización y se aplica en todos los sitios.
El dominio es el de `GenerateSinaiBasis`: `0 <= y <= x <= L`, fuera del disco.
Es un dominio con frontera propia; no se presupone una reducción por simetría para una moneda genérica.
Se replica la reflexión local de `BuildShiftOperators4State`.
No se alteraron el PDF, su fuente, los cuadernos ni las bibliotecas originales.

## Reproducir

El cálculo necesita NumPy. La figura necesita Matplotlib. Desde la carpeta de esta nota:

```sh
python calcular_sff.py --L 16 --R 12 --samples 128 --seed 20260930 --validate
python calcular_sff.py --L 24 --R 18 --samples 64 --seed 20260931
python desplegar_sff.py
python graficar_sff.py
```

En este equipo el cálculo se ejecutó con el Python del runtime de Codex, que incluye NumPy;
la figura se generó con `/opt/miniconda3/bin/python`, que incluye Matplotlib.

Los errores de las bandas y bloques temporales se estiman entre monedas después de
promediar los tiempos dentro de cada realización. Los archivos de fases originales
no se reemplazan por niveles desplegados. Las desviaciones observadas frente a CUE
son mayores que los errores estándar y no se presentan como una demostración de
convergencia a CUE.

La función `QWSFF` original usa la referencia COE con índice 1. La referencia
correspondiente a este caso es CUE, índice 2; la nota incluye la expresión directa
para el SFF físico en Wolfram, sin modificar esa función.
