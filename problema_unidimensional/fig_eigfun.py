import numpy as np, matplotlib
matplotlib.use("Agg"); import matplotlib.pyplot as plt; plt.rcParams.update({"font.size":11})
exec(open("qw.py").read().split("for n in")[0])
BLUE,ORANGE,AQUA,YEL,INK,MUTED,GRID="#2a78d6","#eb6834","#1baf7a","#eda100","#1f1f1e","#8a897f","#d8d7d0"

def coin(al,a,b): return np.exp(1j*al)*np.array([[a,b],[-np.conj(b),np.conj(a)]])
def eig(n,al,a,b):
    ev,V=np.linalg.eig(U(n,coin(al,a,b))); mu=ev*np.exp(-1j*al)
    return np.angle(mu),V                                    # omega, eigenvectores
def estado(w,V,w0):                                          # eigenvector con omega mas cercana a w0
    return V[:,np.argmin(abs(np.exp(1j*w)-np.exp(1j*w0)))]
def ondas(n,a,b,w):                                          # descomposicion en ondas planas de un estado de banda
    A,pa=abs(a),np.angle(a); mu=np.exp(1j*w); q=np.arccos(np.cos(w)/A)
    k=pa+np.array([q,-q]); z=np.exp(1j*k)
    u=[np.array([b,mu*zz-a]) for zz in z]; f=lambda zz:(b-mu)*zz+a
    c=np.array([-f(z[1])/z[1],f(z[0])/z[0]])
    return q,k,u,c
def estilo(ax):
    for sp in ax.spines.values(): sp.set_color(GRID)
    ax.tick_params(colors=MUTED)

# moneda generica de las notas
al,a,b=0.3,0.6*np.exp(0.7j),0.8*np.exp(1j*np.pi/3); A,pa=abs(a),np.angle(a)

# ---------- Figura 1: un eigenestado = dos ondas planas ----------
fig,ax=plt.subplots(1,3,figsize=(14,4.3))
kk=np.linspace(pa-np.pi,pa+np.pi,600); wb=np.arccos(A*np.cos(kk-pa))
ax[0].plot(kk,wb,color=BLUE,lw=2); ax[0].plot(kk,-wb,color=BLUE,lw=2)
n,m=12,4; qm=np.pi*np.arange(1,n)/n
for s in (1,-1):
    for t in (1,-1): ax[0].scatter(pa+s*qm,t*np.arccos(A*np.cos(qm)),s=22,color=BLUE,edgecolors="white",zorder=3)
q0=np.pi*m/n; w0=np.arccos(A*np.cos(q0))
ax[0].scatter([pa+q0,pa-q0],[w0,w0],s=70,color=YEL,edgecolors=INK,zorder=4)
ax[0].annotate("",xy=(pa-q0,w0+.12),xytext=(pa+q0,w0+.12),arrowprops=dict(arrowstyle="<->",color=INK,lw=1.3))
ax[0].text(pa,w0+.22,r"pared: $k_+\leftrightarrow k_-$",ha="center",fontsize=10)
ims=b.imag; s0=np.sqrt(1-ims**2)
for wx,kx in ((np.angle(s0+1j*ims),pa),(np.angle(-s0+1j*ims),pa+np.pi)):
    ax[0].scatter([kx],[wx],marker="D",s=60,color=ORANGE,edgecolors="white",zorder=4)
    ax[0].text(kx-.12 if kx>pa else kx+.12,wx,r"$k$ complejo",color=ORANGE,fontsize=10,va="center",ha="right" if kx>pa else "left")
ax[0].set_xlabel(r"$k$ (onda plana $e^{ikj}$)",color=MUTED); ax[0].set_ylabel(r"$\omega$",color=MUTED)
ax[0].set_title(r"(a) bandas del sistema sin paredes, $n=12$",fontsize=11)
ax[0].set_xlim(pa-np.pi,pa+np.pi); ax[0].set_ylim(-np.pi,np.pi)

