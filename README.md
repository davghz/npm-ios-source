# npm-ios-source

npm 10.9.0 packaged for jailbroken iOS, wrapping the Node.js v22 binary.

## What it is

This repository contains the npm 10.9.0 source tree (extracted from Node.js v22.12.0
`deps/npm`), iOS runtime wrapper scripts, DEBIAN packaging metadata, and a prebuilt
`.deb` ready to install on jailbroken iPhones.

- Installs `/usr/local/bin/npm22` and `/usr/local/bin/npx22`
- npm tree at `/usr/local/lib/node22/node_modules/npm`
- Wrappers retry transient crash codes (`134`, `137`, `138`) common on iOS 13

**Tested device:** iPhone X (`iPhone10,3`), iOS 13.2.3

## Toolchain overview

```
node22-ios-source  →  build  →  nodejs22-ios.deb  (Node runtime)
                                       ↓ (dependency)
npm-ios-source     →  build  →  npm22-ios.deb     (package manager)
```

## Prerequisite

**`nodejs22-ios` must be installed first.** See:
[node22-ios-source](https://github.com/davghz/node22-ios-source)

```bash
dpkg -i nodejs22-ios_22.12.0-18_iphoneos-arm.deb
```

## Install prebuilt (recommended)

Download `deb/npm22-ios_10.9.0-2_iphoneos-arm.deb` from this repo and install:

```bash
dpkg -i npm22-ios_10.9.0-2_iphoneos-arm.deb
```

Verify the SHA256 checksum:

```bash
sha256sum -c deb/SHA256SUMS
```

## Rebuild from source

If you want to produce the deb yourself from the packaging tree:

```bash
dpkg-deb --build deb/build-20260216-2/npm22-ios npm22-ios_10.9.0-2_iphoneos-arm.deb
```

The `DEBIAN/` directory at the repo root mirrors the packaging metadata.

## Verify on device

```bash
/usr/local/bin/npm22 -v    # 10.9.0
/usr/local/bin/npx22 -v    # 10.9.0
```

## Contents

| Path | Description |
|------|-------------|
| `source/` | npm 10.9.0 source from Node v22.12.0 `deps/npm` |
| `ios/bin/npm22` | iOS wrapper for npm CLI |
| `ios/bin/npx22` | iOS wrapper for npx CLI |
| `DEBIAN/control` | Debian package metadata |
| `deb/npm22-ios_10.9.0-2_iphoneos-arm.deb` | Prebuilt package |
| `deb/SHA256SUMS` | Checksums for prebuilt debs |
| `patches/IOS_RUNTIME_NOTES.md` | Runtime notes for iOS 13 |

## iOS runtime notes

The wrappers use these flags to work reliably on iOS 13:

- `--max-opt=0`
- `--no-sparkplug`
- `--max-old-space-size=512`
- `--disable-wasm-trap-handler`

`--jitless` is intentionally NOT used so WebAssembly remains available.

## Upstream

- npm upstream: https://github.com/npm/cli
- Node.js source: https://github.com/davghz/node22-ios-source
