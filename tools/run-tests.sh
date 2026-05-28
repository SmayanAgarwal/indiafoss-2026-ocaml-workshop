#!/usr/bin/env bash
# Full test pipeline -- the pre-recording sanity check.
#   1. tools/audit-activities.py  -- activity-fresh-code rule
#                                    (M07-L01 / M05-L04 failure
#                                    mode: chapter walks function
#                                    through, activity asks
#                                    student to recreate it)
#   2. KC-comment sweep            -- any unresolved silent-fix
#                                    or blocker comments KC drops
#                                    in lecture markdown. KC! and
#                                    KC? block; plain KC: warns.
#   3. dune runtest                -- mdx code blocks compile
#   4. tools/build-site.sh         -- rebuild + smoke pages
#   5. tools/playwright-check.mjs  -- end-to-end browser test
#
# Exits non-zero on any failure. Run from anywhere.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

bold '[1/5] activity-fresh-code audit'
python3 tools/audit-activities.py

bold '[2/5] KC-comment sweep'
# `KC:` (silent fix) is allowed to linger; `KC?:` and `KC!:` are
# blockers per CLAUDE.md. Surface all three so the user sees them.
KC_HITS=$(grep -rEn '<!--[[:space:]]*KC[!?]?:' \
  lectures/ tools/ assets/ README.md 2>/dev/null || true)
if [ -n "$KC_HITS" ]; then
  red "Unresolved KC comments:"
  echo "$KC_HITS"
  # Fail only on KC! or KC? (the explicit-attention markers).
  # Plain KC: is the silent-fix backlog and doesn't block recording.
  if echo "$KC_HITS" | grep -qE '<!--[[:space:]]*KC[!?]:'; then
    red 'KC!: or KC?: present -- resolve before recording.'
    exit 1
  fi
  green '  (only silent KC: notes; not blocking.)'
else
  green '  no KC comments outstanding'
fi

bold '[3/5] dune runtest (mdx + OCaml tests)'
opam exec -- dune runtest

bold '[4/5] build site'
tools/build-site.sh

bold '[5/5] playwright end-to-end'
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
