#!/bin/sh
# termcolor installer — macOS Terminal.app only.
#
#   curl -fsSL https://raw.githubusercontent.com/janwilmake/termcolor/main/install.sh | sh
#
# Installs ~/.local/bin/termcolor and adds an auto-color hook to ~/.zshrc
# (guarded by markers, safe to re-run).

set -e

RAW="https://raw.githubusercontent.com/janwilmake/termcolor/main"
BIN_DIR="$HOME/.local/bin"
ZSHRC="$HOME/.zshrc"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "termcolor only works on macOS (it scripts Terminal.app)." >&2
  exit 1
fi

mkdir -p "$BIN_DIR"

# Prefer the local copy when run from a clone; otherwise fetch from GitHub.
if [ -f "$(dirname "$0")/termcolor" ]; then
  cp "$(dirname "$0")/termcolor" "$BIN_DIR/termcolor"
else
  curl -fsSL "$RAW/termcolor" -o "$BIN_DIR/termcolor"
fi
chmod +x "$BIN_DIR/termcolor"
echo "installed $BIN_DIR/termcolor"

if grep -q "# >>> termcolor >>>" "$ZSHRC" 2>/dev/null; then
  echo "zshrc hook already present, leaving it untouched"
else
  cat >> "$ZSHRC" <<'EOF'

# >>> termcolor >>>
# Auto-color Terminal.app tabs by directory: same folder -> same color,
# recolors on every cd. https://github.com/janwilmake/termcolor
export PATH="$HOME/.local/bin:$PATH"
if [[ "$TERM_PROGRAM" == "Apple_Terminal" && -o interactive && -n "$TTY" ]]; then
  _termcolor_auto() { "$HOME/.local/bin/termcolor" auto &>/dev/null &! }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _termcolor_auto
  _termcolor_auto
fi
# <<< termcolor <<<
EOF
  echo "added auto-color hook to $ZSHRC"
fi

echo
echo "Done. Open a new Terminal tab (or run 'source ~/.zshrc') to see it."
echo "Try:  termcolor list | termcolor ocean | termcolor reset"
