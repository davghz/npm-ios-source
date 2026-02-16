# npm iOS Source (Node 22 / npm 10.9.0)

This repository contains the npm source tree used in the iOS `node22` package build, plus iOS runtime wrappers used on a jailbroken iPhone X (iOS 13.2.3).

## Contents

- `source/`: npm source from Node `deps/npm` (version `10.9.0`)
- `ios/bin/npm22`: iOS wrapper for npm CLI
- `ios/bin/npx22`: iOS wrapper for npx CLI
- `patches/`: notes/patch artifacts for iOS packaging
- `deb/`: prebuilt iOS package artifacts

## Upstream

- npm upstream project: https://github.com/npm/cli
- This source snapshot came from Node `v22.12.0` distribution tree (`deps/npm`).

## iOS runtime notes

The wrappers use:

- `--max-opt=0`
- `--no-sparkplug`
- `--max-old-space-size=512`
- `--disable-wasm-trap-handler`

and retry transient crash exit codes (`134`, `137`, `138`) that can occur on this iOS 13 target.

## Verify on device

```sh
/usr/local/bin/npm22 -v
/usr/local/bin/npx22 -v
```

Expected npm version:

```text
10.9.0
```

## Prebuilt Debian package

This repo includes a ready-to-install package:

- `deb/npm22-ios_10.9.0-2_iphoneos-arm.deb`

Install on device:

```sh
dpkg -i /var/root/npm22-ios_10.9.0-2_iphoneos-arm.deb
```
