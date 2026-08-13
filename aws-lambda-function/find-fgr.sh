#!/usr/bin/env bash
# Resolve repo-installed `fgr` by walking up from SOURCE_DIR.
# Usage: find-fgr.sh SOURCE_DIR [fgr args...]
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "ERROR: source directory argument is required" >&2
  exit 1
fi

source_dir="$1"
shift

dir="$source_dir"
fgr=""
while [ "$dir" != "/" ]; do
  if [ -x "$dir/node_modules/.bin/fgr" ]; then
    fgr="$dir/node_modules/.bin/fgr"
    break
  fi
  dir="$(dirname "$dir")"
done

if [ -z "$fgr" ]; then
  echo "ERROR: fgr not found under ${source_dir} (or parents)." >&2
  echo "Install @figurepos/platform-tooling via npm ci / pnpm install in the service repo or lambda directory before terraform apply." >&2
  exit 1
fi

exec "$fgr" "$@"
