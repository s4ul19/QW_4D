import os
os.environ["OMP_NUM_THREADS"]=os.environ["OPENBLAS_NUM_THREADS"]=os.environ["MKL_NUM_THREADS"]="1"
import numpy as np, sys
from multiprocessing import Pool
from scipy.stats import unitary_group
Lx,Ly,cx,cy,R,nreal,tag = sys.argv[1:8]
Lx,Ly,nreal=int(Lx),int(Ly),int(nreal); cx,cy,R=float(cx),float(cy),float(R)
sites=[(x,y) for x in range(Lx) for y in range(Ly) if (x-cx)**2+(y-cy)**2>R**2]
idx={s:i for i,s in enumerate(sites)}; N=len(sites); D=4*N
d=[(-1,0),(0,1),(1,0),(0,-1)]; bar=[2,3,0,1]
perm=np.empty(D,int); B=np.zeros(4,int)
for (x,y),i in idx.items():
    for c in range(4):
        t=(x+d[c][0],y+d[c][1])
        if t in idx: perm[4*i+c]=4*idx[t]+c
        else: perm[4*i+c]=4*i+bar[c]; B[c]+=1
ts=np.arange(1,3*D); inv=np.argsort(perm)
g=np.linspace(-np.pi,np.pi,4001); w=0.05
def one(seed):
    M=unitary_group.rvs(4, random_state=seed)
    U=np.zeros((D,D),complex)
    for c in range(4):
        for cp in range(4): U[perm[4*np.arange(N)+c],4*np.arange(N)+cp]=M[c,cp]
    th=np.sort(np.angle(np.linalg.eigvals(U)))
    s=np.diff(np.concatenate([th,[th[0]+2*np.pi]]))
    r=(np.minimum(s[:-1],s[1:])/np.maximum(s[:-1],s[1:])).mean()
    dth=(g[:,None]-th[None,:]+np.pi)%(2*np.pi)-np.pi
    rho=np.exp(-dth**2/(2*w*w)).sum(1); del dth; rho=rho/np.sqrt(2*np.pi)/w
    cum=np.concatenate([[0],np.cumsum((rho[1:]+rho[:-1])/2*np.diff(g))]); cum*=D/cum[-1]
    e=np.interp(th,g,cum)*2*np.pi/D
    Kr=np.array([abs(np.exp(1j*t*th).sum())**2 for t in ts])
    Ku=np.array([abs(np.exp(1j*t*e).sum())**2 for t in ts])
    return Kr,Ku,r,rho
if __name__=="__main__":
    print("N",N,"D",D,"B",B,"K(1) pred",(B**2).sum()/4,flush=True)
    with Pool(48) as p: res=p.map(one, range(nreal))
    Kr=np.mean([x[0] for x in res],0); Ku=np.mean([x[1] for x in res],0)
    rs=np.array([x[2] for x in res]); rho=np.array([x[3] for x in res])
    print("<r> = %.4f +- %.4f"%(rs.mean(), rs.std()/np.sqrt(nreal)), "K(1) num", Kr[0])
    np.savez(f"res_{tag}.npz",ts=ts,Kr=Kr,Ku=Ku,D=D,N=N,B=B,r=rs,rho=rho,g=g)
