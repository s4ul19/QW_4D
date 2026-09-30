import numpy as np, matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
lab={"sym30":"Sinaí simétrico","asym31":"Sinaí asimétrico"}
tau=np.logspace(-4,np.log10(3),600)
cue=np.minimum(tau,1)
coe=np.where(tau<1,2*tau-tau*np.log(1+2*tau),2-tau*np.log(np.abs((2*tau+1)/(2*tau-1))))
def logbin(t,K,n=80):
    b=np.logspace(np.log10(t[0]),np.log10(t[-1]),n); i=np.digitize(t,b)
    k=[j for j in range(1,n) if (i==j).any()]
    return np.array([t[i==j].mean() for j in k]),np.array([K[i==j].mean() for j in k])
fig,ax=plt.subplots(1,2,figsize=(11,4.2),sharey=True)
for a,key,ttl in zip(ax,["Kr","Ku"],["(a) sin unfolding","(b) con unfolding"]):
    for tg in lab:
        z=np.load(f"res_{tg}.npz"); D=int(z["D"])
        tm,Km=logbin(z["ts"]/D,z[key]/D)
        a.loglog(tm,Km,".-",ms=3,lw=.8,label=f"{lab[tg]} ($D={D}$)")
    a.loglog(tau,cue,"k-",lw=1.5,label=r"CUE: $\min(\tau,1)$"); a.loglog(tau,coe,"k--",lw=1,label="COE")
    a.set_xlabel(r"$\tau=t/D$"); a.set_title(ttl); a.set_ylim(1e-3,1e3)
ax[0].set_ylabel(r"$K(t)/D$"); ax[1].legend(fontsize=8)
plt.tight_layout(); plt.savefig("../Imgs/SFF_CUEcoin.pdf")
fig,a=plt.subplots(figsize=(5.5,4))
for tg,m in zip(lab,["o","s"]):
    z=np.load(f"short_{tg}.npz"); D=int(z["D"]); t=np.arange(1,len(z["K"])+1)
    a.errorbar(t,z["K"]/D,z["err"]/D,fmt=m,ms=4,mfc="none",label=lab[tg])
t=np.arange(2,15); a.loglog(t,1500/t**2,"k:",label=r"$\propto t^{-2}$")
a.loglog(t,t/2768,"k-",lw=1,label=r"CUE: $t/D$")
a.set_xlabel("$t$"); a.set_ylabel(r"$K(t)/D$"); a.legend(fontsize=8); plt.tight_layout(); plt.savefig("../Imgs/SFF_short.pdf")
