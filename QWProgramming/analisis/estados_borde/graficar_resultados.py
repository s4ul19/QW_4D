"""Figura cientifica a partir del espectro guardado; no recalcula eigenvectores."""
import csv
import json
import os
from pathlib import Path

os.environ.setdefault("MPLCONFIGDIR", "/private/tmp/qw_boundary_check/matplotlib")
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

base = Path(__file__).resolve().parent
with (base / "espectro_seed23_L30.csv").open() as f:
    records = list(csv.DictReader(f))
with (base / "resumen_seed23_L30.json").open() as f:
    summary = json.load(f)

energy = np.array([float(row["Energy"]) for row in records])
weight = np.array([float(row["BoundaryWeight"]) for row in records])
ipr = np.array([float(row["IPR"]) for row in records])
threshold = summary["BoundaryThreshold"]
selected = weight >= threshold

plt.rcParams.update({"font.size": 11, "axes.spines.top": False,
                     "axes.spines.right": False, "svg.fonttype": "none"})
fig, (ax, bx) = plt.subplots(2, 1, figsize=(10.5, 7.2), sharex=True,
                             layout="constrained")
fig.suptitle("Estados con probabilidad concentrada en el borde\n"
             "Semilla 23 · rectángulo de 31 × 31 sitios · "
             r"$\lambda_n=e^{-i\epsilon_n}$", fontsize=15)
for panel, values in ((ax, weight), (bx, ipr)):
    panel.scatter(energy[~selected], values[~selected], s=4,
                  color="#9aa5b1", alpha=0.65, linewidths=0,
                  label="Otros estados")
    panel.scatter(energy[selected], values[selected], s=13,
                  color="#d63b32", linewidths=0,
                  label=f"Candidatos: {selected.sum()} estados")
    panel.grid(axis="y", color="#dddddd", linewidth=0.7, alpha=0.75)
    panel.set_xlim(-np.pi, np.pi)
ax.axhline(threshold, color="#d63b32", linestyle="--", linewidth=1,
           label=f"Umbral: {threshold:.0%}")
ax.axhline(summary["UniformBoundaryWeight"], color="#344454",
           linestyle=":", linewidth=1.3,
           label=f"Estado uniforme: {summary['UniformBoundaryWeight']:.1%}")
ax.set_ylim(-0.025, 1.025)
ax.set_ylabel(r"Peso en el borde $W_n$" + "\n(dos capas exteriores)")
ax.legend(loc="lower center", bbox_to_anchor=(0.5, 1.01),
          ncol=4, frameon=False, fontsize=9)
bx.set_ylim(0, 1.08 * ipr.max())
bx.set_ylabel("IPR espacial")
bx.set_xlabel(r"Cuasienergía $\epsilon_n=-\mathrm{Arg}(\lambda_n)$")
bx.set_xticks([-np.pi, -2, -1, 0, 1, 2, np.pi],
              [r"$-\pi$", "−2", "−1", "0", "1", "2", r"$\pi$"])
fig.savefig(base / "borde_seed23_L30.png", dpi=180)
fig.savefig(base / "borde_seed23_L30.svg")
plt.close(fig)
print(f"Figura: {selected.sum()} candidatos de {energy.size} eigenestados.")
