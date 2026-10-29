import numpy as np, sys, matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
sys.path.insert(0,'/home/claude/mix')
from core import rect, graph, floquet
exec(open('coins.py').read().split("coins={")[0])
plt.rcParams.update({'font.size':10})
def fprof(L,m,j): return np.sqrt((2-(m==0))/L)*np.cos(np.pi*m/L*(j-.5))
def gprof(L,m,j): return np.sqrt((2-(m==L))/L)*np.sin(np.pi*m/L*(j-.5))
# ---------------- Figure 12: identity coin, cycles
fig=plt.figure(figsize=(15,4.8)); gs=fig.add_gridspec(1,3,width_ratios=[1.25,1,1.1],wspace=.32)
a=fig.add_subplot(gs[0]); a.axis('off'); a.set_xlim(-1.2,8.6); a.set_ylim(-1.6,2.6)
N=6
for x in range(N):
    a.text(x,1.55,f'$|{x+1},R\\rangle$',ha='center',fontsize=8,color='#245b89'); a.text(x,-.05,f'$|{x+1},L\\rangle$',ha='center',fontsize=8,color='#c65338')
    a.plot(x,1.25,'o',color='#245b89'); a.plot(x,.3,'o',color='#c65338')
for x in range(N-1):
    a.annotate('',xy=(x+.85,1.25),xytext=(x+.15,1.25),arrowprops=dict(arrowstyle='->',color='#245b89'))
    a.annotate('',xy=(x+.15,.3),xytext=(x+.85,.3),arrowprops=dict(arrowstyle='->',color='#c65338'))
a.annotate('',xy=(N-1+.1,.42),xytext=(N-1+.1,1.13),arrowprops=dict(arrowstyle='->',color='#555',connectionstyle='arc3,rad=-.9'))
a.annotate('',xy=(-.1,1.13),xytext=(-.1,.42),arrowprops=dict(arrowstyle='->',color='#555',connectionstyle='arc3,rad=-.9'))
a.text(N-.3,.78,'wall',fontsize=8); a.text(-1.15,.78,'wall',fontsize=8)
a.text(-1.1,-.85,'With $C=I$ the walk is the shift alone: every row is one closed cycle of\n'
       '$2N_x$ basis states, every column one of $2N_y$. A state never leaves its cycle.',fontsize=8.5)
a.set_title(f'(a) One row ($N_x={N}$): a single cycle of length $2N_x={2*N}$',fontsize=10)
b=fig.add_subplot(gs[1]); nx,ny=8,5
t=np.linspace(0,2*np.pi,300); b.plot(np.cos(t),np.sin(t),color='#bbb',lw=.8)
zr=np.exp(2j*np.pi*np.arange(2*nx)/(2*nx)); zc=np.exp(2j*np.pi*np.arange(2*ny)/(2*ny))
b.plot(zr.real,zr.imag,'o',ms=9,mfc='none',color='#245b89',label=f'rows: $e^{{2\\pi ik/{2*nx}}}$, each $\\times N_y={ny}$')
b.plot(zc.real,zc.imag,'s',ms=5,color='#c65338',label=f'columns: $e^{{2\\pi ik/{2*ny}}}$, each $\\times N_x={nx}$')
pts=rect(nx,ny); idx,nb=graph(pts); ev=np.linalg.eigvals(floquet(nb,np.eye(4)).toarray())
b.plot(ev.real,ev.imag,'k.',ms=2,label=f'numerical eigenvalues ({len(ev)})')
b.set_aspect('equal'); b.set_xlim(-1.35,1.35); b.set_ylim(-1.35,1.6); b.legend(fontsize=7.5,loc='upper center',ncol=1)
b.set_title(f'(b) Spectrum of $U=S$ on ${nx}\\times{ny}$: roots of unity',fontsize=10); b.set_xticks([]); b.set_yticks([])
c=fig.add_subplot(gs[2]); Nx,m=8,2; k=np.pi*m/Nx; s2=np.sqrt(2); j=np.arange(1,Nx+1)
f=fprof(Nx,m,j); g=gprof(Nx,m,j)
vR,vL=f/s2,f/s2; W1=[];W2=[]
for step in range(17):
    hpc=(vR+vL)/s2; hmc=(vR-vL)/s2
    W1.append(np.dot(f,hpc)**2); W2.append(np.dot(g,hmc)**2)
    nR=np.zeros(Nx); nL=np.zeros(Nx); nR[1:]+=vR[:-1]; nL[-1]+=vR[-1]; nL[:-1]+=vL[1:]; nR[0]+=vL[0]; vR,vL=nR,nL
