#!/usr/bin/env bash
# Full test pipeline:
#   1. dune runtest    -- unit + integration tests for the OCaml side
#   2. tools/build-site.sh  -- rebuild the on-disk site (including smoke)
#   3. tools/playwright-check.mjs -- end-to-end browser test
#
# Exits non-zero on any failure. Run from anywhere.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

bold '[1/3] dune runtest (unit + integration)'
opam exec -- dune runtest

bold '[2/3] build site'
tools/build-site.sh

bold '[3/3] playwright end-to-end'
SERVER_PID=""
if ! curl -sf -o /dev/null http://localhost:8765/_site/test/smoke.html; then
  green "  starting http.server on 8765 for the duration of the test"
  python3 -m http.server 8765 --directory . >/dev/null 2>&1 &
  SERVER_PID=$!
  # give it a moment to bind
  for _ in 1 2 3 4 5; do
    sleep 0.3
    curl -sf -o /dev/null http://localhost:8765/_site/test/smoke.html && break
  done
fi
trap '[ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null || true' EXIT

node "$SCRIPT_DIR/playwright-check.mjs"

green 'All tests passed.'
