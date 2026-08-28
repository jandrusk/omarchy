#!/usr/bin/env bash
# Install the Matrix overlay into the current user's Omarchy / Emacs config.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "  $dest"
}

echo "Installing Omarchy Matrix overlay into \$HOME..."

mkdir -p "$HOME/.config/omarchy/themes" \
  "$HOME/.config/omarchy/bin" \
  "$HOME/.config/omarchy/hooks/theme-set.d" \
  "$HOME/.local/bin" \
  "$HOME/.emacs.d/themes"

rsync -a --delete --exclude 'key.pem' \
  "$ROOT/omarchy/themes/matrix/" \
  "$HOME/.config/omarchy/themes/matrix/"
echo "  $HOME/.config/omarchy/themes/matrix/"

copy_file "$ROOT/omarchy/bin/omarchy-screensaver" \
  "$HOME/.config/omarchy/bin/omarchy-screensaver"
chmod 755 "$HOME/.config/omarchy/bin/omarchy-screensaver"
chmod 755 "$HOME/.config/omarchy/themes/matrix/screensaver"

copy_file "$ROOT/omarchy/hooks/theme-set.d/omarchy-brave-matrix-theme.hook" \
  "$HOME/.config/omarchy/hooks/theme-set.d/omarchy-brave-matrix-theme.hook"
copy_file "$ROOT/omarchy/hooks/theme-set.d/theme-set-screensaver.hook" \
  "$HOME/.config/omarchy/hooks/theme-set.d/theme-set-screensaver.hook"
chmod 755 "$HOME/.config/omarchy/hooks/theme-set.d/"*.hook

copy_file "$ROOT/bin/omarchy-brave-matrix" "$HOME/.local/bin/omarchy-brave-matrix"
chmod 755 "$HOME/.local/bin/omarchy-brave-matrix"

copy_file "$ROOT/emacs/omarchy-matrix-theme.el" \
  "$HOME/.emacs.d/themes/omarchy-matrix-theme.el"

cat <<'EOF'

Installed. Next steps:

  1. Append hypr/matrix-screensaver-path.lua to ~/.config/hypr/hyprland.lua
     so Omarchy launches the Matrix digital-rain screensaver.
  2. Apply the theme:  omarchy theme set matrix
  3. Preview the screensaver:  omarchy launch screensaver
  4. In Emacs, load emacs/omarchy-matrix-setup.el or add its forms to your init.

The Brave extension private key is not shipped. Existing installs keep
~/.config/omarchy/themes/matrix/brave/key.pem locally if you already have one.
EOF
