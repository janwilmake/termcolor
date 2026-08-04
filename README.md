# termcolor

Give every macOS Terminal tab its own background color — automatically, keyed to the folder you're in.

Working in five checkouts of the same repo? Each one gets its own stable color, so you can tell your terminals apart at a glance. `cd` somewhere else and the tab recolors instantly.

![termcolor recoloring a Terminal tab on every cd](demo.gif)

- **Same folder → same color.** Colors come from a hash of the directory path, so they're stable across tabs, restarts, and days.
- **Git-aware.** Inside a repo the color is keyed to the repo root, so moving around subdirectories never changes it.
- **Live.** A `chpwd` hook recolors the tab on every `cd`, in the background — zero prompt latency.
- **Pinnable.** Want `project-a` always green and `project-b` always red? Pin exact colors in an overrides file.
- **Zero dependencies.** One zsh script driving Terminal.app over AppleScript. No brew, no daemons.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/janwilmake/termcolor/main/install.sh | sh
```

This copies `termcolor` to `~/.local/bin` and appends a marker-guarded hook to your `~/.zshrc` (safe to re-run; it won't duplicate). Then open a new tab.

Or manually: clone the repo, run `./install.sh`.

**Requirements:** macOS with the built-in Terminal.app and zsh (the default shell). iTerm2 is not supported — it has its own escape codes for this.

## Usage

The automatic coloring just works after install. The CLI is there when you want control:

```sh
termcolor list        # show named presets
termcolor ocean       # apply a preset to this tab
termcolor 40 10 30    # custom background, 0-255 per channel
termcolor auto        # color from the current directory (what the hook runs)
termcolor random      # random dark background
termcolor reset       # restore the tab's profile colors
```

Presets: `midnight`, `ocean`, `forest`, `wine`, `plum`, `ember`, `slate`, `black`. All colors are deliberately dark so light text stays readable; only the background changes.

## Pinning colors per project

Create `~/.config/termcolor/overrides` with one `<path> <R> <G> <B>` line per project (0–255, `~` allowed, `#` comments). The path must be what `auto` keys on: the git repo root, or the absolute directory for non-repos.

```
# my checkouts, maximally distinct
~/code/app    12 18 48
~/code/app2   48 10 30
~/code/app3   10 42 14
```

Anything not pinned falls back to the hashed color. Changes apply on the next `cd`.

## How it works

Terminal.app is scriptable: AppleScript exposes each tab's `background color` as 16-bit RGB. `termcolor` finds the tab it was called from by matching the tab's tty, so it colors the right window even with many open. `auto` mode hashes the directory (via `cksum`) onto a hue wheel and converts it to a dark RGB.

The zshrc hook runs `termcolor auto` once when an interactive shell starts and again on every directory change, disowned (`&!`) so your prompt never waits on it. It only activates inside Terminal.app — SSH sessions, VS Code, and other terminals are untouched.

To target a different tab than the one you're in: `TERMCOLOR_TTY=/dev/ttys003 termcolor wine`.

## Uninstall

```sh
rm ~/.local/bin/termcolor
```

Then delete the block between `# >>> termcolor >>>` and `# <<< termcolor <<<` in `~/.zshrc`, and optionally `rm -r ~/.config/termcolor`. Already-colored tabs reset when closed (or run `termcolor reset` first).

## License

MIT
