"""Verificación independiente, NumPy; ejecutar: python3 verificar.py."""
import json
from pathlib import Path
import numpy as np

RNG = np.random.default_rng(271828)
DELTA = [(1,0),(-1,0),(0,1),(0,-1)]  # R,L,U,D
G = np.ones((4,4))/2-np.eye(4)


def build(C, coords):
    coords = sorted(coords)
    index = {v:i for i,v in enumerate(coords)}
    n = len(coords)
    S = np.zeros((4*n,4*n), complex)
    Adj = np.zeros((n,n))
    for v,i in index.items():
        for c,(dx,dy) in enumerate(DELTA):
            w = (v[0]+dx,v[1]+dy)
            if w in index:
                j = index[w]
                S[4*j+c,4*i+c] = 1
                Adj[i,j] = 1
            else:
                S[4*i+(c^1),4*i+c] = 1
    return S @ np.kron(np.eye(n),C), S, Adj


def multiset_error(a,b):
    remaining = list(b)
    errs = []
    for x in a:
        k = int(np.argmin(np.abs(np.asarray(remaining)-x)))
        errs.append(abs(x-remaining.pop(k)))
    assert not remaining
    return float(max(errs,default=0))


def grover_check(coords):
    U,S,A = build(G,coords)
    n = len(A); e = int(A.sum()/2)
    D = (A+np.diag(4-A.sum(axis=1)))/4
    tau,f = np.linalg.eigh(D)
    assert abs(tau[-1]-1)<1e-12 and (n==1 or tau[-2]<1-1e-10)
    F = np.kron(np.eye(n),np.array([[0,1,0,0],[1,0,0,0],[0,0,0,1],[0,0,1,0]]))
    K = S@F
    Q = np.kron(np.eye(n),np.array([1,1,-1,-1])[:,None]/2)
    assert np.linalg.norm(K@K-np.eye(4*n))<1e-13
    assert np.linalg.norm(Q.conj().T@K@Q-D)<1e-13
    assert np.linalg.norm(U-K@(np.eye(4*n)-2*Q@Q.conj().T))<1e-13
    expected = [1.]*(3*n-e)+[-1.]*(e-n+2)
    max_res = 0.
    for j,t in enumerate(tau[:-1]):
        for s in [-1,1]:
            lam = -t+s*1j*np.sqrt(max(0,1-t*t))
            expected.append(lam)
            psi = Q@f[:,j]+lam*K@Q@f[:,j]
            psi /= np.linalg.norm(psi)
            max_res = max(max_res,np.linalg.norm(U@psi-lam*psi))
    ev = np.linalg.eigvals(U)
    assert len(expected)==4*n
    err = multiset_error(expected,ev)
    assert err<1e-11 and max_res<1e-11
    assert sum(abs(ev-1)<1e-8)==3*n-e
    assert sum(abs(ev+1)<1e-8)==e-n+2
    return dict(sites=n,edges=e,spectral_error=err,vector_residual=float(max_res))


def vertical_shift(m):
    V = np.zeros((2*m,2*m))
    for y in range(m):
        V[y+1 if y+1<m else m+y,y] = 1
        V[m+y-1 if y else y,m+y] = 1
    return V


def transfer(C,m,lam):
    I = np.eye(m)
    CC = np.kron(C,I)
    V = vertical_shift(m)
    E = lam*np.eye(2*m)-V@CC[2*m:,2*m:]
    if np.linalg.cond(E)>1e9:
        return None
    K = CC[:2*m,:2*m]+CC[:2*m,2*m:]@np.linalg.solve(E,V@CC[2*m:,:2*m])
    a,b,c,d = K[:m,:m],K[:m,m:],K[m:,:m],K[m:,m:]
    if np.linalg.cond(d)>1e9:
        return None
    dc = np.linalg.solve(d,c); di = np.linalg.solve(d,I)
    T = np.block([[(a-b@dc)/lam,b@di],[-dc,lam*di]])
    return T,E,CC,V


