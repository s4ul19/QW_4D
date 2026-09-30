import os
os.environ["OMP_NUM_THREADS"]="1"; os.environ["OPENBLAS_NUM_THREADS"]="1"
import numpy as np, sys, scipy.sparse as sp
from multiprocessing import Pool
from scipy.stats import unitary_group
Lx,Ly,cx,cy,R,nreal,tag,tmax=sys.argv[1:9]
Lx,Ly,nreal,tmax=int(Lx),int(Ly),int(nreal),int(tmax); cx,cy,R=float(cx),float(cy),float(R)
sites=[(x,y) for x in range(Lx) for y in range(Ly) if (x-cx)**2+(y-cy)**2>R**2]
idx={s:i for i,s in enumerate(sites)}; N=len(sites); D=4*N
d=[(-1,0),(0,1),(1,0),(0,-1)]; bar=[2,3,0,1]
perm=np.empty(D,int)
for (x,y),i in idx.items():
    for c in range(4):
        t=(x+d[c][0],y+d[c][1]); perm[4*i+c]=4*idx[t]+c if t in idx else 4*i+bar[c]
S=sp.csr_matrix((np.ones(D),(perm,np.arange(D))),shape=(D,D))
def one(seed):
    M=unitary_group.rvs(4,random_state=seed)
    U=(S@sp.kron(sp.identity(N),M)).tocsr(); P=U.copy(); out=[]
    for t in range(1,tmax+1):
        out.append(abs(P.diagonal().sum())**2); P=(P@U).tocsr()
    return out
if __name__=="__main__":
    with Pool(60) as p: r=np.array(p.map(one,range(nreal)))
    np.savez(f"short_{tag}.npz",K=r.mean(0),err=r.std(0)/np.sqrt(nreal),D=D)
    for t in range(tmax): print(t+1,"K/D = %.3f +- %.3f"%(r[:,t].mean()/D, r[:,t].std()/np.sqrt(nreal)/D))
