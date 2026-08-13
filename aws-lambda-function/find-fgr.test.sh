#!/usr/bin/env bash
# Self-check for find-fgr.sh. Run: ./find-fgr.test.sh
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
find_fgr="$root/find-fgr.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

# missing fgr
if "$find_fgr" "$tmp/lambda" >/dev/null 2>&1; then
  fail "expected miss when fgr is not installed"
fi

# fgr in parent of source_dir
mkdir -p "$tmp/repo/lambda/src" "$tmp/repo/node_modules/.bin"
printf '#!/bin/sh\necho "fgr $*"\n' >"$tmp/repo/node_modules/.bin/fgr"
chmod +x "$tmp/repo/node_modules/.bin/fgr"

out="$("$find_fgr" "$tmp/repo/lambda" lambda build --source-dir x)"
[ "$out" = "fgr lambda build --source-dir x" ] || fail "parent walk: got '$out'"

# fgr in source_dir wins over parent
mkdir -p "$tmp/repo/lambda/node_modules/.bin"
printf '#!/bin/sh\necho "local $*"\n' >"$tmp/repo/lambda/node_modules/.bin/fgr"
chmod +x "$tmp/repo/lambda/node_modules/.bin/fgr"

out="$("$find_fgr" "$tmp/repo/lambda" hello)"
[ "$out" = "local hello" ] || fail "source_dir wins: got '$out'"

echo "ok"
