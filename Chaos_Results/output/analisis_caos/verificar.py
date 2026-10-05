"""Auditoría local reproducible; sólo lee los datos originales. Requiere NumPy."""
from pathlib import Path
import importlib.util
import json
import numpy as np

ROOT = Path('/Users/saul/Desktop/ChatGPT/QWProgramming')
spec = importlib.util.spec_from_file_location('sff', ROOT/'analisis/sff_cue_2d/calcular_sff.py')
sff = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sff)

def norm(a):
    return float(np.linalg.norm(a))

def ratio(ph):
    ph = np.sort(np.mod(ph, 2*np.pi))
    gaps = np.diff(np.r_[ph, ph[0]+2*np.pi])
    other = np.roll(gaps, -1)
    return float(np.mean(np.minimum(gaps, other)/np.maximum(gaps, other)))

out = {}
data = np.genfromtxt(ROOT/'analisis/estados_borde/espectro_seed23_L30.csv', delimiter=',', names=True)
out['oo_rectangulo_guardado'] = {'D':len(data), 'mean_r':ratio(data['Energy']),
    'boundary_candidates': int(np.sum(data['BoundaryWeight'] >= .6))}
for name in ['sinai_L16_R12','sinai_L24_R18']:
    z = np.load(ROOT/'analisis/sff_cue_2d'/name/'datos_sff.npz')
    rr = np.array([ratio(ph) for ph in z['phases']])
    out[name] = {'D': int(z['phases'].shape[1]), 'samples': len(rr),
        'mean_r':float(rr.mean()), 'SE_between_coins':float(rr.std(ddof=1)/np.sqrt(len(rr))),
        'max_difference_from_saved_ratios':float(np.max(np.abs(rr-z['ratios'])))}

# Rectángulo pequeño: nx, ny cuentan sitios, no coordenadas máximas.
nx, ny = 7, 5
coords = np.array([(x,y) for x in range(nx) for y in range(ny)])
dest, _ = sff.reflecting_shift(coords)
D = len(dest)
shift = np.zeros((D,D),complex)
shift[dest,np.arange(D)] = 1
rng = np.random.default_rng(20261004)
theta = rng.uniform(-np.pi,np.pi,4)
p = np.diag(np.exp(1j*theta))
u = sff.evolution(p,dest)
eig = np.linalg.eigvals(u)
vph = (theta[0]+theta[1])/2 + np.pi*np.arange(2*ny)/ny
hph = (theta[2]+theta[3])/2 + np.pi*np.arange(2*nx)/nx
pred = np.r_[np.repeat(np.exp(1j*vph),nx),np.repeat(np.exp(1j*hph),ny)]
err = float(np.max(np.abs(np.sort(np.angle(eig))-np.sort(np.angle(pred)))))
assert err < 1e-10
out['p_formula_exacta'] = {'nx':nx,'ny':ny,'D':D,'max_phase_error':err,
    'generic_distinct_eigenvalues':2*(nx+ny),
    'generic_zero_spacing_fraction':1-2*(nx+ny)/D}

# Conjugación de una MISMA moneda: conserva espectro local pero no el global.
v = sff.haar_coin(rng)
cp = v@p@v.conj().T
up = sff.evolution(cp,dest)
out['conjugacion_moneda'] = {
    'coin_max_phase_error':float(np.max(np.abs(np.sort(np.angle(np.linalg.eigvals(cp)))-np.sort(theta)))),
    'abs_trace_U_squared_p':float(abs(np.trace(u@u))),
    'abs_trace_U_squared_VpVdagger':float(abs(np.trace(up@up)))}

# P invierte sólo posición: P S P = S^dagger en el rectángulo.
mapping = {tuple(x):i for i,x in enumerate(coords)}
inv = np.array([4*mapping[(nx-1-x,ny-1-y)]+c for x,y in coords for c in range(4)])
P = np.zeros((D,D),complex)
P[inv,np.arange(D)] = 1
assert norm(P@shift@P-shift.conj().T) < 1e-12
q = sff.haar_coin(rng)
c = q@q.T
C = np.kron(np.eye(len(coords)),c)
U = shift@C
# Theta = Q K, Q=C^dagger P; prueba de reversión temporal en la base física.
Q = C.conj().T@P
out['simetria_antiunitaria_rectangulo_C_simetrica'] = {
    'coin_symmetry_error':norm(c-c.T),
    'PSP_minus_Sdagger':norm(P@shift@P-shift.conj().T),
    'Theta_squared_minus_identity':norm(Q@Q.conj()-np.eye(D)),
    'Theta_U_Theta_inverse_minus_Udagger':norm(Q@U.conj()@Q.conj().T-U.conj().T)}
assert out['simetria_antiunitaria_rectangulo_C_simetrica']['Theta_U_Theta_inverse_minus_Udagger'] < 1e-10
target = Path(__file__).with_name('verificacion.json')
target.write_text(json.dumps(out, indent=2)+'\n')
print(json.dumps(out,indent=2))
