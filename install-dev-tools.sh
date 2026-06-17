#!/usr/bin/env bash
set -euo pipefail

GREEN=$'\033[1;32m'; BLUE=$'\033[1;34m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

info() { printf "${BLUE}==>${NC} %b\n" "$*"; }
ok()   { printf "${GREEN}✔ %b${NC}\n" "$*"; }
warn() { printf "${YELLOW}!  %b${NC}\n" "$*"; }
die()  { printf "${RED}✘ %b${NC}\n" "$*" >&2; exit 1; }

MODE="install"
ASSUME_YES="false"
DRY_RUN="false"

CASKS=(visual-studio-code gcloud-cli)
CASK_APP_PATHS=("/Applications/Visual Studio Code.app" "")
FORMULAS=(opencode googleworkspace-cli node pnpm rtk ripgrep fd jq yq tree bat gh shellcheck shfmt)
DEAD_SYMLINKS=(/opt/homebrew/bin/code /opt/homebrew/bin/code-tunnel)
VSCODE_EXTENSIONS=(sst-dev.opencode)

for arg in "$@"; do
  case "$arg" in
    uninstall|--uninstall|remove)
      MODE="uninstall"
      ;;
    -y|--yes)
      ASSUME_YES="true"
      ;;
    --dry-run)
      DRY_RUN="true"
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 [uninstall|--uninstall|remove] [-y|--yes] [--dry-run]

Without arguments, installs development tools.
Use uninstall, --uninstall, or remove to uninstall development tools.
Use -y or --yes to skip uninstall confirmation.
Use --dry-run to preview actions without changing your system.
EOF
      exit 0
      ;;
    *)
      die "Unknown argument: $arg"
      ;;
  esac
done

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    info "Would run: $*"
  else
    "$@"
  fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script only supports macOS (detected: $(uname -s))."
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$MODE" == "uninstall" ]]; then
    warn "Homebrew not found. Nothing to uninstall."
    exit 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    info "Would install Homebrew."
    exit 0
  fi

  info "Homebrew not found - installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "Homebrew already installed."
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

command -v brew >/dev/null 2>&1 || die "Homebrew is installed but not on PATH. Open a new terminal window and re-run this script."

