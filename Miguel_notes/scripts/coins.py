import numpy as np
from scipy.linalg import expm
from scipy.optimize import minimize
s2=np.sqrt(2)
# physical order (R,L,U,D); notes' coherent order Q columns (h+,v+,h-,v-)
Q=np.array([[1,0,1,0],[1,0,-1,0],[0,1,0,1],[0,1,0,-1]])/s2
J=np.array([[0,1,0,0],[1,0,0,0],[0,0,0,1],[0,0,1,0]])
G=np.full((4,4),.5)-np.eye(4)
P=np.array([[0,0,1,0],[0,0,0,1],[1,0,0,0],[0,1,0,0]])
hm=np.array([1,-1,0,0])/s2; vm=np.array([0,0,1,-1])/s2
V=np.outer(hm,vm)+np.outer(vm,hm)
def CG(t): return G@expm(-1j*t*V)
BI=np.array([[-1,0,0,1],[0,-1,1,0],[0,1,1,0],[1,0,0,1]])/s2          # notes / earlier report
B_udrl=np.array([[1,0,0,1],[1,0,0,-1],[0,1,1,0],[0,1,-1,0]])/s2
perm=[2,3,0,1]; BII=B_udrl[np.ix_(perm,perm)]                          # reproduces the IPR plot
def BIIt(t): return BII@expm(-1j*t*V)
F=np.array([[1j**(j*k) for k in range(4)] for j in range(4)])/2
Fp=F                                   # cyclic index = physical order (R,L,U,D)
# compass: cyclic order (R,U,L,D): physical index of cyclic j
cyc=[0,2,1,3]  # cyclic j -> physical index : R->0,U->2,L->1,D->3
Fc=np.zeros((4,4),complex)
for j in range(4):
    for k in range(4): Fc[cyc[j],cyc[k]]=F[j,k]
Fc_notes=np.array([[1,1,1,1],[1,1,-1,-1],[1,-1,1j,-1j],[1,-1,-1j,1j]])/2
print('Fc matches notes:',np.allclose(Fc,Fc_notes))
allowed=np.zeros((4,4),bool); allowed[:2,:2]=True; allowed[2,2]=allowed[3,3]=True
coh=lambda C: Q.conj().T@C@Q
Lsw=lambda C: float((abs(coh(C))**2)[~allowed].sum()/4)
def Dg(a,b): return np.diag([np.exp(1j*a),np.exp(-1j*a),np.exp(1j*b),np.exp(-1j*b)])
def Lstar(C):
    best=(9,None)
    for a0 in np.linspace(0,np.pi,13):
        for b0 in np.linspace(0,np.pi,13):
            r=minimize(lambda x: Lsw(Dg(*x)@C@Dg(*x)),[a0,b0],method='Nelder-Mead',options=dict(xatol=1e-12,fatol=1e-15,maxiter=4000))
            if r.fun<best[0]: best=(r.fun,r.x)
    return best
def split(C):
    p=abs(C)**2; p=p[p>1e-15]; return float(-(p*np.log(p)).sum()/(4*np.log(4)))
def Mq(C,q):
    q=np.diag(q); return float(min(np.linalg.norm(C@q-q@C)**2,np.linalg.norm(C@q+q@C)**2)/8)
coins={'P':P,'G':G,'F_p':Fp,'F_c':Fc,'B_I':BI,'B_II':BII,'C_G(pi/4)':CG(np.pi/4),'C_G(pi/3)':CG(np.pi/3),'B_II(pi/4)':BIIt(np.pi/4),'B_II(pi/2)':BIIt(np.pi/2)}
np.set_printoptions(precision=3,suppress=True)
res={}
for n,C in coins.items():
    assert np.allclose(C@C.conj().T,np.eye(4))
    Ls,(x)=Lsw(C),Lstar(C)
    res[n]=dict(Lsw=Ls,Lstar=x[0],ab=x[1],split=split(C),Mq=[Mq(C,q) for q in ([1,1,-1,-1],[1,-1,1,-1],[1,-1,-1,1])],
                CJ=float(np.linalg.norm(C@J-J@C)),sym=bool(np.allclose(C,C.T)),real=bool(np.allclose(C.imag,0)))
    print(f"{n:11s} L_SW={Ls:.4f}  L*_SW={x[0]:.2e} at (a,b)={np.round(x[1],4)}  split={res[n]['split']:.3f}  Mq={np.round(res[n]['Mq'],3)}  |[C,J]|={res[n]['CJ']:.3f} sym={res[n]['sym']} real={res[n]['real']}")
    print('   coherent C~ (h+,v+,h-,v-):'); print(np.round(coh(C),3))
np.save('coins_res.npy',res,allow_pickle=True)
