"""Diagnóstico separado del SFF de niveles desplegados, sin alterar Tr U^t.

La densidad se suaviza con Fejér (positiva), con 8 y 16 armónicos. Se calculan
ambos para evaluar sensibilidad. La variable t aquí es un índice de Fourier
de las fases desplegadas; no es el tiempo físico del operador original.
"""

from pathlib import Path
import json
import numpy as np

BASE = Path(__file__).resolve().parent


def fejer_unfold(phases: np.ndarray, harmonics: int) -> np.ndarray:
    theta = np.asarray(phases)
    n = np.arange(1, harmonics+1)
    w = 1-n/(harmonics+1)
    cos_moments = np.cos(n[:, None]*theta[None, :]).mean(axis=1)
    sin_moments = np.sin(n[:, None]*theta[None, :]).mean(axis=1)
    cumulative = (theta+np.pi)/(2*np.pi) + (
        (w/n)[:, None] * (
            cos_moments[:, None]*np.sin(n[:, None]*theta[None, :])
            + sin_moments[:, None]*((-1.0)**n[:, None]
                                     - np.cos(n[:, None]*theta[None, :]))
        )).sum(axis=0)/np.pi
    assert np.all(np.diff(cumulative) > 0)
    assert np.all((cumulative >= 0) & (cumulative <= 1))
    return 2*np.pi*cumulative-np.pi


if __name__ == "__main__":
    summaries = {}
    for dirname in ("sinai_L16_R12", "sinai_L24_R18"):
        data = np.load(BASE/dirname/"datos_sff.npz")
        times, tau = data["times"], data["tau"]
        D = len(data["coords"])*4
        result = {}
        arrays = {}
        for h in (8, 16):
            k = np.empty_like(data["k_samples"])
            for m, phases in enumerate(data["phases"]):
                unfolded = fejer_unfold(phases, h)
                for start in range(0,len(times),256):
                    tt = times[start:start+256]
                    z = np.exp(1j*tt[:,None]*unfolded[None,:]).sum(axis=1)
                    k[m,start:start+len(tt)] = np.abs(z)**2/D
            arrays[f"k_samples_h{h}"] = k
            arrays[f"mean_k_h{h}"] = k.mean(axis=0)
            result[f"harmonics_{h}"] = {}
            for lo,hi in [(0.2,0.6),(0.6,1.0),(1.2,2.0)]:
                sl = (tau >= lo) & (tau <= hi)
                band = k[:,sl].mean(axis=1)
                result[f"harmonics_{h}"][f"band_{lo}_{hi}"] = {
                    "K_mean": float(band.mean()),
                    "SE_between_coins": float(band.std(ddof=1)/np.sqrt(len(band))),
                    "K_CUE_mean": float(np.minimum(tau[sl],1).mean())}
        np.savez_compressed(BASE/dirname/"sff_desplegado.npz", tau=tau,times=times,**arrays)
        summaries[dirname] = result
    (BASE/"diagnostico_unfolding.json").write_text(json.dumps(summaries,indent=2)+"\n")
    print(json.dumps(summaries,indent=2))
