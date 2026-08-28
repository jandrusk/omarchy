#!/usr/bin/env bash
# Apply the Omarchy Matrix overlay on this user account.
# Never writes under /usr/share/omarchy.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".bak.omarchy-matrix.$(date +%s)"

APPLY_THEME=1
APPLY_HYPR=1
APPLY_EMACS=1
APPLY_EMACS_INIT=1
BRAVE_BIND=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Install the Matrix Omarchy overlay into this account and apply it.

  --skip-theme       Copy files but do not run `omarchy theme set matrix`
  --skip-hypr        Do not patch Hyprland config
  --skip-emacs       Do not install the Emacs theme
  --skip-emacs-init  Install the Emacs theme files but do not edit init.el
  --brave-bind       Rebind SUPER+SHIFT+B to the Matrix Brave launcher
                     (stock Omarchy uses this key for Browser)
  --dry-run          Print actions without writing files
  -h, --help         Show this help

Safe locations only: ~/.config/omarchy, ~/.config/hypr, ~/.local/bin, ~/.emacs.d
EOF
}

while (($# > 0)); do
  case "$1" in
  --skip-theme) APPLY_THEME=0 ;;
  --skip-hypr) APPLY_HYPR=0 ;;
  --skip-emacs) APPLY_EMACS=0 ;;
  --skip-emacs-init) APPLY_EMACS_INIT=0 ;;
  --brave-bind) BRAVE_BIND=1 ;;
  --dry-run) DRY_RUN=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

log() { printf '%s\n' "$*"; }
run() {
  if ((DRY_RUN)); then
    printf 'dry-run: %s\n' "$*"
    return 0
  fi
  "$@"
}

backup_file() {
  local path="$1"
  [[ -f $path ]] || return 0
  run cp -a "$path" "${path}${BACKUP_SUFFIX}"
  log "  backup ${path}${BACKUP_SUFFIX}"
}

copy_file() {
  local src="$1" dest="$2" mode="${3:-}"
  [[ -f $src ]] || {
    echo "Missing source file: $src" >&2
    exit 1
  }
  if ((DRY_RUN)); then
    log "dry-run: install $src -> $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  [[ -z $mode ]] || chmod "$mode" "$dest"
  log "  $dest"
}

file_has() {
  local path="$1" needle="$2"
  [[ -f $path ]] && grep -Fq "$needle" "$path"
}

append_marked_block() {
  local dest="$1" marker="$2" src="$3"
  if file_has "$dest" "$marker"; then
    log "  already present: $marker"
    return 0
  fi
  backup_file "$dest"
  if ((DRY_RUN)); then
    log "dry-run: append $src -> $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  [[ -f $dest ]] || touch "$dest"
  printf '\n' >>"$dest"
  cat "$src" >>"$dest"
  if [[ $(tail -c1 "$dest" | wc -l) -eq 0 ]]; then
    printf '\n' >>"$dest"
  fi
  log "  appended $src -> $dest"
}

