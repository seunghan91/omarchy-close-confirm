#!/bin/bash
# Installs omarchy-close-confirm and binds it to SUPER+W and SUPER+Q.
# Safe to run again: it replaces its own block instead of adding a second one.
set -euo pipefail

cd "$(dirname "$0")"
source ./lib.sh

for cmd in hyprctl jq pgrep omarchy-menu-select; do
  command -v "$cmd" >/dev/null || die "Missing $cmd. This needs Omarchy 4 with the Lua Hyprland config."
done
[[ -f $bindings ]] || die "Not found: $bindings (Omarchy 4 Lua config expected)."
target=$(readlink -f "$bindings")
check_markers "$target"

install -Dm755 bin/omarchy-close-confirm "$HOME/.local/bin/omarchy-close-confirm"
install -Dm644 i18n.json "${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-close-confirm/i18n.json"

backup="$target.bak.$(date +%Y%m%d-%H%M%S-%N)"
cp -p "$target" "$backup"

block="$begin
-- Ask before closing a busy terminal: https://github.com/seunghan91/omarchy-close-confirm
local close_confirm = o.shell_quote(os.getenv(\"HOME\") .. \"/.local/bin/omarchy-close-confirm\")
hl.unbind(\"SUPER + W\")
o.bind(\"SUPER + W\", \"Close window\", close_confirm)
hl.unbind(\"SUPER + Q\")
o.bind(\"SUPER + Q\", \"Close window\", close_confirm)
$end"

rewrite_bindings "$target" "$block"
reload_or_restore "$target" "$backup"

echo "Installed. SUPER+W and SUPER+Q now ask before closing a busy terminal."
echo "Backup of your bindings: $backup"
echo "Options: cp omarchy-close-confirm.conf.example ~/.config/omarchy-close-confirm.conf"
