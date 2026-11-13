#!/usr/bin/env python3
"""Build a pinned npm release for the native rootless Node.js port."""
import base64
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
VERSION = '12.2.2'
PACKAGE_VERSION = VERSION + '-1+rootless'


def main():
    # Use the reviewed release identity, rather than trusting fresh registry
    # metadata to supply both the archive and its expected digest on each build.
    provenance = json.loads((ROOT / 'ios/npm-release.json').read_text())
    if provenance['name'] != 'npm' or provenance['version'] != VERSION:
        raise RuntimeError('Pinned npm release metadata does not match this builder')
    with urllib.request.urlopen(provenance['tarball'], timeout=60) as response:
        payload = response.read()
    algorithm, expected = provenance['integrity'].split('-', 1)
    actual = base64.b64encode(hashlib.new(algorithm, payload).digest()).decode()
    if actual != expected:
        raise RuntimeError('npm release integrity check failed')
    with tempfile.TemporaryDirectory(prefix='npm12-rootless-') as directory:
        work = Path(directory)
        with tarfile.open(fileobj=io.BytesIO(payload), mode='r:gz') as archive:
            archive.extractall(work / 'release', filter='data')
        stage = work / 'pkg'
        npm = stage / 'var/jb/usr/lib/nodejs/node_modules/npm'
        npm.parent.mkdir(parents=True)
        shutil.copytree(work / 'release/package', npm, symlinks=True)
        bindir = stage / 'var/jb/usr/bin'
        bindir.mkdir(parents=True)
        for cli in ('npm', 'npx'):
            wrapper = bindir / cli
            wrapper.write_text(f'''#!/var/jb/bin/sh
PATH="/var/jb/usr/bin:/var/jb/bin:${{PATH:-/usr/bin:/bin}}"
export PATH
if [ -z "${{npm_config_prefix:-${{NPM_CONFIG_PREFIX:-}}}}" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        npm_config_prefix=/var/jb/usr
    else
        npm_config_prefix="$HOME/.local"
    fi
    export npm_config_prefix
fi
export npm_config_script_shell="${{npm_config_script_shell:-/var/jb/bin/sh}}"
exec /var/jb/usr/bin/node /var/jb/usr/lib/nodejs/node_modules/npm/bin/{cli}-cli.js "$@"
''')
            wrapper.chmod(0o755)
            (bindir / (cli + '22')).symlink_to(cli)
        profile = stage / 'var/jb/etc/profile.d/node22-path.sh'
        profile.parent.mkdir(parents=True)
        profile.write_text('''case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH
''')
        control = stage / 'DEBIAN'
        control.mkdir()
        control_text = f'''Package: npm22-ios
Name: npm 12 (Rootless)
Version: {PACKAGE_VERSION}
Architecture: iphoneos-arm64
Maintainer: davgz
Depends: nodejs22-ios (>= 26.13.1), firmware (>= 15.0), dash
Section: Development
Description: npm {VERSION} and npx for native rootless Node.js
 Includes the complete verified upstream release and legacy npm22/npx22 aliases.
'''
        (control / 'control').write_text(control_text)
        destination = ROOT / f'deb/npm22-ios_{PACKAGE_VERSION}_iphoneos-arm64.deb'
        destination.parent.mkdir(exist_ok=True)
        subprocess.run(['dpkg-deb', '--root-owner-group', '-Zgzip', '-b', str(stage), str(destination)], check=True)
        destination.with_suffix('.deb.sha256').write_text(
            hashlib.sha256(destination.read_bytes()).hexdigest() + '  ' + destination.name + '\n')
        (ROOT / 'DEBIAN/control').write_text(control_text)
        print('Built:', destination)


if __name__ == '__main__':
    main()
