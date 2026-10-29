import json, numpy as np, matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch
exec(open('coins.py').read().split("coins={")[0])
plt.rcParams.update({'font.size':10,'axes.titlesize':10})
CH=['$h_+$','$v_+$','$h_-$','$v_-$']; ENV=['$f^xf^y$','$f^xf^y$','$g^xf^y$','$f^xg^y$']
PH=['R','L','U','D']
def fmt(z):
    z=complex(np.round(z,3))
    if abs(z)<1e-9: return '0'
    r,i=z.real,z.imag
    if abs(i)<1e-9: return f'{r:.2f}'.replace('0.71','.71').replace('-0.71','-.71')
    if abs(r)<1e-9: return f'{i:.2f}i'
    return f'{r:.2f}\n{i:+.2f}i'
def heat(a,M,labels,mask=None,title='',small=False):
    a.imshow(abs(M),cmap='Blues',vmin=0,vmax=1)
    fs=6.5 if small else 8
    for i in range(4):
        for j in range(4):
            a.text(j,i,fmt(M[i,j]),ha='center',va='center',fontsize=fs,color='white' if abs(M[i,j])>.6 else 'black')
            if mask is not None and not mask[i,j]:
                a.add_patch(Rectangle((j-.5,i-.5),1,1,fill=False,hatch='////',edgecolor='#c65338',lw=0,alpha=.55))
                if abs(M[i,j])>1e-9: a.add_patch(Rectangle((j-.46,i-.46),.92,.92,fill=False,edgecolor='#c65338',lw=2))
    if mask is not None:
        for (x0,y0,w) in [(-.5,-.5,2),(1.5,1.5,1),(2.5,2.5,1)]:
            a.add_patch(Rectangle((x0,y0),w,w,fill=False,edgecolor='#2e7d32',lw=1.6,ls='--'))
    a.set_xticks(range(4)); a.set_yticks(range(4)); a.set_xticklabels(labels,fontsize=fs+1); a.set_yticklabels(labels,fontsize=fs+1)
    a.set_title(title,fontsize=fs+1.5)
    a.tick_params(length=0)
# ---------------- Figure 1: wall, envelopes, mask
fig=plt.figure(figsize=(13,10.5)); gs=fig.add_gridspec(2,4,height_ratios=[1,1.05],wspace=.45,hspace=.32)
a=fig.add_subplot(gs[0,0:2]); a.set_xlim(-.6,5.4); a.set_ylim(-1.7,2.4); a.axis('off')
for j in range(4):
    a.add_patch(plt.Circle((j,.6),.12,color='#17354B'))
    a.text(j,.15,f'x={j+1}',ha='center',fontsize=8)
for xw in (-.5,3.5): a.add_patch(Rectangle((xw-.05,-.35),.1,1.9,color='#888'))
for j in range(3): a.annotate('',xy=(j+.82,1.15),xytext=(j+.18,1.15),arrowprops=dict(arrowstyle='->',color='#245b89',lw=1.6))
for j in range(3): a.annotate('',xy=(j+.18,.05-.0),xytext=(j+.82,.05),arrowprops=dict(arrowstyle='->',color='#c65338',lw=1.6))
a.annotate('',xy=(3.15,.15),xytext=(3.15,1.05),arrowprops=dict(arrowstyle='->',color='#555',lw=1.4,connectionstyle='arc3,rad=-.6'))
a.annotate('',xy=(-.15,1.05),xytext=(-.15,.15),arrowprops=dict(arrowstyle='->',color='#555',lw=1.4,connectionstyle='arc3,rad=-.6'))
a.text(1.0,1.35,'$|R\\rangle$: moves right, keeps label',color='#245b89',fontsize=8.5)
a.text(1.0,-.35,'$|L\\rangle$: moves left, keeps label',color='#c65338',fontsize=8.5)
a.text(3.9,.6,'blocked move:\nstay, $R\\to L$\n(amplitude $+1$)',fontsize=8.5,va='center')
a.text(-.55,-1.05,'At a vertical wall the shift acts on the pair $\\{R,L\\}$ as the reversal $J$:\n'
 '$J|h_+\\rangle=+|h_+\\rangle,\\quad J|h_-\\rangle=-|h_-\\rangle$,  $h_\\pm=(R\\pm L)/\\sqrt{2}$.\n'
 'Same at horizontal walls for $\\{U,D\\}$ and $v_\\pm=(U\\pm D)/\\sqrt{2}$.',fontsize=8.5,va='center')
