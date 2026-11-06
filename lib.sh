# Shared by install.sh and uninstall.sh: edit bindings.lua without ever
# leaving it half-written, and only when our markers are intact.

bindings="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
begin="-- >>> omarchy-close-confirm >>>"
end="-- <<< omarchy-close-confirm <<<"

die() { echo "$*" >&2; exit 1; }

# Either no markers, or exactly one begin line followed by one end line.
# Anything else means someone edited the block by hand: stop, touch nothing.
check_markers() {
  local file=$1 b e
  b=$(grep -nxF -- "$begin" "$file" | cut -d: -f1 | tr '\n' ' ' || true)
  e=$(grep -nxF -- "$end" "$file" | cut -d: -f1 | tr '\n' ' ' || true)
  [[ -z $b && -z $e ]] && return 0
  if [[ $b =~ ^[0-9]+\ $ && $e =~ ^[0-9]+\ $ ]] && (( ${b% } < ${e% } )); then
    return 0
  fi
  die "The omarchy-close-confirm markers in $file are incomplete or duplicated.
Fix or remove the block between \"$begin\" and \"$end\" by hand, then run this again."
}

# Writes the file minus our block (plus $2, if given) to a temp file next to
# the real file, then swaps it in with one rename.
rewrite_bindings() {
  local target=$1 block=${2:-} tmp
  tmp=$(mktemp "$(dirname "$target")/.bindings.lua.XXXXXX")
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" EXIT
  awk -v b="$begin" -v e="$end" '$0 == b { skip = 1; next } $0 == e { skip = 0; next } !skip' "$target" >"$tmp"
  if [[ -n $block ]]; then
    # Keep the block on its own lines even if the file lacks a final newline.
    [[ -s $tmp && -n $(tail -c 1 "$tmp") ]] && echo >>"$tmp"
    printf '%s\n' "$block" >>"$tmp"
  fi
  chmod --reference="$target" "$tmp"
  mv -f "$tmp" "$target"
  trap - EXIT
}

reload_or_restore() {
  local target=$1 backup=$2 errors
  if hyprctl reload >/dev/null && sleep 1 && errors=$(hyprctl configerrors); then
    [[ -z ${errors//[[:space:]]/} ]] && return 0
  else
    errors="hyprctl did not respond"
  fi
  cp -p "$backup" "$target"
  hyprctl reload >/dev/null 2>&1 || true
  die "Hyprland reported a problem, so bindings.lua was restored from $backup:
$errors"
}
