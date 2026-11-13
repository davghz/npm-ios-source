#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="${1:-$ROOT/deb/npm22-ios_10.9.0-2_iphoneos-arm.deb}"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/npm22-rootless.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
PKG="$STAGE/pkg"
mkdir -p "$PKG/DEBIAN" "$PKG/var/jb/usr/bin" \
    "$PKG/var/jb/usr/lib/node22/node_modules/npm" "$PKG/var/jb/etc/profile.d"
# Git excludes node_modules in the source tree; use the complete release payload.
[ "$(dpkg-deb -f "$INPUT" Package)" = npm22-ios ]
[ "$(dpkg-deb -f "$INPUT" Version)" = 10.9.0-2 ]
dpkg-deb -x "$INPUT" "$STAGE/input"
NPM_SOURCE="$STAGE/input/usr/local/lib/node22/node_modules/npm"
[ -f "$NPM_SOURCE/node_modules/graceful-fs/package.json" ]
rsync -a --exclude=.DS_Store --exclude=.git "$NPM_SOURCE/" \
    "$PKG/var/jb/usr/lib/node22/node_modules/npm/"
cat > "$PKG/DEBIAN/control" <<'EOF'
Package: npm22-ios
Name: npm 10 (Rootless)
Version: 10.9.0-3+rootless
Architecture: iphoneos-arm64
Maintainer: davgz
Depends: nodejs22-ios (>= 22.12.0-27+rootless), firmware (>= 15.0), dash
Section: Development
Description: npm 10.9.0 and npx for rootless iOS
 Uses the native Node.js 22 port. Mobile global installs default to ~/.local.
EOF
for cli in npm npx; do
    cat > "$PKG/var/jb/usr/bin/${cli}22" <<EOF
#!/var/jb/bin/sh
PATH="/var/jb/usr/bin:/var/jb/bin:\${PATH:-/usr/bin:/bin}"
export PATH
# Give mobile a writable prefix; an explicit environment override takes priority.
if [ "\$(id -u)" -ne 0 ] && [ -z "\${npm_config_prefix:-\${NPM_CONFIG_PREFIX:-}}" ]; then
    export npm_config_prefix="\$HOME/.local"
fi
export npm_config_script_shell="\${npm_config_script_shell:-/var/jb/bin/sh}"
exec /var/jb/usr/bin/node /var/jb/usr/lib/node22/node_modules/npm/bin/${cli}-cli.js "\$@"
EOF
    chmod 755 "$PKG/var/jb/usr/bin/${cli}22"
    ln -s "${cli}22" "$PKG/var/jb/usr/bin/$cli"
done
cat > "$PKG/var/jb/etc/profile.d/node22-path.sh" <<'EOF'
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH
EOF
mkdir -p "$ROOT/deb"
OUTPUT="$ROOT/deb/npm22-ios_10.9.0-3+rootless_iphoneos-arm64.deb"
dpkg-deb --root-owner-group -Zgzip -b "$PKG" "$OUTPUT"
echo "Built: $OUTPUT"