remove_dead_symlink() {
  local path="$1"
  if [[ -L "$path" && ! -e "$path" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would remove dead symlink $path."
    else
      info "Removing dead symlink $path..."
      rm "$path"
      ok "Removed $path."
    fi
  fi
}

install_cask() {
  local name="$1"
  local app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then
    ok "$name (cask) already installed."
  elif [[ -n "$app_path" && -e "$app_path" ]]; then
    ok "$name already exists at $app_path."
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would install $name (cask)."
    else
      info "Installing $name (cask)..."
      brew install --cask "$name"
      ok "$name installed."
    fi
  fi
}

install_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    ok "$name already installed."
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would install $name."
    else
      info "Installing $name..."
      brew install "$name"
      ok "$name installed."
    fi
  fi
}

uninstall_cask() {
  local name="$1"
  local app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would uninstall $name (cask)."
    else
      info "Uninstalling $name (cask)..."
      brew uninstall --cask "$name"
      ok "$name uninstalled."
    fi
  elif [[ -n "$app_path" && -e "$app_path" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would remove $app_path."
    else
      info "Removing $app_path..."
      rm -rf "$app_path"
      ok "$name app removed."
    fi
  else
    ok "$name (cask) is not installed."
  fi
}

uninstall_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would uninstall $name."
    else
      info "Uninstalling $name..."
      brew uninstall "$name"
      ok "$name uninstalled."
    fi
  else
    ok "$name is not installed."
  fi
}

confirm_uninstall() {
  if [[ "$ASSUME_YES" == "true" || "$DRY_RUN" == "true" ]]; then
    return 0
  fi

  printf "%b" "${YELLOW}!  This will uninstall VS Code, opencode, gcloud-cli, and googleworkspace-cli. Type 'yes' to continue: ${NC}"
  read -r answer
  [[ "$answer" == "yes" ]] || die "Uninstall cancelled."
}

find_code_bin() {
  if command -v code >/dev/null 2>&1; then
    command -v code
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    printf '%s\n' "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  else
    return 1
  fi
}

install_vscode_extension() {
  local extension="$1"
  local code_bin=""

  if ! code_bin="$(find_code_bin)"; then
    warn "VS Code command not found. Install extension manually: $extension"
    return 0
  fi

  if "$code_bin" --list-extensions 2>/dev/null | grep -Fx "$extension" >/dev/null; then
    ok "$extension extension already installed."
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      info "Would install VS Code extension $extension."
    else
      info "Installing VS Code extension $extension..."
      "$code_bin" --install-extension "$extension"
    fi
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    ok "$extension extension install check previewed."
  elif "$code_bin" --list-extensions 2>/dev/null | grep -Fx "$extension" >/dev/null; then
    ok "$extension extension verified."
  else
    warn "$extension extension install could not be verified."
  fi
}

install_all_casks() {
  local i
  for ((i = 0; i < ${#CASKS[@]}; i++)); do
    install_cask "${CASKS[$i]}" "${CASK_APP_PATHS[$i]}"
  done
}

install_all_formulas() {
  local formula
  for formula in "${FORMULAS[@]}"; do
    install_formula "$formula"
  done
}

uninstall_all_casks() {
  local i
  for ((i = 0; i < ${#CASKS[@]}; i++)); do
    uninstall_cask "${CASKS[$i]}" "${CASK_APP_PATHS[$i]}"
  done
}

uninstall_all_formulas() {
  local formula
  for formula in "${FORMULAS[@]}"; do
    uninstall_formula "$formula"
  done
}

remove_all_dead_symlinks() {
  local path
  for path in "${DEAD_SYMLINKS[@]}"; do
    remove_dead_symlink "$path"
  done
}

install_all_vscode_extensions() {
  local extension
  for extension in "${VSCODE_EXTENSIONS[@]}"; do
    install_vscode_extension "$extension"
  done
}

verify_rtk_token_killer() {
  local out
  if ! command -v rtk >/dev/null 2>&1; then
    warn "rtk is not on PATH yet. Open a new terminal and run: rtk gain"
    return 0
  fi

  if out="$(rtk gain 2>&1)"; then
    ok "rtk gain: $(printf '%s' "$out" | head -n1)"
  else
    warn "rtk gain failed. Verify this is rtk-ai/rtk, not another rtk package."
  fi
}

print_version() {
  local label="$1"; shift
  local out
  if out="$("$@" 2>&1)"; then
    ok "$label: $(printf '%s' "$out" | head -n1)"
  else
    warn "$label: installed, but '$1' is not on this shell's PATH yet."
  fi
}

if [[ "$MODE" == "uninstall" ]]; then
  confirm_uninstall

  info "Uninstalling development tools..."
  uninstall_all_casks
  uninstall_all_formulas

  if [[ "$DRY_RUN" == "true" ]]; then
    cat <<EOF

${BOLD}Dry-run complete.${NC}

No changes were made. Homebrew would be kept installed.
EOF
  else
    cat <<EOF

${BOLD}Uninstall complete.${NC}

Homebrew was kept installed.
EOF
  fi
  exit 0
fi

info "Installing development tools..."

remove_all_dead_symlinks
install_all_casks
install_all_vscode_extensions
install_all_formulas

info "Verifying installations..."
print_version "VS Code"                 code     --version
print_version "opencode"                opencode --version
print_version "gcloud"                  gcloud   --version
print_version "gws (Google Workspace)"  gws      --version
print_version "node"                    node     --version
print_version "pnpm"                    pnpm     --version
print_version "rtk"                     rtk      --version
verify_rtk_token_killer

cat <<EOF

${BOLD}All done.${NC}

Next steps (run these yourself whenever you're ready):
  gcloud init        # sign in and configure the Google Cloud CLI
  gws auth setup     # one-time Google Workspace auth (requires gcloud)

Tip: if any command above was reported as not on PATH, open a ${BOLD}new terminal window${NC}
so your PATH refreshes, then try again.

Agent tip: prefer ${BOLD}rtk${NC}, ${BOLD}rg${NC}, and ${BOLD}fd${NC} for high-output commands and code search.
EOF
