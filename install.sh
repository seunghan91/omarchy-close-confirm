#!/bin/bash
# Installs omarchy-close-confirm and binds it to SUPER+W and SUPER+Q.
# Safe to run again: it replaces its own block instead of adding a second one.
set -euo pipefail

cd "$(dirname "$0")"
bin_dir="$HOME/.local/bin"
bindings="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
begin="-- >>> omarchy-close-confirm >>>"
end="-- <<< omarchy-close-confirm <<<"

for cmd in hyprctl jq pgrep omarchy-menu-select; do
  command -v "$cmd" >/dev/null || { echo "Missing $cmd. This needs Omarchy 4 with the Lua Hyprland config." >&2; exit 1; }
done
[[ -f $bindings ]] || { echo "Not found: $bindings (Omarchy 4 Lua config expected)." >&2; exit 1; }

install -Dm755 bin/omarchy-close-confirm "$bin_dir/omarchy-close-confirm"
install -Dm644 i18n.json "${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-close-confirm/i18n.json"

backup="$bindings.bak.$(date +%Y%m%d-%H%M%S-%N)"
cp "$bindings" "$backup"

tmp=$(mktemp)
sed "/^$begin\$/,/^$end\$/d" "$bindings" >"$tmp"
cat >>"$tmp" <<LUA
$begin
-- Ask before closing a busy terminal: https://github.com/seunghan91/omarchy-close-confirm
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Close window", os.getenv("HOME") .. "/.local/bin/omarchy-close-confirm")
hl.unbind("SUPER + Q")
o.bind("SUPER + Q", "Close window", os.getenv("HOME") .. "/.local/bin/omarchy-close-confirm")
$end
LUA
cat "$tmp" >"$bindings"
rm -f "$tmp"

hyprctl reload >/dev/null
sleep 1
errors=$(hyprctl configerrors)
if [[ -n ${errors//[[:space:]]/} ]]; then
  cp "$backup" "$bindings"
  hyprctl reload >/dev/null
  echo "Hyprland reported config errors, so bindings.lua was restored:" >&2
  echo "$errors" >&2
  exit 1
fi

echo "Installed. SUPER+W and SUPER+Q now ask before closing a busy terminal."
echo "Backup of your bindings: $backup"
echo "Options: cp omarchy-close-confirm.conf.example ~/.config/omarchy-close-confirm.conf"
