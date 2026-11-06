# Close Confirm for Omarchy

`SUPER + W` closes a window instantly. That's great for a browser tab, and
painful when the window was a terminal running a coding agent, an editor with
unsaved work, an `ssh` session or a long build.

Close Confirm makes `SUPER + W` and `SUPER + Q` ask first, but only when it
matters:

| Window | What happens |
|---|---|
| Terminal running something (`claude`, `nvim`, `ssh`, `make`...) | Asks: *"claude is still running. Close?"* |
| Terminal sitting at an idle shell prompt | Closes right away |
| Any other window | Closes right away, same as stock Omarchy |

"Running something" means the shell is not the terminal's foreground process
group, the same signal a shell uses for job control. Background jobs (`cmd &`)
don't count. The confirmation is Omarchy's own menu (`omarchy-menu-select`),
so it follows your theme and works with the keyboard, with **Cancel** listed
first.

## Requirements

- Omarchy 4 with the Lua Hyprland config (`~/.config/hypr/bindings.lua`).
  Tested on Omarchy 4.5.0 / Hyprland 0.56.2.
- `jq` and `pgrep`, which Omarchy already ships.

## Install

```bash
git clone https://github.com/seunghan91/omarchy-close-confirm.git
cd omarchy-close-confirm
./install.sh
```

The installer copies `omarchy-close-confirm` to `~/.local/bin`, backs up
`bindings.lua`, and appends one marked block that rebinds `SUPER + W` and
`SUPER + Q`. Running it again replaces that block instead of adding another.
If Hyprland reports a config error after the change, the backup is restored.

Uninstall with `./uninstall.sh`; the keys go back to Omarchy's defaults.

## Languages

The dialog speaks every language Omarchy ships (50, from Arabic to Chinese).
It follows your Omarchy language (**Setup > Language**, the same setting the
rest of Omarchy uses), then your `$LANG`, then English.

| Language | Busy terminal prompt |
|---|---|
| English | *claude is still running. Close?* |
| Deutsch | *claude läuft noch. Schließen?* |
| 日本語 | *claude はまだ実行中です。閉じますか？* |
| 한국어 | *claude 실행 중입니다. 닫을까요?* |

Translations live in [`i18n.json`](i18n.json). They were machine-assisted, so
corrections from native speakers are very welcome: edit the four strings for
your language and open a PR. `%1` is the running program's name.

## Options

Copy `omarchy-close-confirm.conf.example` to
`~/.config/omarchy-close-confirm.conf`:

```bash
TERMINALS="foot Alacritty"   # window classes treated as terminals
ASK="busy"                   # or "always" to ask for every terminal
LANGUAGE_CODE="ko"           # pin a language from i18n.json
PROMPT_RUNNING="%1 is busy!" # or write any string yourself
```

Changes apply on the next keypress.

Ghostty and Kitty already have their own setting for this
(`confirm-close-surface`, `confirm_os_window_close`), so they aren't listed by
default. Add their class to `TERMINALS` if you prefer this menu.

## Limits

- Only the two key bindings are covered. The `×` button on Omarchy's tabbed /
  titlebar layouts and `CTRL + ALT + DELETE` (close all) still close
  immediately.
- A terminal server that owns several windows (e.g. `footclient` with
  `foot --server`) can't be mapped to one shell, so those windows always ask.

## Related

- [omacom/omarchy#17236](https://github.com/omacom/omarchy/pull/17236) proposes
  a built-in Foot confirmation, and
  [#17259](https://github.com/omacom/omarchy/pull/17259) turns on Ghostty and
  Kitty's native one. If those land, you may not need this.
- [flaviozantut/omarchy-close-confirm](https://github.com/flaviozantut/omarchy-close-confirm)
  is a shell plugin that asks before closing *any* window.

## License

MIT
