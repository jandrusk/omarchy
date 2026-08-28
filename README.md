# Omarchy customizations

Themes, hooks, screensavers, and related overlays for [Omarchy](https://omarchy.org/), plus a matching Emacs color theme.

This repository is a **user overlay**. It never patches `/usr/share/omarchy/`. Files install under `~/.config/omarchy/`, `~/.config/hypr/`, `~/.local/bin/`, and `~/.emacs.d/`.

## Matrix theme

CRT phosphor green on near-black (`#00ff41` on `#050a05`), with digital-rain wallpapers, a TTE matrix screensaver, a Brave theme, and an Emacs theme that shares the same palette.

```
omarchy/themes/matrix/     Omarchy desktop theme (colors, Hyprland, wallpapers, Brave)
omarchy/bin/               Screensaver wrapper (used when Matrix is the current theme)
omarchy/hooks/theme-set.d/ Enable Brave + screensaver branding on `omarchy theme set`
hypr/                      Hyprland PATH snippet so the screensaver wrapper wins
bin/omarchy-brave-matrix   Launch Brave, applying the Matrix theme on a fresh start
emacs/                     `omarchy-matrix` Emacs theme + a small loader
setup.sh                   Apply the overlay on this account
```

## Setup

On an Omarchy machine:

```bash
git clone https://github.com/jandrusk/omarchy.git
cd omarchy
./setup.sh
```

That will:

1. Copy the Matrix theme into `~/.config/omarchy/themes/matrix`
2. Install the screensaver wrapper and theme-set hooks
3. Patch `~/.config/hypr/hyprland.lua` so the Matrix screensaver can run
4. Install the Emacs theme and load it from your init file if one exists
5. Run `omarchy theme set matrix`

Existing files are backed up as `*.bak.omarchy-matrix.<timestamp>` before they are edited. Re-running the script is idempotent.

```bash
./setup.sh --dry-run              # print actions only
./setup.sh --skip-theme           # copy files, keep the current Omarchy theme
./setup.sh --skip-emacs           # desktop overlay only
./setup.sh --brave-bind           # also rebind SUPER+SHIFT+B to Matrix Brave
                                  # (stock Omarchy uses this key for Browser)
./setup.sh --help
```

Preview the screensaver after setup:

```bash
omarchy launch screensaver
```

## Screensaver

While Matrix is the current theme, idle screensaver uses `ttfx matrix` in the theme greens and resolves to a MATRIX wordmark. Other themes keep the stock Omarchy TTE loop.

Omarchy puts `/usr/share/omarchy/bin` first on `PATH`, so the wrapper in `~/.config/omarchy/bin/omarchy-screensaver` only works after the Hyprland PATH snippet `setup.sh` installs.

## Brave

`omarchy-brave-matrix-apply enable|disable` stages the theme into the Brave profile. A `theme-set` hook turns it on for Matrix and off for every other theme.

The Chrome/Brave **private key is not in this repo**. Keep `brave/key.pem` only on the machine that signed the packed `.crx`. Setup never overwrites an existing local key.

## License

Personal overlay. Palette and assets are for use with Omarchy on your own systems.
