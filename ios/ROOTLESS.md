# npm 12 on rootless iOS 15

`ios/build-latest-rootless-deb.py` pins npm **12.2.2** and verifies the downloaded
archive against the reviewed SHA-512 integrity value in `ios/npm-release.json`
before extraction. It
packages the complete upstream release, including all bundled dependencies.

Build with Python 3.12 or later and `dpkg-deb`:

```sh
python3 ios/build-latest-rootless-deb.py
```

The package is `npm22-ios` version `12.2.2-1+rootless`, architecture
`iphoneos-arm64`. It requires the native rootless `nodejs22-ios` runtime at
version 26.13.1 or later. This is an in-place upgrade of the historical
package identifier; `npm`, `npx`, `npm22`, and `npx22` all run the new release.

The wrappers use the runtime's `/var/jb/usr/bin/node` launcher and
`/var/jb/bin/sh` for lifecycle scripts. For non-root users, global installs
default to `$HOME/.local` unless a prefix environment variable is supplied.
Root global installs default to `/var/jb/usr`, independent of the native Node
executable's private location. A profile script adds the mobile `bin`
directory to new shells.

The older `ios/build-rootless-deb.sh` builds the npm 10.9.0 rollback version.

On-device validation on iPhone X, iOS 15.6.1, with Node.js 26.13.1 passed
`npm ping`, global installation into the mobile prefix, a scoped lifecycle
script approval, and execution of the installed command. Run
`sh ios/smoke-latest-rootless.sh` on the device to repeat this check.

npm 12 requires explicit approval for dependency lifecycle scripts. The smoke
test approves only its exact local fixture tarball with `--allow-scripts`;
the package preserves npm's default approval policy.
