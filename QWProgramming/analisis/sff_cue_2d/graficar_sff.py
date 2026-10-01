"""Genera la figura del SFF a partir de las realizaciones guardadas."""

from pathlib import Path
import os

os.environ.setdefault("MPLCONFIGDIR", "/private/tmp/qw_sff_matplotlib")
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

BASE = Path(__file__).resolve().parent
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11,
                     "axes.spines.top": False, "axes.spines.right": False,
                     "axes.titleweight": "bold"})

datasets = [np.load(BASE/"sinai_L16_R12"/"datos_sff.npz"),
            np.load(BASE/"sinai_L24_R18"/"datos_sff.npz")]
colors = ("#146bba", "#de6c27")
labels = ("L=16, R=12; D=352; 128 monedas", "L=24, R=18; D=736; 64 monedas")

fig, axes = plt.subplots(1, 2, figsize=(13.6, 5.5), constrained_layout=True,
                         gridspec_kw={"width_ratios": [1.45, 1]})
fig.suptitle("Caminante 2D en Sinaí con moneda CUE(4)", fontsize=17, fontweight="bold")
ax = axes[0]
x = np.linspace(0, 2, 600)
ax.plot(x, np.minimum(x, 1), color="#20242b", ls="--", lw=2,
        label="Referencia CUE(D): min(τ, 1)")
for data, color, label in zip(datasets, colors, labels):
    block = data["blocks"]
    keep = block[:, 0] >= 0.08
    tau, k, se, _ = block[keep].T
    ax.plot(tau, k, color=color, lw=1.7, label=label)
    ax.fill_between(tau, k-se, k+se, color=color, alpha=0.17, lw=0)
ax.axvline(1, color="#6c737d", lw=0.8, alpha=0.6)
ax.set(xlim=(0.08, 2), ylim=(0, 1.3), xlabel="τ = t / D; D = 4N",
       ylabel="K(t) = ⟨|Tr Uᵗ|²⟩ / D", title="Rampa y aproximación a la meseta")
ax.grid(alpha=0.15)
ax.legend(loc="lower right", fontsize=9, frameon=False)
ax.text(0.04, 0.96, "Bloques ≈ 0.04D pasos\nBandas: ±1 error estándar entre monedas",
        transform=ax.transAxes, va="top", fontsize=9, color="#424b55")

ax = axes[1]
data = datasets[1]
t = data["times"][:40]
k, se = data["mean_k"][:40], data["se_k"][:40]
ax.errorbar(t, k, yerr=se, color=colors[1], fmt="o-", markersize=3.8,
            linewidth=1.15, capsize=2, label="Promedio de 64 monedas; D=736")
ax.plot(t, np.minimum(t/736,1), "--", color="#20242b", lw=1.7,
        label="CUE(D): t/D")
ax.scatter([1, 2], [0.5224184782608695, 20.09429347826087], marker="*",
           s=135, color="#662e91", zorder=10, label="Haar exacto: t=1,2")
ax.set(xlabel="t (pasos)", ylabel="K(t)", yscale="log", xlim=(0.6,40.5),
       title="Tiempos cortos: efectos del modelo")
ax.grid(alpha=0.15, which="both")
ax.legend(loc="upper right", fontsize=8.5, frameon=False)
fig.text(0.51, -0.015,
         "Misma moneda en todos los sitios y pasos. Fases originales, sin unfolding. Dominio 1/8 con reflexión local.",
         ha="center", fontsize=9, color="#424b55")
fig.savefig(BASE/"sff_cue_2d.png", dpi=180, bbox_inches="tight", facecolor="white")
fig.savefig(BASE/"sff_cue_2d.svg", bbox_inches="tight", facecolor="white")
print(BASE/"sff_cue_2d.png")
