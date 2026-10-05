import numpy as np
rng=np.random.default_rng(1)
def U(n,C):
    S=np.zeros((2*n,2*n),complex); idx=lambda j,s:2*j+s  # s=0 R, s=1 L
    for j in range(n):
        S[idx(j+1,0) if j<n-1 else idx(n-1,1), idx(j,0)]=1
        S[idx(j-1,1) if j>0 else idx(0,0), idx(j,1)]=1
    return S@np.kron(np.eye(n),C)
def theory(n,al,a,b):
    w=np.arccos(abs(a)*np.cos(np.pi*np.arange(1,n)/n))
    s=np.sqrt(1-b.imag**2)
    return np.exp(1j*al)*np.concatenate([np.exp(1j*w),np.exp(-1j*w),[s+1j*b.imag,-s+1j*b.imag]])
def match(x,y):
    x=np.sort_complex(x); return max(min(abs(xi-y)) for xi in y), max(min(abs(yi-x)) for yi in x)
for n in [2,3,5,8,13]:
    for _ in range(3):
        al=rng.uniform(0,2*np.pi); th=rng.uniform(0,np.pi/2); p1,p2=rng.uniform(0,2*np.pi,2)
        a=np.cos(th)*np.exp(1j*p1); b=np.sin(th)*np.exp(1j*p2)
        C=np.exp(1j*al)*np.array([[a,b],[-b.conjugate(),a.conjugate()]])
        ev=np.linalg.eigvals(U(n,C)); t=theory(n,al,a,b)
        # multiset comparison
        err=max(abs(np.sort(np.angle(ev))-np.sort(np.angle(t))))
        print(n, f"{err:.2e}")
