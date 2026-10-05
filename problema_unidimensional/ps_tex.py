import numpy as np, matplotlib
matplotlib.use("Agg"); import matplotlib.pyplot as plt; plt.rcParams.update({"font.size":11})
exec(open("qw.py").read().split("for n in")[0])
BLUE,ORANGE,AQUA,YEL,INK,MUTED,GRID="#2a78d6","#eb6834","#1baf7a","#eda100","#1f1f1e","#8a897f","#d8d7d0"
n=1500
cases=[("Hadamard",0.0,2**-.5,2**-.5+0j),("Genérica |a|=0.6",0.3,0.6*np.exp(.7j),0.8*np.exp(1j*np.pi/3))]
s=np.linspace(0,3.5,600)
pois=np.exp(-s); goe=np.pi/2*s*np.exp(-np.pi*s**2/4); gue=32/np.pi**2*s**2*np.exp(-4*s**2/np.pi)
fig,axs=plt.subplots(1,3,figsize=(10,4.6))
for col,(name,al,a,b) in zip([BLUE,ORANGE],cases):
    C=np.exp(1j*al)*np.array([[a,b],[-np.conj(b),np.conj(a)]])
    ev=np.linalg.eigvals(U(n,C))
    th=np.angle(ev*np.exp(-1j*al))
    # dominio fundamental: arco superior, 0<theta<pi/2 (simetrías theta->-theta y theta->pi-theta)
    w0=np.arccos(abs(a))
    dom=np.sort(th[(th>w0-1e-9)&(th<=np.pi/2+1e-12)])
    sp=np.diff(dom); sr=sp/sp.mean()
    A=abs(a); kap=2*np.arcsin(A)/np.pi
    x=np.linspace(0,A/kap*0.999,800); y=kap*(2/np.pi)*(abs(b)/A)/((1-(kap*x)**2)*np.sqrt(1-(kap*x/A)**2))
    axs[0].hist(sr,bins=40,density=True,histtype="stepfilled",color=col,alpha=.28,lw=0)
    axs[0].plot(x,y,color=col,lw=2,label=f"{name}")
    # unfolding exacto
    N=lambda t:(n/np.pi)*np.arccos(np.clip(np.cos(t)/A,-1,1))
    ue=np.diff(-N(dom))
    # unfolding "ciego": ajuste polinomial a la escalera
    k=np.arange(len(dom)); c=np.polyfit(dom,k,9); uf=np.diff(np.polyval(c,dom))
    axs[1 if name=="Hadamard" else 2].hist(uf,bins=np.linspace(0,3.5,141),density=True,color=col,alpha=.85,label="ajuste pol. grado 9")
    axs[1 if name=="Hadamard" else 2].axvline(1,color=INK,lw=1.5,ls=(0,(1,2)),label=f"exacto: s≡1")
for ax in axs:
    ax.plot(s,pois,color=MUTED,lw=1.3,label="Poisson"); ax.plot(s,goe,color=AQUA,lw=1.3,label="GOE (Wigner)"); ax.plot(s,gue,color=YEL,lw=1.3,label="GUE (Wigner)")
    ax.set_xlim(0,3); ax.set_xlabel("s",color=MUTED); ax.tick_params(colors=MUTED)
    for sp_ in ax.spines.values(): sp_.set_color(GRID)
REF=("Poisson","GOE (Wigner)","GUE (Wigner)")
for ax in axs:
    hh,ll=ax.get_legend_handles_labels(); ax.legend([x for x,y in zip(hh,ll) if y not in REF],[y for y in ll if y not in REF],frameon=False,fontsize=9,loc="upper right")
from matplotlib.lines import Line2D
h=[Line2D([],[],color=c,lw=2) for c in (MUTED,AQUA,YEL)]; l=list(REF); fig.legend(h,l,loc="lower center",ncol=3,frameon=False,fontsize=10)
axs[0].set_ylim(0,3.2); axs[1].set_ylim(0,6); axs[2].set_ylim(0,6)
axs[0].set_ylabel("P(s)",color=MUTED)
axs[0].set_title("Sin unfolding",fontsize=14)
axs[1].set_title("Unfolded: Hadamard",fontsize=14); axs[2].set_title("Unfolded: genérica",fontsize=14)

plt.tight_layout(rect=(0,0.07,1,1)); plt.savefig("/home/user/qw_reflectante/figs/nns.pdf")
