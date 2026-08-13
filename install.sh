#!/bin/sh
# termcolor installer — macOS Terminal.app only.
#
#   curl -fsSL https://raw.githubusercontent.com/janwilmake/termcolor/main/install.sh | sh
#
# Installs ~/.local/bin/termcolor, adds an auto-color hook to ~/.zshrc
# (guarded by markers, safe to re-run), and loads a launch agent that
# repaints your tabs when macOS switches between light and dark mode.

set -e

RAW="https://raw.githubusercontent.com/janwilmake/termcolor/main"
BIN_DIR="$HOME/.local/bin"
ZSHRC="$HOME/.zshrc"
LABEL="io.github.janwilmake.termcolor"
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST="$AGENT_DIR/$LABEL.plist"

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

# Launch agent: waits for the system appearance notification, then repaints.
mkdir -p "$AGENT_DIR"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN_DIR/termcolor</string>
    <string>watch</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ProcessType</key>
  <string>Background</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null \
  || launchctl load -w "$PLIST" 2>/dev/null \
  || echo "could not load the launch agent; light/dark switching will lag" >&2
echo "loaded launch agent $LABEL"

echo
echo "Done. Open a new Terminal tab (or run 'source ~/.zshrc') to see it."
echo "Try:  termcolor list | termcolor ocean | termcolor reset"