n,m=40,7; w,V=eig(n,al,a,b); w0=np.arccos(A*np.cos(np.pi*m/n)); v=estado(w,V,w0)
R,L=v[0::2],v[1::2]; ks=np.linspace(-np.pi,np.pi,2000); js=np.arange(n)
FT=lambda x: abs(np.exp(-1j*np.outer(ks,js))@x)**2
ax[1].plot(ks,FT(R),color=BLUE,lw=1.6,label=r"$|\tilde R(k)|^2$"); ax[1].plot(ks,FT(L),color=AQUA,lw=1.6,label=r"$|\tilde L(k)|^2$")
q,k,u,c=ondas(n,a,b,w0)
for kx,lab in zip(np.angle(np.exp(1j*k)),("$k_+$","$k_-$")):
    ax[1].axvline(kx,color=YEL,ls="--",lw=1.2); ax[1].text(kx,ax[1].get_ylim()[1]*.93,lab,ha="center",fontsize=11,backgroundcolor="white")
ax[1].set_xlabel(r"$k$",color=MUTED); ax[1].legend(frameon=False,loc="upper left",bbox_to_anchor=(0,.88))
ax[1].set_title(rf"(b) Fourier de un eigenestado ($n={n}$, $m={m}$)",fontsize=11)

P=abs(R)**2+abs(L)**2; N=[np.vdot(x,x).real for x in u]
x=np.linspace(0,n-1,800); z=np.exp(1j*k)
Pc=(abs(c[0])**2*N[0]+abs(c[1])**2*N[1]+2*np.real(c[0]*np.conj(c[1])*np.vdot(u[1],u[0])*np.exp(2j*q*x)))
nrm=P.sum()/(abs(c[0])**2*N[0]+abs(c[1])**2*N[1]+2*np.real(c[0]*np.conj(c[1])*np.vdot(u[1],u[0])*np.exp(2j*q*js))).sum()
D=abs(b)*abs(np.cos(q))/abs(np.sin(w0)); A0=nrm*(abs(c[0])**2*N[0]+abs(c[1])**2*N[1])
ax[2].fill_between(x,A0*(1-D),A0*(1+D),color=YEL,alpha=.15,lw=0)
ax[2].axhline(A0/2,color=MUTED,ls=":",lw=1.2); ax[2].text(n-1,A0/2,"cada onda sola",ha="right",va="bottom",color=MUTED,fontsize=9)
ax[2].plot(x,nrm*Pc,color=YEL,lw=1.4,label="suma de 2 ondas planas")
ax[2].scatter(js,P,s=22,color=INK,zorder=3,label=r"$P_j$ (diag. de $U$)")
ax[2].set_xlabel(r"$j$",color=MUTED); ax[2].set_ylim(0,None); ax[2].set_ylim(0,1.35*P.max()); ax[2].legend(frameon=False,loc="upper center",fontsize=9,ncol=2)
ax[2].set_title(rf"(c) interferencia: $P_j=A_0[1+D\cos(2qj+\delta)]$, $D={D:.2f}$",fontsize=11)
for x_ in ax: estilo(x_)
plt.tight_layout(); plt.savefig("figs/ondas_planas.pdf")

# ---------- Figura 2: alfombra de todos los eigenestados ----------
n=50; w,V=eig(n,al,a,b); o=np.argsort(w); P=abs(V[0::2])**2+abs(V[1::2])**2; P=P[:,o]/P[:,o].max(0)
fig,ax=plt.subplots(1,2,figsize=(10,5.6),gridspec_kw=dict(width_ratios=[4,1]),sharey=True)
ax[0].imshow(P.T,cmap="magma",aspect="auto",origin="lower",interpolation="nearest")
ax[0].set_xlabel(r"sitio $j$",color=MUTED); ax[0].set_ylabel(r"nivel (ordenado por $\omega$)",color=MUTED)
ix=np.arange(2*n); tk=ix[::10]; ax[0].set_yticks(tk); ax[0].set_yticklabels([f"{x:.2f}" for x in w[o][tk]])
ax[0].set_ylabel(r"$\omega$ del nivel (niveles equiespaciados en el eje)",color=MUTED)
ax[0].set_title(r"$P_j/\max_j P_j$ para los $2n$ eigenestados, $n=50$",fontsize=11)
wo=w[o]; cq=np.cos(wo)/A; ok=abs(cq)<1-1e-9
ax[1].plot(np.where(ok,abs(b)*abs(cq)/abs(np.sin(wo)),np.nan),ix,"o-",ms=3,color=YEL,lw=1.5)
ax[1].set_xlim(0,1.05); ax[1].set_xlabel(r"$D$",color=MUTED)
for i in ix[~ok]:
    ax[1].axhline(i,color=ORANGE,lw=1.5); ax[1].text(.5,i+.8,"borde",color=ORANGE,ha="center",fontsize=9)
