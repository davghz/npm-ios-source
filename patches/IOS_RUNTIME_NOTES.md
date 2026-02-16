# iOS Runtime Notes

These wrappers were validated on:

- Device: iPhone X (`iPhone10,3`)
- OS: iOS 13.2.3 (Darwin 19.0.0)
- Node: `v22.12.0` (`/usr/local/bin/node22`)
- npm: `10.9.0`

The wrappers intentionally avoid `--jitless` to preserve WebAssembly-capable runtime behavior for broader Node/OpenClaw compatibility.
