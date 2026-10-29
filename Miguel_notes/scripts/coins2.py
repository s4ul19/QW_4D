import itertools, numpy as np, scipy.sparse as sp
exec(open('coins.py').read().split("coins={")[0])
np.set_printoptions(precision=4,suppress=True)
# 1. explicit gauge for F_c
a,b=np.pi/2,0.0
Fg=Dg(a,b)@Fc@Dg(a,b); print('D F_c D, D=diag(i,-i,1,1); coherent:'); print(np.round(coh(Fg),4)); print('L_SW =',Lsw(Fg))
# 2. B_I vs permuted/transposed B_II (basis-order conversion test)
hits=[]
for pi in itertools.permutations(range(4)):
    Pm=np.eye(4)[list(pi)]
    for nm,X in [('B_II',BII),('B_II^T',BII.T),('-B_II',-BII),('-B_II^T',-BII.T)]:
        if np.allclose(Pm@X@Pm.T,BI): hits.append((pi,nm))
print('permutations pi with Pi X Pi^T = B_I:',hits)
# also allow sign flips (diagonal +-1) congruence
hits2=[]
for pi in itertools.permutations(range(4)):
    Pm=np.eye(4)[list(pi)]
    for sg in itertools.product([1,-1],repeat=4):
        S_=np.diag(sg)@Pm
        for nm,X in [('B_II',BII),('B_II^T',BII.T)]:
            if np.allclose(S_@X@S_.T,BI): hits2.append((pi,sg,nm))
print('signed permutations giving B_I:',hits2[:6],'... total',len(hits2))
for nm,X in [('B_I',BI),('B_II',BII),('F_p',Fp),('F_c',Fc)]:
    ev=np.linalg.eigvals(X); print(nm,'eigenvalue phases/pi:',np.round(np.sort(np.angle(ev))/np.pi,4),' smallest k with X^k=I:',next((k for k in range(1,25) if np.allclose(np.linalg.matrix_power(X,k),np.eye(4))),None))
