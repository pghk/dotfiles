#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd
)"

SEQUENCE_EDITOR="$SCRIPT_DIR/git-smart-squash-sequence-editor.py"

usage() {
  cat <<'EOF'
Usage:

  git smart-squash <upstream>

Squashes commits that change exactly the same set of files.

Example:

  git smart-squash HEAD~20
EOF

  exit 1
}

[[ $# -eq 1 ]] || usage

case "$1" in
-h | --help)
  usage
  ;;
esac

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

if [[ ! -x "$SEQUENCE_EDITOR" ]]; then
  echo "Sequence editor not found or not executable:" >&2
  echo "  $SEQUENCE_EDITOR" >&2
  exit 1
fi

git \
  -c sequence.editor="$SEQUENCE_EDITOR" \
  rebase -i "$1"