emacs_init_path() {
  if [[ -f $HOME/.emacs.d/init.hermes.el ]]; then
    printf '%s\n' "$HOME/.emacs.d/init.hermes.el"
  elif [[ -f $HOME/.emacs.d/init.el ]]; then
    printf '%s\n' "$HOME/.emacs.d/init.el"
  elif [[ -f $HOME/.config/emacs/init.el ]]; then
    printf '%s\n' "$HOME/.config/emacs/init.el"
  elif [[ -f $HOME/.emacs ]]; then
    printf '%s\n' "$HOME/.emacs"
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

log "Omarchy Matrix setup"
log "  repo: $ROOT"
log "  home: $HOME"
((DRY_RUN)) && log "  mode: dry-run"

if [[ $EUID -eq 0 ]]; then
  echo "Refusing to run as root. Apply this overlay as the desktop user." >&2
  exit 1
fi

if [[ ! -d $ROOT/omarchy/themes/matrix ]]; then
  echo "This script must be run from the Matrix/ directory of github.com/jandrusk/omarchy" >&2
  exit 1
fi

if ! need_cmd rsync; then
  echo "rsync is required" >&2
  exit 1
fi

if ! need_cmd omarchy; then
  echo "warning: 'omarchy' is not on PATH. File copy will still run; theme apply will be skipped." >&2
  APPLY_THEME=0
fi

# --- theme files (keep a local Brave signing key if the user already has one) ---
log "Installing Matrix theme files"
if ((DRY_RUN)); then
  log "dry-run: rsync omarchy/themes/matrix -> $HOME/.config/omarchy/themes/matrix"
else
  mkdir -p "$HOME/.config/omarchy/themes/matrix"
  rsync -a --exclude 'key.pem' --exclude '*~' \
    "$ROOT/omarchy/themes/matrix/" \
    "$HOME/.config/omarchy/themes/matrix/"
  chmod 755 "$HOME/.config/omarchy/themes/matrix/screensaver"
  log "  $HOME/.config/omarchy/themes/matrix/"
fi

copy_file "$ROOT/omarchy/bin/omarchy-screensaver" \
  "$HOME/.config/omarchy/bin/omarchy-screensaver" 755

copy_file "$ROOT/bin/omarchy-brave-matrix" \
  "$HOME/.local/bin/omarchy-brave-matrix" 755

# --- hooks ---
log "Installing theme-set hooks"
if need_cmd omarchy && ((DRY_RUN == 0)); then
  omarchy hook install theme-set "$ROOT/omarchy/hooks/theme-set.d/omarchy-brave-matrix-theme.hook"
  omarchy hook install theme-set "$ROOT/omarchy/hooks/theme-set.d/theme-set-screensaver.hook"
else
  copy_file "$ROOT/omarchy/hooks/theme-set.d/omarchy-brave-matrix-theme.hook" \
    "$HOME/.config/omarchy/hooks/theme-set.d/omarchy-brave-matrix-theme.hook" 755
  copy_file "$ROOT/omarchy/hooks/theme-set.d/theme-set-screensaver.hook" \
    "$HOME/.config/omarchy/hooks/theme-set.d/theme-set-screensaver.hook" 755
fi

# --- Hyprland ---
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"

if ((APPLY_HYPR)); then
  if [[ ! -f $HYPR_LUA ]]; then
    echo "warning: $HYPR_LUA not found; skipping Hyprland PATH patch" >&2
  else
    log "Patching Hyprland PATH for the Matrix screensaver"
    if file_has "$HYPR_LUA" "begin omarchy-matrix screensaver PATH" ||
      file_has "$HYPR_LUA" '/.config/omarchy/bin'; then
      log "  already present in $HYPR_LUA"
    else
      append_marked_block "$HYPR_LUA" "begin omarchy-matrix screensaver PATH" \
        "$ROOT/hypr/matrix-screensaver-path.lua"
    fi
  fi

  if ((BRAVE_BIND)); then
    if [[ ! -f $BINDINGS_LUA ]]; then
      echo "warning: $BINDINGS_LUA not found; skipping Brave keybind" >&2
    else
      log "Binding SUPER+SHIFT+B to Matrix Brave (was Browser in stock Omarchy)"
      if file_has "$BINDINGS_LUA" "begin omarchy-matrix brave binding" ||
        file_has "$BINDINGS_LUA" "omarchy-brave-matrix"; then
        log "  already present in $BINDINGS_LUA"
      else
        append_marked_block "$BINDINGS_LUA" "begin omarchy-matrix brave binding" \
          "$ROOT/hypr/bindings-matrix.lua"
      fi
    fi
  fi

  if ((DRY_RUN)); then
    log "dry-run: hyprctl reload && hyprctl configerrors"
  elif [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && need_cmd hyprctl; then
    log "Reloading Hyprland"
    hyprctl reload >/dev/null
    errors="$(hyprctl configerrors 2>/dev/null || true)"
    if [[ -n ${errors//[[:space:]]/} && $errors != ok ]]; then
      echo "warning: hyprctl configerrors reported:" >&2
      printf '%s\n' "$errors" >&2
    else
      log "  hyprctl configerrors: clean"
    fi
  else
    log "  Hyprland is not the current session; PATH takes effect on next login or hyprctl reload"
  fi
fi

# --- Emacs ---
if ((APPLY_EMACS)); then
  log "Installing Emacs Matrix theme"
  copy_file "$ROOT/emacs/omarchy-matrix-theme.el" \
    "$HOME/.emacs.d/themes/omarchy-matrix-theme.el"
  copy_file "$ROOT/emacs/omarchy-matrix-setup.el" \
    "$HOME/.emacs.d/omarchy-matrix-setup.el"

  if ((APPLY_EMACS_INIT)); then
    init="$(emacs_init_path || true)"
    if [[ -z ${init:-} ]]; then
      log "  no Emacs init file found; load ~/.emacs.d/omarchy-matrix-setup.el yourself"
    elif file_has "$init" "omarchy-matrix"; then
      log "  $init already references omarchy-matrix"
    else
      log "  wiring $init"
      backup_file "$init"
      if ((DRY_RUN == 0)); then
        cat >>"$init" <<'ELISP'

;;; begin omarchy-matrix
(load (expand-file-name "omarchy-matrix-setup.el" user-emacs-directory) nil t)
;;; end omarchy-matrix
ELISP
      fi
    fi
  fi
fi

# --- apply theme ---
if ((APPLY_THEME)); then
  log "Applying Omarchy theme: matrix"
  if ((DRY_RUN)); then
    log "dry-run: omarchy theme set matrix"
  else
    omarchy theme set matrix
  fi
fi

log
log "Done."
log "  Theme files:     ~/.config/omarchy/themes/matrix"
log "  Screensaver:     omarchy launch screensaver"
if ((BRAVE_BIND)); then
  log "  Brave launcher:  SUPER+SHIFT+B  (replaced stock Browser)"
else
  log "  Brave launcher:  ~/.local/bin/omarchy-brave-matrix"
  log "                   (pass --brave-bind to take SUPER+SHIFT+B)"
fi
log "  Emacs:           restart Emacs, or M-x load-theme RET omarchy-matrix"
