# npm for iOS

This branch packages **npm 12.2.2** and npx for the native **Node.js 26.13.1**
port on rootless jailbroken iOS 15 or later. The complete npm release is
verified against its registry SHA-512 integrity value before packaging.

```sh
python3 ios/build-latest-rootless-deb.py
```

Output: `deb/npm22-ios_12.2.2-1+rootless_iphoneos-arm64.deb`.
Install the matching rootless `nodejs22-ios` 26.13.1 package first, then
install this package with dpkg or your package manager.

```sh
node --version
npm --version
npx --version
npm ping
```

The historical Debian package identifier `npm22-ios` and commands `npm22` /
`npx22` remain available for compatibility. The actual npm version is 12.2.2.
The payload lives under `/var/jb/usr/lib/nodejs/node_modules/npm`. Global
installs as mobile default to `$HOME/.local`; root uses `/var/jb/usr`. New
shells include the mobile `bin` directory in PATH. See
[rootless details](ios/ROOTLESS.md).

The `source/` directory mirrors the published npm 12.2.2 source, excluding
bundled `node_modules` from Git. The builder fetches the complete matching
release, including those dependencies. Its exact release metadata is saved
in [npm-release.json](ios/npm-release.json).

Older rootful and rootless npm 10.9 packages remain in `deb/` for rollback.
