#!/bin/bash
# Removes omarchy-close-confirm and gives SUPER+W / SUPER+Q back to Omarchy.
set -euo pipefail

cd "$(dirname "$0")"
source ./lib.sh

if [[ -f $bindings ]]; then
  target=$(readlink -f "$bindings")
  check_markers "$target"
  if grep -qxF -- "$begin" "$target"; then
    backup="$target.bak.$(date +%Y%m%d-%H%M%S-%N)"
    cp -p "$target" "$backup"
    rewrite_bindings "$target"
    command -v hyprctl >/dev/null && reload_or_restore "$target" "$backup"
    echo "Backup of your bindings: $backup"
  fi
fi
rm -f "$HOME/.local/bin/omarchy-close-confirm"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-close-confirm"

echo "Removed. Your settings file, if any, is left at ~/.config/omarchy-close-confirm.conf."
