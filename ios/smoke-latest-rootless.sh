#!/var/jb/bin/sh
set -eu
PATH="/var/jb/usr/bin:/var/jb/bin:$HOME/.local/bin:${PATH:-/usr/bin:/bin}"
export PATH
[ "$(node --version)" = v26.13.1 ]
[ "$(npm --version)" = 12.2.2 ]
[ "$(npx --version)" = 12.2.2 ]
npm ping

WORK="$(mktemp -d)"
TEST_PACKAGE=codex-rootless-runtime-smoke
cleanup() {
    npm uninstall -g "$TEST_PACKAGE" --offline --no-audit --no-fund >/dev/null 2>&1 || true
    rm -rf "$WORK"
}
trap cleanup EXIT HUP INT TERM
mkdir "$WORK/package"
cat > "$WORK/package/package.json" <<'EOF'
{"name":"codex-rootless-runtime-smoke","version":"1.0.0","bin":{"codex-rootless-smoke":"cli.js"},"scripts":{"install":"node -e \"require('fs').writeFileSync('installed.ok','ok')\""}}
EOF
cat > "$WORK/package/cli.js" <<'EOF'
#!/usr/bin/env node
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
assert.equal(fs.readFileSync(path.join(__dirname, 'installed.ok'), 'utf8'), 'ok');
console.log('PASS: npm global install, approved lifecycle script, and executable');
EOF
chmod 755 "$WORK/package/cli.js"
tar -cf "$WORK/test.tar" -C "$WORK" package
# The minimal rootless bootstrap need not provide a gzip command.
node - "$WORK" <<'JS'
const fs = require('node:fs');
const zlib = require('node:zlib');
const path = require('node:path');
const directory = process.argv[2];
fs.writeFileSync(path.join(directory, 'test.tgz'),
  zlib.gzipSync(fs.readFileSync(path.join(directory, 'test.tar'))));
JS
# Local tarball approvals match the exact source, not its claimed package name.
npm install -g "$WORK/test.tgz" --offline --no-audit --no-fund \
    --allow-scripts="$WORK/test.tgz"
codex-rootless-smoke