def transfer_check(C,n,m):
    U,_,_ = build(C,[(x,y) for x in range(n) for y in range(m)])
    vals,vecs = np.linalg.eig(U)
    worst = 0.; skipped = 0
    for k,lam in enumerate(vals):
        data = transfer(C,m,lam)
        if data is None:
            skipped += 1
            continue
        T,E,CC,V = data
        original = vecs[:,k].reshape(n,m,4)
        r = original[0,:,0]
        if np.linalg.norm(r)<1e-10:
            skipped += 1
            continue
        w = np.concatenate([r,r])
        psi = np.zeros((n,m,4),complex)
        for x in range(n):
            wn = T@w
            h = np.concatenate([w[:m],wn[m:]])
            v = np.linalg.solve(E,V@CC[2*m:,:2*m]@h)
            psi[x,:,0] = w[:m]; psi[x,:,1] = wn[m:]
            psi[x,:,2] = v[:m]; psi[x,:,3] = v[m:]
            w = wn
        psi = psi.ravel(); psi /= np.linalg.norm(psi)
        res = np.linalg.norm(U@psi-lam*psi)
        worst = max(worst,res)
        assert res<1e-8,(n,m,lam,res)
    return dict(nx=n,ny=m,checked=len(vals)-skipped,exceptional=skipped,max_residual=float(worst))


def block_determinant_check(C,coords):
    coords = sorted(coords)
    U,_,_ = build(C,coords)
    xs = sorted(set(x for x,y in coords))
    slices = [np.array([4*i+c for i,v in enumerate(coords) if v[0]==x for c in range(4)]) for x in xs]
    worst = 0.
    for _ in range(4):
        lam = complex(1.2+RNG.random(),RNG.random())
        H = lam*np.eye(len(U))-U
        Q = H[np.ix_(slices[0],slices[0])]
        sign,logdet = np.linalg.slogdet(Q)
        for j in range(1,len(slices)):
            p,q = slices[j-1],slices[j]
            Q = H[np.ix_(q,q)]-H[np.ix_(q,p)]@np.linalg.solve(Q,H[np.ix_(p,q)])
            s,l = np.linalg.slogdet(Q); sign*=s; logdet+=l
        direct_s,direct_l = np.linalg.slogdet(H)
        err = abs(sign/direct_s*np.exp(logdet-direct_l)-1)
        worst = max(worst,err)
        assert err<1e-10
    return float(worst)


def main():
    rects = [(1,1),(1,5),(5,1),(2,2),(2,5),(3,4),(4,5),(5,6)]
    grover = []
    for n,m in rects:
        result = grover_check([(x,y) for x in range(n) for y in range(m)])
        scalar = []
        for a in range(n):
            for b in range(m):
                scalar.append((np.cos(np.pi*a/n)+np.cos(np.pi*b/m))/2)
        U,_,A = build(G,[(x,y) for x in range(n) for y in range(m)])
        D = (A+np.diag(4-A.sum(axis=1)))/4
        assert max(abs(np.sort(scalar)-np.linalg.eigvalsh(D)))<1e-12
        result['domain'] = f'rectangle_{n}x{m}'
        grover.append(result)
    irregular = []
    for L,r in [(3,1),(4,2),(5,3),(6,4)]:
        coords = [(x,y) for x in range(L+1) for y in range(x+1) if x*x+y*y>=r*r]
        result = grover_check(coords); result['domain'] = f'sinai_octant_L{L}_R{r}'
        grover.append(result); irregular.append(coords)
    for trial in range(6):
        coords = {(0,0)}
        while len(coords)<10+trial:
            x,y = sorted(coords)[int(RNG.integers(len(coords)))]; dx,dy = DELTA[int(RNG.integers(4))]
            coords.add((x+dx,y+dy))
        result = grover_check(coords); result['domain'] = f'connected_random_{trial}'
        grover.append(result); irregular.append(coords)
    checks = []
    det_errors = []
    for trial in range(5):
        Z = RNG.normal(size=(4,4))+1j*RNG.normal(size=(4,4))
        C,_ = np.linalg.qr(Z)
        for n,m in [(1,1),(2,2),(3,2),(4,3)]:
            checks.append(transfer_check(C,n,m))
        det_errors.append(block_determinant_check(C,irregular[trial]))
    for n,m in [(2,2),(3,3),(4,3)]:
        checks.append(transfer_check(G,n,m))
    report = dict(seed=271828,grover=grover,transfer=checks,block_determinant_errors=det_errors)
    path = Path(__file__).with_name('verificacion.json')
    path.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(grover_domains=len(grover),max_grover_spectral_error=max(x['spectral_error'] for x in grover),max_grover_vector_residual=max(x['vector_residual'] for x in grover),transfer_checked=sum(x['checked'] for x in checks),transfer_exceptional=sum(x['exceptional'] for x in checks),max_transfer_residual=max(x['max_residual'] for x in checks),max_block_determinant_relative_error=max(det_errors)),indent=2))

if __name__=='__main__':
    main()
