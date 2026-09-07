#!/bin/bash
# Install or remove the Night City screensaver when the theme changes.
# Installed with: omarchy hook install theme-set hooks/theme-set-screensaver.sh

set -euo pipefail

THEME_NAME=${1:-}
CURRENT="$HOME/.local/state/omarchy/current/theme"
BRANDING="$HOME/.config/omarchy/branding/screensaver.txt"
STAMP="$HOME/.local/state/omarchy/screensaver-from-theme"
BASHRC="$HOME/.bashrc"
MARKER_START="# >>> omarchy-theme-screensaver >>>"
MARKER_END="# <<< omarchy-theme-screensaver <<<"

SNIPPET=$(cat <<'EOF'
# >>> omarchy-theme-screensaver >>>
# If the current theme ships screensaver/launch, use it instead of the ASCII ttfx saver.
if [[ -x "$HOME/.local/state/omarchy/current/theme/screensaver/launch" ]]; then
  omarchy-launch-screensaver() {
    exec "$HOME/.local/state/omarchy/current/theme/screensaver/launch" "$@"
  }
fi
# <<< omarchy-theme-screensaver <<<
EOF
)

ensure_bashrc_snippet() {
  [[ -f $BASHRC ]] || return 0
  grep -qF "$MARKER_START" "$BASHRC" && return 0

  python3 - "$BASHRC" "$SNIPPET" <<'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
snippet = sys.argv[2]
text = path.read_text()
needle = "[[ $- != *i* ]] && return"
block = snippet.rstrip() + "\n\n"
if needle in text:
    text = text.replace(needle, block + needle, 1)
else:
    text = block + text
path.write_text(text)
PY
}

ensure_bashrc_snippet

mkdir -p "$(dirname "$STAMP")" "$HOME/.config/omarchy/branding"

if [[ -x $CURRENT/screensaver/launch ]]; then
  if [[ -f $CURRENT/screensaver.txt ]]; then
    cp "$CURRENT/screensaver.txt" "$BRANDING"
  fi
  printf '%s\n' "$THEME_NAME" >"$STAMP"
elif [[ -f $STAMP && -f ${OMARCHY_PATH:-/usr/share/omarchy}/logo.txt ]]; then
  cp "${OMARCHY_PATH:-/usr/share/omarchy}/logo.txt" "$BRANDING"
  rm -f "$STAMP"
fi
