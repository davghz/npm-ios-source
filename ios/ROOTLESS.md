# Rootless iOS 15

Build npm **10.9.0** for the rootless Node.js 22 port:

```sh
bash ios/build-rootless-deb.sh
```

Output: `deb/npm22-ios_10.9.0-3+rootless_iphoneos-arm64.deb`.
Install the rootless `nodejs22-ios` package first.

The builder uses the complete `10.9.0-2` release package, since the Git
source tree excludes bundled `node_modules`. It installs the npm tree under
`/var/jb/usr/lib/node22/node_modules/npm`, with `npm`, `npx`, `npm22`, and
`npx22` in `/var/jb/usr/bin`. The wrappers invoke the stable `node` wrapper
and use `/var/jb/bin/sh` for lifecycle scripts.

For non-root users, global installs default to `$HOME/.local` unless a prefix
environment variable is explicitly supplied. A profile script adds its `bin`
directory to PATH in new shells.

Validated as `mobile` on rootless iOS 15.6.1: npm/npx versions, registry ping,
offline installation of a local package including its lifecycle script,
execution of its global command, and uninstall.
