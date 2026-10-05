from pathlib import Path
import hashlib, os, shutil, tempfile, datetime
base=Path(__file__).resolve().parent
target=Path('/Users/saul/Desktop/ChatGPT/QWProgramming/FunctionsTester.nb')
staged=base/'FunctionsTester.nb'
original_hash=(base/'original.sha256').read_text().strip()
staged_hash=(base/'staged.sha256').read_text().strip()
if hashlib.sha256(target.read_bytes()).hexdigest()!=original_hash:
    raise SystemExit('El notebook cambio desde la lectura; no se sobrescribio. Hay que incorporar los cambios recientes.')
content=staged.read_bytes()
if hashlib.sha256(content).hexdigest()!=staged_hash:
    raise SystemExit('La copia preparada cambio desde la validacion; no se sobrescribio.')
backup=target.with_name('FunctionsTester.before_orthogonal_orientation.'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'.nb.bak')
shutil.copy2(target,backup)
fd,temp_path=tempfile.mkstemp(prefix='.FunctionsTester.orientation.',suffix='.nb',dir=target.parent)
with os.fdopen(fd,'wb') as stream:
    stream.write(content)
    stream.flush()
    os.fsync(stream.fileno())
os.chmod(temp_path,target.stat().st_mode & 0o777)
os.replace(temp_path,target)
assert hashlib.sha256(target.read_bytes()).hexdigest()==staged_hash
print('Actualizado:',target)
print('Respaldo:',backup)
print('SHA256:',staged_hash)
