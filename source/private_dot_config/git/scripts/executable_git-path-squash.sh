#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd
)"

SEQUENCE_EDITOR="$SCRIPT_DIR/git-path-squash-sequence-editor.py"

usage() {
  cat <<'EOF'
Usage:

  git path-squash <path> <upstream>

Squashes commits that change only files within <path>.

Examples:

  git path-squash app/Models HEAD~20

  git path-squash app/Models/User.php develop
EOF

  exit 1
}

case "${1:-}" in
-h | --help)
  usage
  ;;
esac

[[ $# -eq 2 ]] || usage

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

if [[ ! -x "$SEQUENCE_EDITOR" ]]; then
  echo "Sequence editor not found or not executable:" >&2
  echo "  $SEQUENCE_EDITOR" >&2
  exit 1
fi

export GPS_PATH="$1"

git \
  -c sequence.editor="$SEQUENCE_EDITOR" \
  rebase -i "$2"
