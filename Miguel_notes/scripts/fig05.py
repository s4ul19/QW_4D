import json, numpy as np, matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
from scipy.optimize import minimize
exec(open('coins.py').read().split("coins={")[0])
def Lstar_fast(C):
    best=9
    for a0 in np.linspace(0,np.pi,7):
        for b0 in np.linspace(0,np.pi,7):
            r=minimize(lambda x: Lsw(Dg(*x)@C@Dg(*x)),[a0,b0],method='Nelder-Mead',options=dict(xatol=1e-10,fatol=1e-13))
            best=min(best,r.fun)
    return best
tt=np.linspace(0,np.pi,41)
LB=[Lsw(BIIt(t)) for t in tt]; LBs=[Lstar_fast(BIIt(t)) for t in tt]
json.dump({'theta':list(tt),'Lsw':LB,'Lstar':LBs},open('bell_II_Lstar.json','w'))
print('L*(B_II(theta)) min/max:',min(LBs),max(LBs)); print(np.round(np.c_[tt/np.pi,LBs][::5],4))
s=json.load(open('/home/claude/mix/sweep_31x23.json')); z=json.load(open('/home/claude/mix/sizes.json')); q=json.load(open('/home/claude/mix/bell_partners.json')); nul=json.load(open('/home/claude/mix/nulls.json'))
fig,ax=plt.subplots(1,2,figsize=(15,5.4))
# Grover
a=ax[0]; t2=np.linspace(0,np.pi/2,200)
a.plot(t2/np.pi,.5*np.sin(t2)**2,color='#c65338',lw=2,label=r'$\mathcal{L}_{\rm SW}=\mathcal{L}^*_{\rm SW}=\frac{1}{2}\sin^2\theta$ (exact)')
a.set_xlabel(r'$\theta/\pi$'); a.set_ylabel('leakage',color='#c65338'); a.set_ylim(0,.7); a.set_xlim(0,.5)
a2=a.twinx(); pts=sorted((float(k.split('|')[1]),v['r'],v['se']) for k,v in s.items() if k.startswith('grover'))
x,y,e=map(np.array,zip(*pts)); a2.errorbar(x/np.pi,y,yerr=e,fmt='o-',color='#245b89',label=r'$\langle r\rangle$, $31\times23$')
for sz,mk in [('21x15','s'),('41x31','^')]:
    qq=[(float(k.split('|')[2]),v['r'],v['se']) for k,v in z.items() if k.startswith(sz+'|grover')]
    if qq: x2,y2,e2=map(np.array,zip(*qq)); a2.errorbar(x2/np.pi,y2,yerr=e2,fmt=mk,mfc='none',ms=8,label=sz.replace('x',r'$\times$'))
a2.axhspan(nul['goe_mean']-nul['goe_sd'],nul['goe_mean']+nul['goe_sd'],color='#5b7d38',alpha=.15)
a2.axhline(.5307,ls='--',color='#5b7d38'); a2.axhline(.3863,ls=':',color='gray'); a2.set_ylim(.36,.62); a2.set_ylabel(r'$\langle r\rangle$',color='#245b89')
a2.text(.005,.537,'GOE',color='#5b7d38',fontsize=9); a2.text(.005,.392,'Poisson',color='gray',fontsize=9)
h1,l1=a.get_legend_handles_labels(); h2,l2=a2.get_legend_handles_labels(); a.legend(h1+h2,l1+l2,fontsize=8.5,loc='lower right')
a.set_title('(a) Modified Grover: envelope leakage switches on and $\\langle r\\rangle$ follows')
# Bell II
b=ax[1]; b.plot(tt/np.pi,LB,color='#c65338',lw=2,label=r'$\mathcal{L}_{\rm SW}$ (fixed modes) $=5/8$')
b.plot(tt/np.pi,LBs,color='#c65338',lw=1.5,ls='--',label=r'$\mathcal{L}^*_{\rm SW}$ (best gauge, numerical)')
qq=sorted((float(k),v['quartet']) for k,v in q.items()); xq,yq=map(np.array,zip(*qq))
b.plot(xq/np.pi,yq,'s:',color='#8a5a9e',label=r'fraction of levels in exact $\pi/2$ quartets')
b.set_ylim(0,1.05); b.set_xlim(0,1); b.set_xlabel(r'$\theta/\pi$'); b.set_ylabel('leakage / fraction')
b2=b.twinx(); pts=sorted((float(k.split('|')[1]),v['r'],v['se']) for k,v in s.items() if k.startswith('bell'))
x,y,e=map(np.array,zip(*pts)); b2.errorbar(x/np.pi,y,yerr=e,fmt='o-',color='#245b89',label=r'$\langle r\rangle$, $31\times23$')
for sz,mk in [('21x15','s'),('41x31','^')]:
    qz=[(float(k.split('|')[2]),v['r'],v['se']) for k,v in z.items() if k.startswith(sz+'|bell')]
    if qz: x2,y2,e2=map(np.array,zip(*qz)); b2.errorbar(x2/np.pi,y2,yerr=e2,fmt=mk,mfc='none',ms=8,label=sz.replace('x',r'$\times$'))
b2.axhline(.5996,ls='-.',color='#8a5a9e'); b2.axhline(.5307,ls='--',color='#5b7d38'); b2.axhline(.3863,ls=':',color='gray'); b2.set_ylim(.36,.62); b2.set_ylabel(r'$\langle r\rangle$',color='#245b89')
b2.text(.86,.585,'CUE',color='#8a5a9e',fontsize=9); b2.text(.86,.517,'GOE',color='#5b7d38',fontsize=9); b2.text(.86,.372,'Poisson',color='gray',fontsize=9)
h1,l1=b.get_legend_handles_labels(); h2,l2=b2.get_legend_handles_labels(); b.legend(h1+h2,l1+l2,fontsize=8,loc='upper center',bbox_to_anchor=(.5,.86))
b.set_title(r'(b) Modified Bell $B_{\rm II}(\theta)$: exact structures break, leakage does not track $\langle r\rangle$')
plt.tight_layout(); plt.savefig('Figures/fig05_mechanisms_leakage_vs_r.pdf',bbox_inches='tight')
