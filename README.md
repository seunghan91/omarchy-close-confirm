# Close Confirm for Omarchy

`SUPER + W` closes a window instantly. That's great for a browser window, and
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
group, the same signal a shell uses for job control, or that the terminal was
started straight into a program (`foot nvim`). Background jobs (`cmd &`)
don't count. When in doubt it asks: a missed question costs a keypress, a
missed close costs your work. The confirmation is Omarchy's own menu (`omarchy-menu-select`),
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

The installer copies `omarchy-close-confirm` to `~/.local/bin` and its
translations to `~/.local/share/omarchy-close-confirm/`, backs up
`bindings.lua`, and appends one marked block that rebinds `SUPER + W` and
`SUPER + Q`. Running it again replaces that block instead of adding another.
The file is swapped in atomically (symlinked configs are followed), and if
Hyprland reports a config error the backup is restored. If the markers were
edited by hand, it stops without touching anything.

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
| 한국어 | *claude 프로그램이 아직 실행 중입니다. 닫을까요?* |

Translations live in [`i18n.json`](i18n.json). They were machine-assisted, so
corrections from native speakers are very welcome: edit the four strings for
your language and open a PR. `%1` is the running program's name.

## Options

Copy `omarchy-close-confirm.conf.example` to
`~/.config/omarchy-close-confirm.conf`:

```bash
TERMINALS="foot footclient Alacritty"  # window classes treated as terminals
ASK="busy"            # or "always" to ask for every terminal
WIDTH=520             # dialog width in pixels
LANGUAGE_CODE="ko"    # pin a language from i18n.json (ko, pt-BR, zh-TW...)
# Your own text instead of the translation; %1 = program name
PROMPT="Close this terminal?"
PROMPT_RUNNING="%1 is busy!"
CANCEL="Cancel"
CLOSE="Close"
```

Changes apply on the next keypress. A mistake in this file never stops
`SUPER + W` from working; the defaults are used instead.

Ghostty and Kitty already have their own setting for this
(`confirm-close-surface`, `confirm_os_window_close`), so they aren't listed by
default. Add their class to `TERMINALS` if you prefer this menu.

## Limits

- Only the two key bindings are covered. The `×` button on Omarchy's tabbed /
  titlebar layouts and `CTRL + ALT + DELETE` (close all) still close
  immediately.
- One process with several windows (Alacritty's `create-window`, `footclient`
  with `foot --server`) can't be mapped to one shell. Those windows close
  right away only when every shell in that process is idle, and otherwise
  ask without naming the program.
- It looks one level deep. An idle nested shell (`bash` inside `bash`,
  `sudo -i`, `nix-shell`) or an attached `tmux` client counts as running, so
  those ask too.
- There is a short gap between the check and the close. A command started in
  that instant can still be closed without asking.

## Related

- [omacom/omarchy#17236](https://github.com/omacom/omarchy/pull/17236) proposes
  a built-in Foot confirmation, and
  [#17259](https://github.com/omacom/omarchy/pull/17259) turns on Ghostty and
  Kitty's native one. If those land, you may not need this.
- [flaviozantut/omarchy-close-confirm](https://github.com/flaviozantut/omarchy-close-confirm)
  is a shell plugin that asks before closing *any* window.

## License

MIT