a.set_title('(a) The wall reverses the direction; $h_\\pm$, $v_\\pm$ are its $\\pm1$ eigenvectors',fontsize=10)
b=fig.add_subplot(gs[0,2:4]); Lx=6; m=2; j=np.arange(1,Lx+1); jj=np.arange(0,Lx+2); xx=np.linspace(0,Lx+1,400)
f=lambda t: np.sqrt(2/Lx)*np.cos(np.pi*m/Lx*(t-.5)); g=lambda t: np.sqrt(2/Lx)*np.sin(np.pi*m/Lx*(t-.5))
b.plot(xx,f(xx),color='#245b89',lw=1,alpha=.5); b.plot(xx,g(xx),color='#c65338',lw=1,alpha=.5)
b.plot(j,f(j),'o',color='#245b89',label='$f_m(x)=\\cos[\\pi m(x-\\frac{1}{2})/L]$  (even: $h_+$, $v_+$)')
b.plot(j,g(j),'s',color='#c65338',label='$g_m(x)=\\sin[\\pi m(x-\\frac{1}{2})/L]$  (odd: $h_-$, $v_-$)')
b.plot([0,Lx+1],[f(0),f(Lx+1)],'o',mfc='none',color='#245b89'); b.plot([0,Lx+1],[g(0),g(Lx+1)],'s',mfc='none',color='#c65338')
for xw in (.5,Lx+.5): b.axvline(xw,color='#888',lw=3,alpha=.6)
b.axhline(0,color='k',lw=.4); b.set_xticks(range(0,Lx+2)); b.set_xlabel('site $x$  (open symbols: mirror images behind the walls)')
b.text(Lx/2+.5,-.75,'$f(0)=+f(1)$, $g(0)=-g(1)$: the image has the wall parity',ha='center',fontsize=8.5)
b.set_ylim(-.82,.95); b.legend(fontsize=7.5,loc='upper center'); b.set_title(f'(b) Standing-wave envelopes on a segment ($L={Lx}$, $m={m}$)',fontsize=10)
c=fig.add_subplot(gs[1,1:3]); c.imshow(allowed,cmap='Greens',vmin=0,vmax=1.7)
for i in range(4):
    for k in range(4):
        c.text(k,i,'allowed' if allowed[i,k] else 'forbidden',ha='center',va='center',fontsize=8,color='black' if allowed[i,k] else '#c65338')
lab=[f'{CH[i]}\n{ENV[i]}' for i in range(4)]
c.set_xticks(range(4)); c.set_yticks(range(4)); c.set_xticklabels(lab,fontsize=8); c.set_yticklabels(lab,fontsize=8)
c.set_xlabel('input channel (column)'); c.set_ylabel('output channel (row)')
c.set_title('(c) The 16 cells of $\\widetilde C=Q^\\dagger CQ$ and the envelope rule',fontsize=10)
plt.savefig('Figures/fig01_wall_envelopes_mask.pdf',bbox_inches='tight'); plt.close()
# ---------------- Figure 2: anatomy of the square (Grover)
fig,ax=plt.subplots(1,2,figsize=(10.5,4.6))
heat(ax[0],G,PH,None,'(a) Physical basis: $C_{d\'d}$, rows = output $d\'$, columns = input $d$')
ax[0].set_xlabel('input direction'); ax[0].set_ylabel('output direction')
heat(ax[1],coh(G),[f'{CH[i]}\n{ENV[i]}' for i in range(4)],allowed,'(b) Coherent basis: $\\widetilde G=Q^\\dagger GQ$ with the envelope mask\n$\\mathcal{{L}}_{\\rm SW}=0$: no amplitude in a forbidden cell')
ax[1].set_xlabel('input channel'); ax[1].set_ylabel('output channel')
plt.tight_layout(); plt.savefig('Figures/fig02_reading_the_square_grover.pdf',bbox_inches='tight'); plt.close()
# ---------------- Figure 3: base coins
base=[('P (permutation)',P),('G (Grover)',G),('$F_c$ (compass Fourier)',Fc),('$DF_cD$, $D=\\mathrm{diag}(i,-i,1,1)$',Dg(np.pi/2,0)@Fc@Dg(np.pi/2,0)),
      ('$F_p$ (physical-order Fourier)',Fp),('$B_{\\rm I}$ (Bell, earlier report)',BI),('$B_{\\rm II}$ (Bell, reproduces IPR plot)',BII)]