tt=np.linspace(0,16,400)
c.plot(tt,np.cos(k*tt)**2,color='#245b89',lw=1); c.plot(tt,np.sin(k*tt)**2,color='#c65338',lw=1)
c.plot(range(17),W1,'o',color='#245b89',label='weight in $f_m\\,h_+$ (cosine envelope)')
c.plot(range(17),W2,'s',color='#c65338',label='weight in $g_m\\,h_-$ (sine envelope)')
c.plot(range(17),np.array(W1)+np.array(W2),'k_',ms=10,label='sum (stays 1: never leaves the pair)')
c.set_xlabel('step $t$'); c.set_ylim(-.05,1.25); c.legend(fontsize=7.5,loc='upper right')
c.set_title(f'(c) $S$ on one row rotates $f_m h_+$ into $g_m h_-$\n($N_x={Nx}$, $m={m}$, angle $\\pi m/N_x$ per step)',fontsize=10)
plt.savefig('Figures/fig12_identity_coin_cycles.pdf',bbox_inches='tight'); plt.close()
# ---------------- Figure 13: standing waves in 2D
Nx,Ny,m,n=12,9,3,2
X,Y=np.meshgrid(np.arange(1,Nx+1),np.arange(1,Ny+1))
env={'$h_+$ and $v_+$:  $f_m(x)f_n(y)$':fprof(Nx,m,X)*fprof(Ny,n,Y),'$h_-$:  $g_m(x)f_n(y)$':gprof(Nx,m,X)*fprof(Ny,n,Y),'$v_-$:  $f_m(x)g_n(y)$':fprof(Nx,m,X)*gprof(Ny,n,Y)}
fig,ax=plt.subplots(2,3,figsize=(15,8.3))
for a_,(nm,E) in zip(ax[0],env.items()):
    vm=abs(E).max(); im=a_.imshow(E,origin='lower',cmap='RdBu_r',vmin=-vm,vmax=vm,extent=[.5,Nx+.5,.5,Ny+.5])
    a_.set_title(f'envelope of {nm}',fontsize=10); a_.set_xlabel('$x$'); a_.set_ylabel('$y$'); plt.colorbar(im,ax=a_,fraction=.03)
    for xw in (.5,Nx+.5): a_.axvline(xw,color='k',lw=2)
    for yw in (.5,Ny+.5): a_.axhline(yw,color='k',lw=2)
# eigenstates: identity coin and Grover in the sector K_mn
def full_state(alpha):
    pts=rect(Nx,Ny); idx,nb=graph(pts); V=len(pts); psi=np.zeros(4*V,complex)
    for i,(x0,y0) in enumerate(pts):
        x,y=x0+1,y0+1
        hp_=np.array([1,1,0,0])/s2; vp_=np.array([0,0,1,1])/s2; hm_=np.array([1,-1,0,0])/s2; vm_=np.array([0,0,1,-1])/s2
        psi[4*i:4*i+4]=(alpha[0]*fprof(Nx,m,x)*fprof(Ny,n,y)*hp_+alpha[1]*fprof(Nx,m,x)*fprof(Ny,n,y)*vp_
                        +alpha[2]*gprof(Nx,m,x)*fprof(Ny,n,y)*hm_+alpha[3]*fprof(Nx,m,x)*gprof(Ny,n,y)*vm_)
    return pts,nb,psi
cx,sx_=np.cos(np.pi*m/Nx),np.sin(np.pi*m/Nx); cy,sy_=np.cos(np.pi*n/Ny),np.sin(np.pi*n/Ny)
Smn=np.array([[cx,0,-sx_,0],[0,cy,0,-sy_],[sx_,0,cx,0],[0,sy_,0,cy]])
for col,(nm,C,Cb) in enumerate([('identity coin $C=I$',np.eye(4),np.eye(4)),('Grover coin $G$',G,np.block([[np.array([[0,1],[1,0]]),np.zeros((2,2))],[np.zeros((2,2)),-np.eye(2)]]))]):
    w,vv=np.linalg.eig(Smn@Cb); ph=np.angle(w); ok=(ph>1e-6)&(ph<np.pi-1e-6); kk=np.flatnonzero(ok)[np.argmax(ph[ok])] if 'Grover' in nm else np.argmin(abs(ph-np.pi*m/Nx)); al=vv[:,kk]
    pts,nb,psi=full_state(al); U=floquet(nb,C).toarray(); res=np.linalg.norm(U@psi-w[kk]*psi)/np.linalg.norm(psi)
    P=(abs(psi)**2).reshape(-1,4).sum(1); Pm=np.zeros((Ny,Nx))
    for i,(x0,y0) in enumerate(pts): Pm[y0,x0]=P[i]
    a_=ax[1,col]; im=a_.imshow(Pm/Pm.sum(),origin='lower',cmap='magma',extent=[.5,Nx+.5,.5,Ny+.5]); plt.colorbar(im,ax=a_,fraction=.03)
    a_.set_title(f'{nm}: eigenstate in $\\mathcal{{K}}_{{{m}{n}}}$, $\\varphi={np.angle(w[kk]):.3f}$\nspatial density $P(x,y)$; residual $|U\\psi-\\lambda\\psi|$={res:.1e}',fontsize=9.5)
    a_.set_xlabel('$x$'); a_.set_ylabel('$y$'); print(nm,'residual',res,'eigs',np.round(np.angle(w),4))
ax[1,2].axis('off')
ax[1,2].text(0,.95,f'Rectangle ${Nx}\\times{Ny}$, mode $(m,n)=({m},{n})$',fontsize=11,weight='bold',va='top')
ax[1,2].text(0,.82,'Top: the three distinct envelopes of the sector\n$\\mathcal{K}_{mn}$ (red/blue = sign). The walls are the\nblack frame; cosines have zero slope at the wall,\nsines change sign across the mirror plane.\n\n'
 'Bottom left: with $C=I$ the sector splits into an\n$x$-pair $(a,c)$ and a $y$-pair $(b,d)$. The eigenstate\n$(a-ic)/\\sqrt{2}$ runs around the row cycle: its density\nis uniform along $x$ ($f_m^2+g_m^2$ is constant) and\nkeeps only the $y$ standing wave.\n\n'
 'Bottom middle: Grover couples $h_+$ with $v_+$,\nso its eigenstates mix all four channels and show\na genuine two-dimensional standing-wave pattern.',fontsize=9,va='top')
plt.tight_layout(); plt.savefig('Figures/fig13_standing_waves_2D.pdf',bbox_inches='tight'); plt.close()
