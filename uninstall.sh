#!/bin/bash
# Removes omarchy-close-confirm and gives SUPER+W / SUPER+Q back to Omarchy.
set -euo pipefail

bindings="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
begin="-- >>> omarchy-close-confirm >>>"
end="-- <<< omarchy-close-confirm <<<"

if [[ -f $bindings ]]; then
  tmp=$(mktemp)
  sed "/^$begin\$/,/^$end\$/d" "$bindings" >"$tmp"
  cat "$tmp" >"$bindings"
  rm -f "$tmp"
fi
rm -f "$HOME/.local/bin/omarchy-close-confirm"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-close-confirm"
command -v hyprctl >/dev/null && hyprctl reload >/dev/null

echo "Removed. Your settings file, if any, is left at ~/.config/omarchy-close-confirm.conf."
