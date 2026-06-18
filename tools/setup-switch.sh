#!/usr/bin/env bash
# Provision the two opam switches the repo's code validation needs.
#
#   * default switch (>= 5.2.0): validates M01-M10 and M12 lecture
#     code blocks, plus the M03/M05/M09 practice worksheets. Its leaf
#     packages (mdx, qcheck, qcheck-core, ounit2) are declared in
#     nptel-ocaml.opam, so `opam install . --deps-only` installs them.
#
#   * 5.2.0+ox switch: validates the M11 (OxCaml) cells, whose mode
#     syntax compiles only on the OxCaml compiler. This switch is used
#     BARE -- no extra packages -- so a plain opam file cannot express
#     it (the +ox compiler variant comes from a custom opam repo).
#     That is what this script is for.
#
# Idempotent: re-running it is safe. Run from anywhere.
#
# After this, validate everything with:
#   opam exec -- dune runtest                                   # default
#   opam exec --switch 5.2.0+ox -- dune build @lectures/runtest # M11
# or just: bash tools/run-tests.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OX_SWITCH="5.2.0+ox"
OX_REPO_NAME="oxcaml"
OX_REPO_URL="https://github.com/oxcaml/opam-repository.git"

note() { printf '\033[1m%s\033[0m\n' "$*"; }

# ---- default switch: install the declared leaf deps --------------------
note "Installing default-switch deps from nptel-ocaml.opam ..."
opam install . --deps-only --yes

# ---- OxCaml switch -----------------------------------------------------
if opam switch list -s 2>/dev/null | grep -qx "$OX_SWITCH"; then
  note "OxCaml switch '$OX_SWITCH' already present; nothing to create."
else
  note "Creating OxCaml switch '$OX_SWITCH' ..."
  # The +ox compiler variant lives in a custom opam repository. Add it
  # (no-op if already added) before creating the switch from it.
  if ! opam repository list --all 2>/dev/null | grep -q "$OX_REPO_NAME"; then
    note "Adding opam repository '$OX_REPO_NAME' ($OX_REPO_URL) ..."
    opam repository add "$OX_REPO_NAME" "$OX_REPO_URL" --all-switches --yes \
      || note "  (could not add $OX_REPO_NAME automatically; add it by hand: see https://oxcaml.org/ )"
  fi
  opam switch create "$OX_SWITCH" --packages=ocaml-variants.5.2.0+ox --yes \
    || {
      note "Automatic switch creation failed."
      note "Follow the OxCaml install instructions at https://oxcaml.org/ ,"
      note "then re-run this script. The repo only needs the bare switch"
      note "(dune + ocaml-mdx, which ship with it); no extra packages."
      exit 1
    }
fi

note "Done. The M11 cells validate on '$OX_SWITCH' used bare."
