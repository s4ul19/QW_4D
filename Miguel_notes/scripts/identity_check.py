import numpy as np, sys
sys.path.insert(0,'/home/claude/mix')
from core import rect, graph, floquet
exec(open('blocks.py').read().split("sx=np.array")[0].split("from core import")[0])
from scipy.optimize import linear_sum_assignment
exec(open('blocks.py').read().split("def check")[0].split("exec(open('coins.py')")[0])
exec(open('coins.py').read().split("coins={")[0])
exec(open('blocks.py').read().split("def check")[0].split("from scipy.optimize import linear_sum_assignment")[1])
I4=np.eye(4)
for nx,ny in [(7,5),(8,6)]:
    pts=rect(nx,ny); idx,nb=graph(pts); U=floquet(nb,I4).toarray()
    ev=np.linalg.eigvals(U)
    # cycle prediction
    pred=np.r_[np.tile(np.exp(2j*np.pi*np.arange(2*nx)/(2*nx)),ny),np.tile(np.exp(2j*np.pi*np.arange(2*ny)/(2*ny)),nx)]
    C=abs(ev[:,None]-pred[None]); r,c=linear_sum_assignment(C)
    pb=block_spectrum(np.eye(2),0,0,nx,ny); C2=abs(ev[:,None]-pb[None]); r2,c2=linear_sum_assignment(C2)
    P=np.linalg.matrix_power(U,2*np.lcm(nx,ny))
    print(nx,ny,'|spec - cycle roots|',C[r,c].max(),' |spec - block formula (C+=I,a=b=0)|',C2[r2,c2].max(),' |U^(2 lcm)-I|',abs(P-np.eye(len(U))).max(),
          ' smallest period', next(k for k in range(1,200) if np.allclose(np.linalg.matrix_power(U,k),np.eye(len(U)))))
# standing-wave rotation check on one row (moving shift, RLUD), Nx=8, m=2
Nx=8; m=2; j=np.arange(1,Nx+1)
f=np.sqrt(2/Nx)*np.cos(np.pi*m/Nx*(j-.5)); g=np.sqrt(2/Nx)*np.sin(np.pi*m/Nx*(j-.5))
# row space basis: (x, R),(x, L)
def S_row(vR,vL):
    nR=np.zeros(Nx); nL=np.zeros(Nx)
    nR[1:]+=vR[:-1]; nL[-1]+=vR[-1]      # R moves right; at right wall becomes L
    nL[:-1]+=vL[1:]; nR[0]+=vL[0]        # L moves left; at left wall becomes R
    return nR,nL
s2=np.sqrt(2)
hp=(f/s2,f/s2); hm=(g/s2,-g/s2)
out=S_row(*hp); k=np.pi*m/Nx
pred=(np.cos(k)*hp[0]+np.sin(k)*hm[0], np.cos(k)*hp[1]+np.sin(k)*hm[1])
print('row identity S(f h+) = cos k f h+ + sin k g h-: error',max(abs(out[0]-pred[0]).max(),abs(out[1]-pred[1]).max()))
