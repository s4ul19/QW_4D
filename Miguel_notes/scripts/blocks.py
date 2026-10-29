import numpy as np, scipy.sparse as sp, sys
sys.path.insert(0,'/home/claude/mix')
from core import rect, graph, shift, floquet
exec(open('coins.py').read().split("coins={")[0])
from scipy.optimize import linear_sum_assignment
def block_spectrum(Cplus,al,be,nx,ny):
    ev=[]
    for m in range(nx):
        for n in range(ny):
            cx,sx=np.cos(np.pi*m/nx),np.sin(np.pi*m/nx); cy,sy=np.cos(np.pi*n/ny),np.sin(np.pi*n/ny)
            S=np.array([[cx,0,-sx,0],[0,cy,0,-sy],[sx,0,cx,0],[0,sy,0,cy]],complex)
            Cb=np.zeros((4,4),complex); Cb[:2,:2]=Cplus; Cb[2,2]=np.exp(1j*al); Cb[3,3]=np.exp(1j*be)
            keep=[0,1]+([2] if m>0 else [])+([3] if n>0 else [])
            ev+=list(np.linalg.eigvals((S@Cb)[np.ix_(keep,keep)]))
    ev+=[-np.exp(1j*al)]*ny + [-np.exp(1j*be)]*nx      # terminal singletons
    return np.array(ev)
def check(nx,ny,C,Cplus,al,be,gauge=None):
    pts=rect(nx,ny); idx,nb=graph(pts); V=len(pts)
    U=floquet(nb,C).toarray(); ev=np.linalg.eigvals(U); pred=block_spectrum(Cplus,al,be,nx,ny)
    cost=abs(ev[:,None]-pred[None,:]); r,c=linear_sum_assignment(cost); err=cost[r,c].max()
    out=f'{nx}x{ny}: |spec(U) - block prediction| max = {err:.2e}'
    if gauge is not None:
        a,b=gauge; al_,be_=2*a,2*b
        Dd=np.diag([np.exp(-1j*al_/2),np.exp(1j*al_/2),np.exp(-1j*be_/2),np.exp(1j*be_/2)])
        W=np.diag(np.concatenate([np.exp(1j*(al_*x+be_*y))*np.diag(Dd) for (x,y) in pts]))
        Ug=floquet(nb,Dd.conj()@C@Dd.conj()).toarray()
        out+=f'; |W U_C W^dag - U_(Dbar C Dbar)| = {abs(W@U@W.conj().T-Ug).max():.2e}; Dbar C Dbar == D C D(a,b): {np.allclose(Dd.conj()@C@Dd.conj(),Dg(a,b)@C@Dg(a,b))}'
    print(out)
sx=np.array([[0,1],[1,0]])
print('Grover (C+ = sigma_x, alpha = beta = pi):')
for nx,ny in [(7,5),(8,6)]: check(nx,ny,G,sx,np.pi,np.pi)
print('compass Fourier F_c via its gauge image (C+ = i sigma_x, alpha = pi, beta = pi/2):')
for nx,ny in [(7,5),(8,6)]: check(nx,ny,Fc,1j*sx,np.pi,np.pi/2,gauge=(np.pi/2,0))