res=np.load('coins_res.npy',allow_pickle=True).item()
Lst={'P (permutation)':res['P']['Lstar'],'G (Grover)':0,'$F_c$ (compass Fourier)':0,'$F_p$ (physical-order Fourier)':res['F_p']['Lstar'],'$B_{\\rm I}$ (Bell, earlier report)':res['B_I']['Lstar'],'$B_{\\rm II}$ (Bell, reproduces IPR plot)':res['B_II']['Lstar']}
fig,ax=plt.subplots(4,4,figsize=(15,16))
for k,(nm,C) in enumerate(base):
    r,cc=divmod(k,2)
    heat(ax[r,2*cc],C,PH,None,f'{nm}\nphysical, $|C|$ colour',small=True)
    extra=f', $\\mathcal{{L}}^*_{{\\rm SW}}$={Lst[nm]:.3f}' if nm in Lst else ''
    heat(ax[r,2*cc+1],coh(C),CH,allowed,f'{nm}\ncoherent: $\\mathcal{{L}}_{{\\rm SW}}$={Lsw(C):.3f}{extra}',small=True)
for a in [ax[3,2],ax[3,3]]: a.axis('off')
ax[3,2].text(0,.95,'How to read each pair of squares',fontsize=11,weight='bold',va='top')
ax[3,2].text(0,.82,'Left: the coin in the direction basis (R,L,U,D).\n  A column is the output produced by one input direction.\n'
 'Right: the same coin in the channels $h_\\pm=(R\\pm L)/\\sqrt{2}$,\n  $v_\\pm=(U\\pm D)/\\sqrt{2}$, ordered $(h_+,v_+,h_-,v_-)$.\n'
 '  Hatched cells change the spatial envelope (forbidden);\n  a red frame marks a nonzero forbidden amplitude.\n  Dashed green boxes: the allowed $2+1+1$ blocks.\n'
 '$\\mathcal{L}_{\\rm SW}=\\frac{1}{4}\\sum_{\\rm forbidden}|\\widetilde C_{ij}|^2$ is the mean probability\n  per step of leaving the fixed standing-wave sectors.\n'
 '$\\mathcal{L}^*_{\\rm SW}$: same after the best gauge $C\\to DCD$\n  (numerical minimum for $P$, $F_p$, $B_{\\rm I}$, $B_{\\rm II}$).\n'
 'Zero in a square is sufficient for an exact block solution;\n  a nonzero value is not a proof of non-integrability\n  (see $P$: $\\mathcal{L}_{\\rm SW}=\\mathcal{L}^*_{\\rm SW}=1/2$, exactly solvable by routing).',fontsize=9,va='top')
plt.tight_layout(); plt.savefig('Figures/fig03_base_coins_16cells.pdf',bbox_inches='tight'); plt.close()
# ---------------- Figure 4: deformations
fig,ax=plt.subplots(2,4,figsize=(16,8.4))
for k,t in enumerate([0,np.pi/8,np.pi/4,np.pi/2]):
    lab=['0','\\pi/8','\\pi/4','\\pi/2'][k]
    C=CG(t); heat(ax[0,k],coh(C),CH,allowed,f'$C_G({lab})=Ge^{{-i\\theta V}}$\n$\\mathcal{{L}}_{{\\rm SW}}=\\mathcal{{L}}^*_{{\\rm SW}}$={Lsw(C):.3f}',small=True)
    C=BIIt(t); heat(ax[1,k],coh(C),CH,allowed,f'$B_{{\\rm II}}({lab})=B_{{\\rm II}}e^{{-i\\theta V}}$\n$\\mathcal{{L}}_{{\\rm SW}}$={Lsw(C):.3f}',small=True)
plt.suptitle('The same rotation $e^{-i\\theta V}$, $V=|h_-\\rangle\\langle v_-|+|v_-\\rangle\\langle h_-|$ (acts on input columns $h_-$, $v_-$)',fontsize=12)
plt.tight_layout(); plt.savefig('Figures/fig04_deformed_coins_16cells.pdf',bbox_inches='tight'); plt.close()
print('done')
