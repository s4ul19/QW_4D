from pathlib import Path
import re, hashlib
base=Path(__file__).resolve().parent
original=(base/'original.nb').read_text()
section=(base/'section.txt').read_text().strip()
end='(* End of Notebook Content *)'
clean=original[:original.index(end)+len(end)]+'\n'
clean=re.sub(r'\(\*CacheID:.*?\*\)\n','',clean,flags=re.S)
clean=re.sub(r'\(\* Internal cache information:\n.*?\*\)\n','',clean,count=1,flags=re.S)
marker='\n},\nWindowSize->'
assert clean.count(marker)==1
addition=',\n\n'+section
updated=clean.replace(marker,addition+marker,1)
assert updated.replace(addition,'',1)==clean
(base/'FunctionsTester.nb').write_text(updated)
(base/'staged.sha256').write_text(hashlib.sha256(updated.encode()).hexdigest())
print('Staged notebook:',base/'FunctionsTester.nb')
