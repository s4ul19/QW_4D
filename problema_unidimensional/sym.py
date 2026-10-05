import numpy as np
exec(open("qw.py").read().split("for n in")[0])
rng=np.random.default_rng(3)
n=7
def coin(a,b,al=0): return np.exp(1j*al)*np.array([[a,b],[-np.conj(b),np.conj(a)]])
sx=np.array([[0,1],[1,0]]);sz=np.diag([1,-1])
P=np.zeros((2*n,2*n))
for j in range(n): P[2*(n-1-j)+1,2*j]=1; P[2*(n-1-j),2*j+1]=1
G=np.kron(np.diag((-1.0)**np.arange(n)),sz)
Q=P@G
for name,(a,b) in {"generica":(0.6*np.exp(.7j),0.8*np.exp(1j*np.pi/3)),"hadamard":(2**-.5,2**-.5),
                   "a real, b imag":(0.6,0.8j)}.items():
    U0=U(n,coin(a,b))
    print(name)
    print("  Gamma S Gamma = -S :", np.allclose(G@U(n,np.eye(2))@G,-U(n,np.eye(2))))
    print("  (QK) U (QK)^-1 = -U:", np.allclose(Q@U0.conj()@Q.T,-U0))
    print("  [P,U]=0            :", np.allclose(P@U0@P.T,U0))
    print("  U real (K sym)     :", np.allclose(U0.imag,0))
print("--- paridad P por nivel, a real b imag, n=7")
U0=U(n,coin(0.6,0.8j)); w,v=np.linalg.eig(U0)
o=np.argsort(np.angle(w))
for k in o: print(f"{np.angle(w[k]):+.3f}  <P>={np.real(v[:,k].conj()@P@v[:,k]):+.2f}")
