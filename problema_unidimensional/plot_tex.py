import numpy as np, matplotlib
matplotlib.use("Agg"); import matplotlib.pyplot as plt; plt.rcParams.update({"font.size":14})
exec(open("qw.py").read().split("for n in")[0])
BLUE,ORANGE,INK,MUTED="#2a78d6","#eb6834","#1f1f1e","#8a897f"
cases=[("Hadamard: $a=b=1/\\sqrt{2}$, $\\alpha=0$", 0.0, 1/np.sqrt(2), 1/np.sqrt(2)+0j),
       ("Moneda genérica: $|a|=0.6$, $b=0.8\\,e^{i\\pi/3}$, $\\alpha=0.3$", 0.3, 0.6*np.exp(0.7j), 0.8*np.exp(1j*np.pi/3))]
n=12
fig,axs=plt.subplots(1,2,figsize=(11,6.4))
for ax,(title,al,a,b) in zip(axs,cases):
    C=np.exp(1j*al)*np.array([[a,b],[-np.conj(b),np.conj(a)]])
    ev=np.linalg.eigvals(U(n,C)); t=theory(n,al,a,b)
    th=np.linspace(0,2*np.pi,400)
    ax.plot(np.cos(th),np.sin(th),color=MUTED,lw=1,zorder=1)
    ax.axhline(0,color="#d8d7d0",lw=.8,zorder=0); ax.axvline(0,color="#d8d7d0",lw=.8,zorder=0)
    # band edges: arcs where |cos w|<=|a| (rotated by alpha)
    w0=np.arccos(abs(a))
    for s in (1,-1):
        arc=np.linspace(w0,np.pi-w0,100)*s+al
        ax.plot(1.07*np.cos(arc),1.07*np.sin(arc),color=BLUE,lw=3,alpha=.25,solid_capstyle="round")
    band,ext=t[:2*(n-1)],t[2*(n-1):]
    ax.scatter(ev.real,ev.imag,s=110,facecolors="none",edgecolors=INK,lw=1.2,zorder=3,label="numérico (diag. de $U$)")
    ax.scatter(band.real,band.imag,s=45,color=BLUE,edgecolors="white",lw=1.5,zorder=4,label=r"banda: $\cos\omega_m=|a|\cos(\pi m/n)$")
    ax.scatter(ext.real,ext.imag,s=70,marker="D",color=ORANGE,edgecolors="white",lw=1.5,zorder=5,label=r"aislados: $e^{i\alpha}(\pm\sqrt{1-(\mathrm{Im}\,b)^2}+i\,\mathrm{Im}\,b)$")
    ax.set_aspect("equal"); ax.set_xlim(-1.3,1.3); ax.set_ylim(-1.3,1.3)
    ax.set_title(title,fontsize=13,color=INK); ax.set_xlabel(r"Re $\lambda$",color=MUTED); ax.set_ylabel(r"Im $\lambda$",color=MUTED)
    for sp in ax.spines.values(): sp.set_color("#d8d7d0")
    ax.tick_params(colors=MUTED)
h,l=axs[0].get_legend_handles_labels()
fig.legend(h,l,loc="lower center",bbox_to_anchor=(0.5,0.0),ncol=3,frameon=False,fontsize=12)


plt.tight_layout(rect=(0,0.08,1,1)); plt.savefig("/home/user/qw_reflectante/figs/eigenvalores.pdf")