ax[1].set_title("contraste",fontsize=11)
for x_ in ax: estilo(x_)
plt.tight_layout(); plt.savefig("figs/alfombra.pdf")

# ---------- Figura 3: D como traslape de espinores ----------
fig=plt.figure(figsize=(12,4.8)); ax=fig.add_subplot(1,2,1)
qq=np.linspace(1e-3,np.pi-1e-3,400)
for AA,col in ((0.3,AQUA),(0.6,BLUE),(0.9,ORANGE)):
    BB=np.sqrt(1-AA**2); ax.plot(qq,BB*abs(np.cos(qq))/np.sqrt(1-AA**2*np.cos(qq)**2),color=col,lw=2,label=rf"$|a|={AA}$")
    aa=AA*np.exp(0.7j); bb=BB*np.exp(1j*np.pi/3); n=30; w,V=eig(n,al,aa,bb)
    for i in range(2*n):
        if abs(np.cos(w[i]))>AA-1e-9: continue
        vv=V[:,i]; P=abs(vv[0::2])**2+abs(vv[1::2])**2; q=np.arccos(np.cos(w[i])/AA); js=np.arange(n)
        cf=np.linalg.lstsq(np.c_[np.ones(n),np.cos(2*q*js),np.sin(2*q*js)],P,rcond=None)[0]
        ax.scatter(q,np.hypot(*cf[1:])/cf[0],s=14,color=col,edgecolors="white",lw=.5,zorder=3)
ax.set_xlabel(r"$q=\pi m/n$",color=MUTED); ax.set_ylabel(r"$D=|\langle\hat u_+|\hat u_-\rangle|$",color=MUTED)
ax.set_title("(a) contraste: curvas = fórmula, puntos = ajuste numérico",fontsize=11); ax.legend(frameon=False); estilo(ax)
ax=fig.add_subplot(1,2,2,projection="3d")
def bloch(x): x=x/np.linalg.norm(x); return np.array([2*np.real(np.conj(x[0])*x[1]),2*np.imag(np.conj(x[0])*x[1]),abs(x[0])**2-abs(x[1])**2])
uu,vv=np.mgrid[0:2*np.pi:40j,0:np.pi:20j]
ax.plot_wireframe(np.cos(uu)*np.sin(vv),np.sin(uu)*np.sin(vv),np.cos(vv),color=GRID,lw=.4)
w0s=lambda q: np.arccos(A*np.cos(q))
kk=np.linspace(-np.pi,np.pi,400)
curve=np.array([bloch(np.array([b,np.exp(1j*w0s(kx))*np.exp(1j*(pa+kx))-a])) for kx in kk])
ax.plot(*curve.T,color=BLUE,lw=2,label=r"$\hat u(k)$, banda $\omega>0$")
for q,col in ((0.25,ORANGE),(1.0,AQUA),(np.pi/2,YEL)):
    pts=[bloch(np.array([b,np.exp(1j*w0s(q))*np.exp(1j*(pa+s*q))-a])) for s in (1,-1)]
    ax.plot(*np.array(pts).T,color=col,lw=2.5,marker="o",label=rf"$q={q:.2f}$, $D={abs(b)*abs(np.cos(q))/np.sin(w0s(q)):.2f}$")
