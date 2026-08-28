# Omarchy customizations

Themes, hooks, screensavers, and related overlays for [Omarchy](https://omarchy.org/), plus a matching Emacs color theme.

This repository is a **user overlay**. It never patches `/usr/share/omarchy/`. Files install under `~/.config/omarchy/`, `~/.config/hypr/`, `~/.local/bin/`, and `~/.emacs.d/themes/`.

## Matrix theme

CRT phosphor green on near-black (`#00ff41` on `#050a05`), with digital-rain wallpapers, a TTE matrix screensaver, a Brave theme, and an Emacs theme that shares the same palette.

```
omarchy/themes/matrix/     Omarchy desktop theme (colors, Hyprland, wallpapers, Brave)
omarchy/bin/               Screensaver wrapper (used when Matrix is the current theme)
omarchy/hooks/theme-set.d/ Enable Brave + screensaver branding on `omarchy theme set`
hypr/                      Hyprland PATH snippet so the screensaver wrapper wins
bin/omarchy-brave-matrix   Launch Brave, applying the Matrix theme on a fresh start
emacs/                     `omarchy-matrix` Emacs theme + a small loader
```

## Install

```bash
git clone git@github.com:jandrusk/omarchy.git
cd omarchy
./install.sh
```

Then:

1. Append `hypr/matrix-screensaver-path.lua` to `~/.config/hypr/hyprland.lua` (after Omarchy defaults load).
2. `omarchy theme set matrix`
3. `omarchy launch screensaver` to preview the rain.

Emacs: copy `emacs/omarchy-matrix-theme.el` to `~/.emacs.d/themes/` (the installer does this) and load `emacs/omarchy-matrix-setup.el` from your init, or add:

```elisp
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'omarchy-matrix t)
```

Optional Hyprland binding to open Brave with the Matrix chrome: see `hypr/bindings-matrix.lua`.

## Screensaver

While Matrix is the current theme, idle screensaver uses `ttfx matrix` in the theme greens and resolves to a MATRIX wordmark. Other themes keep the stock Omarchy TTE loop.

Omarchy puts `/usr/share/omarchy/bin` first on `PATH`, so the wrapper in `~/.config/omarchy/bin/omarchy-screensaver` only works after the Hyprland PATH snippet above.

## Brave

`omarchy-brave-matrix-apply enable|disable` stages the theme into the Brave profile. A `theme-set` hook turns it on for Matrix and off for every other theme.

The Chrome/Brave **private key is not in this repo**. Keep `brave/key.pem` only on the machine that signed the packed `.crx`.

## License

Personal overlay. Palette and assets are for use with Omarchy on your own systems.
