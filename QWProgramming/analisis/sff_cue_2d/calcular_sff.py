"""SFF de una DTQW con moneda CUE(4) espacialmente homogénea y fija.

Replica GenerateSinaiBasis y BuildShiftOperators4State del repositorio.
Sólo necesita NumPy. No altera QWMisc.wl ni los datos originales.

Ejemplo: python calcular_sff.py --L 16 --R 12 --samples 128 --seed 20260930
"""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

import numpy as np

DIRECTIONS = ((0, 1), (0, -1), (1, 0), (-1, 0))
OPPOSITE = (1, 0, 3, 2)


def sinai_basis(L: int, R: int, full: bool = False) -> np.ndarray:
    if not (0 < R < L):
        raise ValueError("Se requiere 0 < R < L.")
    if full:
        coords = [(x, y) for x in range(-L, L + 1)
                  for y in range(-L, L + 1) if x*x + y*y >= R*R]
    else:
        coords = [(x, y) for x in range(L + 1)
                  for y in range(x + 1) if x*x + y*y >= R*R]
    return np.asarray(coords, dtype=int)


def reflecting_shift(coords: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """dest[source] es el índice de llegada de S; S es una permutación."""
    mapping = {tuple(v): i for i, v in enumerate(coords)}
    dest = np.empty(4 * len(coords), dtype=int)
    boundary_counts = np.zeros(4, dtype=int)
    for p, (x, y) in enumerate(coords):
        for b, (dx, dy) in enumerate(DIRECTIONS):
            target = mapping.get((x + dx, y + dy))
            if target is None:
                dest[4*p + b] = 4*p + OPPOSITE[b]
                boundary_counts[b] += 1
            else:
                dest[4*p + b] = 4*target + b
    if not np.array_equal(np.sort(dest), np.arange(len(dest))):
        raise AssertionError("El shift debe ser una permutación unitaria.")
    return dest, boundary_counts


def haar_coin(rng: np.random.Generator, size: int = 4) -> np.ndarray:
    """QR de Ginibre complejo, corrigiendo las fases de la diagonal de R."""
    z = (rng.normal(size=(size, size))
         + 1j * rng.normal(size=(size, size))) / np.sqrt(2)
    q, r = np.linalg.qr(z)
    diag = np.diag(r)
    return q * (diag / np.abs(diag))[None, :]


def evolution(coin: np.ndarray, dest: np.ndarray) -> np.ndarray:
    D = len(dest)
    if coin.shape != (4, 4) or D % 4:
        raise ValueError("Moneda o dimensión inválida.")
    # U = S (I_N x C), en orden posición x moneda.
    u = np.zeros((D, D), dtype=complex)
    for p in range(D // 4):
        u[dest[4*p:4*p+4], 4*p:4*p+4] = coin
    return u


def trace_two_coefficients(dest: np.ndarray) -> np.ndarray:
    """A[i,j,k,l]: Tr U² = sum A[i,j,k,l] C[i,j] C[k,l]."""
    a = np.zeros((4, 4, 4, 4), dtype=np.int64)
    for start in range(len(dest)):
        p, incoming = divmod(start, 4)
        for first_outgoing in range(4):
            intermediate = dest[4*p + first_outgoing]
            q, next_incoming = divmod(intermediate, 4)
            for second_outgoing in range(4):
                if dest[4*q + second_outgoing] == start:
                    a[first_outgoing, incoming,
                      second_outgoing, next_incoming] += 1
    return a


def exact_haar_short_times(dest: np.ndarray, b: np.ndarray) -> dict:
    D = len(dest)
    a = trace_two_coefficients(dest).astype(float)
    norm = np.sum(a*a)
    both = np.sum(a * a.transpose(2, 3, 0, 1))
    rows = np.sum(a * a.transpose(2, 1, 0, 3))
    cols = np.sum(a * a.transpose(0, 3, 2, 1))
    f2 = (norm + both)/15 - (rows + cols)/60
    return {"F1_exact": float(np.dot(b, b)/4),
            "K1_exact": float(np.dot(b, b)/(4*D)),
            "F2_exact": float(f2), "K2_exact": float(f2/D),
            "A_squared_norm": float(norm),
            "A_pair_swap_inner_product": float(both),
            "A_row_swap_inner_product": float(rows),
            "A_column_swap_inner_product": float(cols)}


def polynomial_trace_two(coin: np.ndarray, a: np.ndarray) -> complex:
    return np.einsum("ijkl,ij,kl->", a, coin, coin)


def validate() -> dict:
    """Comprobaciones independientes: matriz, caminos y momentos Haar."""
    rng = np.random.default_rng(73142)
    coords = sinai_basis(4, 2)
    dest, b = reflecting_shift(coords)
    coin = haar_coin(rng)
    u = evolution(coin, dest)
    a = trace_two_coefficients(dest)
    direct_t1 = sum(b[i] * coin[i, OPPOSITE[i]] for i in range(4))
    direct_t2 = polynomial_trace_two(coin, a)
    assert np.allclose(np.trace(u), direct_t1, atol=1e-12)
    assert np.allclose(np.trace(u @ u), direct_t2, atol=1e-12)
    assert np.allclose(u.conj().T @ u, np.eye(len(dest)), atol=1e-12)
    eig = np.linalg.eigvals(u)
    for t in (1, 2, 3, 5):
        assert np.allclose(np.sum(eig**t), np.trace(np.linalg.matrix_power(u, t)),
                           atol=1e-10)
    # Una única posición con cuatro reflexiones: U=P C es exactamente CUE(4).
    single_dest = np.array(OPPOSITE)
    single_exact = exact_haar_short_times(single_dest, np.ones(4, dtype=int))
    assert np.isclose(single_exact["F1_exact"], 1)
    assert np.isclose(single_exact["F2_exact"], 2)
    # Control de momentos sobre una geometría sin usar diagonalización.
    moments = np.empty((12000, 2))
    for m in range(len(moments)):
        c = haar_coin(rng)
        moments[m, 0] = abs(sum(b[i]*c[i, OPPOSITE[i]] for i in range(4)))**2
        moments[m, 1] = abs(polynomial_trace_two(c, a))**2
    ex = exact_haar_short_times(dest, b)
    expected = np.array([ex["F1_exact"], ex["F2_exact"]])
    se = moments.std(axis=0, ddof=1)/np.sqrt(len(moments))
    z = (moments.mean(axis=0)-expected)/se
    assert np.all(np.abs(z) < 5), (moments.mean(axis=0), expected, z)
    return {"unitarity_error": float(np.linalg.norm(u.conj().T@u-np.eye(len(dest)))),
            "short_time_Haar_validation_samples": len(moments),
            "short_time_Haar_validation_z_scores": z.tolist(),
            "single_position_CUE4_F1_F2": [single_exact["F1_exact"],
                                           single_exact["F2_exact"]]}


def circular_ratio(phases: np.ndarray) -> float:
    phases = np.sort(np.mod(phases, 2*np.pi))
    gaps = np.diff(np.r_[phases, phases[0]+2*np.pi])
    other = np.roll(gaps, -1)
    return float(np.mean(np.minimum(gaps, other)/np.maximum(gaps, other)))


def run(args: argparse.Namespace) -> None:
    out = Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    validation = validate() if args.validate else None
    coords = sinai_basis(args.L, args.R, args.full)
    dest, b = reflecting_shift(coords)
    exact = exact_haar_short_times(dest, b)
    D = len(dest)
    times = np.arange(1, int(args.tau_max * D)+1)
    if len(times) < 2:
        raise ValueError("tau-max debe permitir al menos los tiempos t=1 y t=2.")
    k_samples = np.empty((args.samples, len(times)))
    phases_samples = np.empty((args.samples, D))
    coins = np.empty((args.samples, 4, 4), dtype=complex)
    ratios = np.empty(args.samples)
    rng = np.random.default_rng(args.seed)
    largest_modulus_error = 0.0
    largest_coin_error = 0.0
    started = time.perf_counter()
    for m in range(args.samples):
        coin = haar_coin(rng)
        largest_coin_error = max(largest_coin_error,
                                float(np.linalg.norm(coin.conj().T@coin-np.eye(4))))
        u = evolution(coin, dest)
        eigenvalues = np.linalg.eigvals(u)
        largest_modulus_error = max(largest_modulus_error,
                                   float(np.max(np.abs(np.abs(eigenvalues)-1))))
        phases = np.angle(eigenvalues)
        # No unfolding: éstos son los tiempos físicos enteros de Tr U^t.
        for begin in range(0, len(times), 256):
            t = times[begin:begin+256]
            z = np.exp(1j*t[:, None]*phases[None, :]).sum(axis=1)
            k_samples[m, begin:begin+len(t)] = np.abs(z)**2/D
        phases_samples[m] = np.sort(phases)
        coins[m] = coin
        ratios[m] = circular_ratio(phases)
        if m == 0:
            assert np.isclose(k_samples[m, 0], abs(np.trace(u))**2/D, atol=1e-10)
            a = trace_two_coefficients(dest)
            assert np.isclose(k_samples[m, 1], abs(polynomial_trace_two(coin,a))**2/D,
                              atol=1e-10)
        if (m+1) % 16 == 0 or m+1 == args.samples:
            print(f"L={args.L} R={args.R}: {m+1}/{args.samples}; "
                  f"{time.perf_counter()-started:.1f} s", flush=True)
    mean_k = k_samples.mean(axis=0)
    se_k = k_samples.std(axis=0, ddof=1)/np.sqrt(args.samples)
    reference = np.minimum(times/D, 1)
    # Bloques disjuntos de tiempos: primero promediar cada realización.
    # Así se conserva la correlación temporal al estimar el error entre monedas.
    block_size = max(1, round(0.04*D))
    blocks = []
    for start in range(0, len(times), block_size):
        sl = slice(start, min(start+block_size, len(times)))
        block_samples = k_samples[:, sl].mean(axis=1)
        blocks.append([times[sl].mean()/D, block_samples.mean(),
                       block_samples.std(ddof=1)/np.sqrt(args.samples),
                       reference[sl].mean()])
    blocks = np.array(blocks)
    np.savez_compressed(out/"datos_sff.npz", times=times, tau=times/D,
                        k_samples=k_samples, phases=phases_samples, coins=coins,
                        mean_k=mean_k, se_k=se_k, cue_reference=reference,
                        coords=coords, dest=dest, boundary_counts=b, ratios=ratios,
                        blocks=blocks)
    np.savetxt(out/"sff.csv", np.column_stack([times, times/D, mean_k, se_k, reference]),
               delimiter=",", header="t,tau,K_mean,SE_between_coins,K_CUE", comments="")
    np.savetxt(out/"sff_bloques.csv", blocks, delimiter=",",
               header="tau_mean,K_block_mean,SE_between_coins,K_CUE_block_mean", comments="")
    summary = {"L": args.L, "R": args.R, "domain": "full" if args.full else "1/8",
               "N_sites": len(coords), "D": D, "samples": args.samples,
               "seed": args.seed, "coin": "CUE(4), misma moneda en todos los sitios y tiempos",
               "unfolding": False, "boundary_counts_up_down_right_left": b.tolist(),
               **exact, "K1_MC": float(mean_k[0]), "K1_SE": float(se_k[0]),
               "K2_MC": float(mean_k[1]), "K2_SE": float(se_k[1]),
               "mean_spacing_ratio": float(ratios.mean()),
               "SE_spacing_ratio_between_coins": float(ratios.std(ddof=1)/np.sqrt(args.samples)),
               "max_eigenvalue_modulus_error": largest_modulus_error,
               "max_coin_unitarity_error": largest_coin_error,
               "block_size_steps": block_size,
               "elapsed_seconds": time.perf_counter()-started,
               "validation": validation}
    for lo, hi in [(0.2,0.6),(0.6,1.0),(1.2,2.0)]:
        sl = (times/D >= lo) & (times/D <= hi)
        band = k_samples[:, sl].mean(axis=1)
        summary[f"band_{lo}_{hi}"] = {
            "K_mean": float(band.mean()),
            "SE_between_coins": float(band.std(ddof=1)/np.sqrt(args.samples)),
            "K_CUE_mean": float(reference[sl].mean())}
    (out/"resumen.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2)+"\n")
    print(json.dumps(summary, ensure_ascii=False, indent=2), flush=True)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--L", type=int, default=16)
    p.add_argument("--R", type=int, default=12)
    p.add_argument("--samples", type=int, default=128)
    p.add_argument("--seed", type=int, default=20260930)
    p.add_argument("--tau-max", type=float, default=2)
    p.add_argument("--full", action="store_true")
    p.add_argument("--validate", action="store_true")
    p.add_argument("--output", default=None)
    a = p.parse_args()
    if a.samples < 2 or a.tau_max <= 0:
        p.error("Se requieren al menos 2 muestras y tau-max positivo.")
    if a.output is None:
        domain_suffix = "_completo" if a.full else ""
        a.output = str(Path(__file__).parent/f"sinai_L{a.L}_R{a.R}{domain_suffix}")
    run(a)