nv=np.linalg.svd(curve-curve.mean(0))[2][2]; nv*=np.sign(nv[2]+1e-12)
ax.set_box_aspect((1,1,1)); ax.set_axis_off(); ax.view_init(np.degrees(np.arcsin(nv[2])),np.degrees(np.arctan2(nv[1],nv[0])))
ax.set_title(r"(b) espinores de $k_\pm$ en la esfera de Bloch",fontsize=11); ax.legend(frameon=False,fontsize=9,loc="lower left")
plt.tight_layout(); plt.savefig("figs/interferencia.pdf")

# ---------- Figura 4: estados de borde = ondas planas con k complejo ----------
fig,ax=plt.subplots(1,2,figsize=(11,4.3)); n=30; AA=0.25; BB=np.sqrt(1-AA**2)
for xr,col in ((0,MUTED),(0.5,AQUA),(1.5,BLUE),(3.5,ORANGE)):
    rb=xr*AA; bb=rb+1j*np.sqrt(BB**2-rb**2); w,V=eig(n,0,AA,bb)
    wp=np.angle(np.sqrt(1-bb.imag**2)+1j*bb.imag); vv=estado(w,V,wp); P=abs(vv[0::2])**2+abs(vv[1::2])**2
    kap=np.arcsinh(xr); js=np.arange(n); th=np.exp(2*kap*(js-n+1)); th*=P[-1]/th[-1]
    ax[0].semilogy(js,P,"o",ms=4,color=col,label=rf"$\mathrm{{Re}}\,b/|a|={xr}$"); ax[0].semilogy(js,th,"-",color=col,lw=1)
ax[0].set_ylim(1e-14,1); ax[0].set_xlabel(r"$j$",color=MUTED); ax[0].set_ylabel(r"$P_j$",color=MUTED)
ax[0].set_title(r"(a) estado de borde $\lambda_+$; líneas: $e^{2\kappa j}$",fontsize=11); ax[0].legend(frameon=False,fontsize=9)
xs=np.linspace(-5.5,5.5,400); ax[1].plot(xs,np.arcsinh(xs),color=BLUE,lw=2,label=r"$\kappa=\mathrm{arcsinh}(\mathrm{Re}\,b/|a|)$")
rng=np.random.default_rng(2)
for _ in range(40):
    AA=rng.uniform(.15,.95); pb=rng.uniform(0,2*np.pi); bb=np.sqrt(1-AA**2)*np.exp(1j*pb); n=30
    w,V=eig(n,0,AA*np.exp(1j*rng.uniform(0,6.3)),bb); wp=np.angle(np.sqrt(1-bb.imag**2)+1j*bb.imag)
    vv=estado(w,V,wp); P=abs(vv[0::2])**2+abs(vv[1::2])**2; mk=P>1e-25
    sl=np.polyfit(np.arange(n)[mk],np.log(P[mk]),1)[0]
    ax[1].scatter(bb.real/AA,sl/2,s=18,color=INK,zorder=3)
ax[1].scatter([],[],s=18,color=INK,label="pendiente numérica / 2")
ax[1].set_xlabel(r"$\mathrm{Re}\,b/|a|$",color=MUTED); ax[1].set_ylabel(r"$\kappa=\ln|z_+|$",color=MUTED)
ax[1].set_title(r"(b) momento complejo: $|e^{ik}|=e^{\kappa}$",fontsize=11); ax[1].legend(frameon=False,fontsize=9)
for x_ in ax: estilo(x_)
plt.tight_layout(); plt.savefig("figs/bordes.pdf")

