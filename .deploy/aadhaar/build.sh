#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE="${TMPDIR:-/tmp}/aadhaar-scanner-site.tar.gz"
OUTPUT="$ROOT/public"
EXPECTED_SHA256="d8f709d3dafc032680064081dc53d08b9f5dba111a318723d663dfdcc6715552"

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

cp "$ROOT/index.html" "$OUTPUT/index.html"
if [[ -d "$ROOT/assets" ]]; then
  cp -R "$ROOT/assets" "$OUTPUT/assets"
fi

cat "$ROOT"/.deploy/aadhaar/site.part* | base64 --decode > "$ARCHIVE"
ACTUAL_SHA256="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "Aadhaar scanner deployment archive checksum mismatch" >&2
  exit 1
fi

tar -xzf "$ARCHIVE" -C "$OUTPUT"
rm -f "$ARCHIVE"

test -f "$OUTPUT/aadhaar-qr-scanner/index.html"
test -f "$OUTPUT/aadhaar-qr-scanner/app.bundle.js"
echo "Prepared Vercel output at $OUTPUT"