# ---------- Figuras 5 y 6 (adenda): componentes R, L y sus transformadas de Fourier, n=20 ----------
GREEN=AQUA
n=20; w,V=eig(n,al,a,b); o=np.argsort(w); js=np.arange(n); x=js.astype(float)                                   # teoría solo en los sitios
ks=np.linspace(-np.pi,np.pi,1500); F=np.exp(-1j*np.outer(ks,js))
wrap=lambda k: np.angle(np.exp(1j*k))
fig1,axs1=plt.subplots(8,5,figsize=(11,15.5),sharex=True)
fig2,axs2=plt.subplots(8,5,figsize=(11,15.5),sharex=True)
for ax,ax2,i in zip(axs1.flat,axs2.flat,o):
    v=V[:,i]; R,L=v[0::2],v[1::2]; wi=w[i]
    if abs(np.cos(wi))>A-1e-9:                              # estado de borde: R_j ~ z^j, L_j = z R_j
        z=(b.real+np.sign(np.cos(wi))*np.sqrt(b.real**2+A**2))/np.conj(a)
        tR=abs(z)**(2*x); tL=abs(z)**2*tR
        s_=(abs(R)**2+abs(L)**2).sum()/((1+abs(z)**2)*abs(z)**(2*js)).sum()
        tit=rf"borde, $\omega={wi:.2f}$, $|z|={abs(z):.2f}$"; col=ORANGE; kl=[np.angle(z)]
    else:
        q,k,u,c=ondas(n,a,b,wi); qe=q if q<np.pi/2 else q-np.pi   # mismos valores en los sitios
        cr=c[0]*np.conj(c[1])*np.exp(2j*qe*x); cr0=c[0]*np.conj(c[1])*np.exp(2j*qe*js)
        wp,wm=u[0][1],u[1][1]
        fR=lambda e: abs(b)**2*(abs(c[0])**2+abs(c[1])**2+2*np.real(e))
        fL=lambda e: abs(c[0]*wp)**2+abs(c[1]*wm)**2+2*np.real(e*wp*np.conj(wm))
        tR,tL=fR(cr),fL(cr); s_=(abs(R)**2+abs(L)**2).sum()/(fR(cr0)+fL(cr0)).sum()
        tit=rf"$m={round(q*n/np.pi)}$, $\omega={wi:.2f}$"; col=INK; kl=list(wrap(k))
    ax.bar(js-.2,abs(R)**2,width=.4,color=BLUE,alpha=.45); ax.bar(js+.2,abs(L)**2,width=.4,color=GREEN,alpha=.45)
    ax.plot(js-.2,s_*tR,"_",ms=5,mew=1.5,color=BLUE); ax.plot(js+.2,s_*tL,"_",ms=5,mew=1.5,color=GREEN)
    ax.set_title(tit,fontsize=8,color=col); ax.set_ylim(0,None); ax.set_yticks([])
    ax2.plot(ks,abs(F@R)**2,color=BLUE,lw=1.1); ax2.plot(ks,abs(F@L)**2,color=GREEN,lw=1.1)
    for kx in kl: ax2.axvline(kx,color=YEL if col==INK else ORANGE,ls="--",lw=.9)
    ax2.set_title(tit,fontsize=8,color=col); ax2.set_ylim(0,None); ax2.set_yticks([]); ax2.set_xlim(-np.pi,np.pi)
    for a_ in (ax,ax2):
        a_.tick_params(labelsize=6,colors=MUTED)
        for sp in a_.spines.values(): sp.set_color(GRID)
for a_ in axs1[-1]: a_.set_xlabel(r"$j$",color=MUTED,fontsize=8)
for a_ in axs2[-1]:
    a_.set_xlabel(r"$k$",color=MUTED,fontsize=8); a_.set_xticks([-np.pi,0,np.pi]); a_.set_xticklabels([r"$-\pi$","0",r"$\pi$"])
from matplotlib.lines import Line2D
h=[Line2D([],[],color=BLUE,lw=4,alpha=.6),Line2D([],[],color=GREEN,lw=4,alpha=.6)]
fig1.legend(h+[Line2D([],[],color=INK,marker="_",ls="",ms=8,mew=1.5)],[r"$|R_j|^2$",r"$|L_j|^2$","teoría (dos ondas planas / $|z|^{2j}$)"],loc="upper center",ncol=3,frameon=False,fontsize=10)
fig2.legend(h+[Line2D([],[],color=YEL,ls="--")],[r"$|\tilde R(k)|^2$",r"$|\tilde L(k)|^2$",r"$k_\pm$ (o $\mathrm{Re}\,k$ en el borde)"],loc="upper center",ncol=3,frameon=False,fontsize=10)
for f_,nm in ((fig1,"adenda_RL"),(fig2,"adenda_fourier")):
    f_.tight_layout(rect=(0,0,1,.985),h_pad=.6,w_pad=.4); f_.savefig(f"figs/{nm}.pdf")
