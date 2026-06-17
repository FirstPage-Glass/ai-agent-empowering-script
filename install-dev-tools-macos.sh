#!/usr/bin/env bash
set -euo pipefail

GREEN=$'\033[1;32m'; BLUE=$'\033[1;34m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

MODE="install"
ASSUME_YES="false"
DRY_RUN="false"
SKIP_CLEANUP="false"
VERBOSE="false"

CASKS=(visual-studio-code gcloud-cli opencode-desktop)
CASK_APP_PATHS=("/Applications/Visual Studio Code.app" "" "")
FORMULAS=(opencode googleworkspace-cli node pnpm rtk ripgrep fd jq yq tree bat gh shellcheck shfmt)
DEAD_SYMLINKS=(/opt/homebrew/bin/code /opt/homebrew/bin/code-tunnel)
VSCODE_EXTENSIONS=(sst-dev.opencode)

for arg in "$@"; do
  case "$arg" in
    uninstall|--uninstall|remove) MODE="uninstall" ;;
    -y|--yes) ASSUME_YES="true" ;;
    --dry-run) DRY_RUN="true" ;;
    --no-cleanup) SKIP_CLEANUP="true" ;;
    --verbose) VERBOSE="true" ;;
    -h|--help)
      cat <<EOF
Usage: install-dev-tools-macos.sh [uninstall|--uninstall|remove] [-y|--yes] [--dry-run] [--no-cleanup] [--verbose]

Without arguments, installs development tools.
Use --verbose to show detailed brew output.
EOF
      exit 0 ;;
    *) die "Unknown argument: $arg" ;;
  esac
done

die() { printf "${RED}✘ %b${NC}\n" "$*" >&2; exit 1; }

STEP=0; TOTAL=0
init_steps() { TOTAL="$1"; STEP=0; }
next_step() {
  STEP=$((STEP + 1))
  printf "${BLUE}[%d/%d]${NC} %s..." "$STEP" "$TOTAL" "$1"
}
ok_step() { printf " ${GREEN}✓${NC}\n"; }
skip_step() { printf " ${YELLOW}−${NC} %s\n" "$1"; }

run_quiet() {
  local log; log="$(mktemp)"
  if "$@" >"$log" 2>&1; then
    rm -f "$log"; return 0
  else
    local rc=$?
    [[ "$VERBOSE" == "true" ]] && cat "$log"
    rm -f "$log"; return "$rc"
  fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script only supports macOS (detected: $(uname -s))."
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$MODE" == "uninstall" ]]; then
    echo "Homebrew not found. Nothing to uninstall."; exit 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Would install Homebrew."; exit 0
  fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 || die "Homebrew is installed but not on PATH. Open a new terminal window and re-run this script."

brew_install() {
  local name="$1" app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then return 0; fi
  if [[ -n "$app_path" && -e "$app_path" ]]; then return 0; fi
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  run_quiet brew install --cask "$name"
}

brew_install_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then return 0; fi
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  run_quiet brew install "$name"
}

brew_uninstall() {
  local name="$1" app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then
    [[ "$DRY_RUN" == "true" ]] && return 0
    run_quiet brew uninstall --cask "$name"
  elif [[ -n "$app_path" && -e "$app_path" ]]; then
    [[ "$DRY_RUN" == "true" ]] && return 0
    rm -rf "$app_path"
  fi
}

brew_uninstall_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    [[ "$DRY_RUN" == "true" ]] && return 0
    run_quiet brew uninstall "$name" 2>/dev/null || true
  fi
}

remove_dead_symlinks() {
  local path
  for path in "${DEAD_SYMLINKS[@]}"; do
    if [[ -L "$path" && ! -e "$path" ]]; then
      rm "$path"
    fi
  done
}

find_code_bin() {
  if command -v code 2>/dev/null; then return 0; fi
  if [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    echo "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    return 0
  fi
  return 1
}

install_vscode_extension() {
  local ext="$1"; local bin
  bin="$(find_code_bin)" || return 0
  if "$bin" --list-extensions 2>/dev/null | grep -Fx "$ext" >/dev/null; then return 0; fi
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  run_quiet "$bin" --install-extension "$ext"
}

verify_rtk() {
  local out
  if ! command -v rtk >/dev/null 2>&1; then return 0; fi
  out="$(rtk gain 2>&1)" || true
}

init_rtk() {
  if ! command -v rtk >/dev/null 2>&1; then return 0; fi
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  if rtk init --show 2>/dev/null | grep -q "opencode"; then return 0; fi
  run_quiet rtk init -g --opencode
}

print_version() {
  local label="$1"; shift
  local out
  out="$("$@" 2>&1)" || true
}

# ── Uninstall ──
if [[ "$MODE" == "uninstall" ]]; then
  if [[ "$ASSUME_YES" != "true" && "$DRY_RUN" != "true" ]]; then
    printf "%b" "${YELLOW}!  Uninstall VS Code, opencode, gcloud-cli, and other tools? Type 'yes' to continue: ${NC}"
    read -r answer
    [[ "$answer" == "yes" ]] || die "Cancelled."
  fi

  echo ""
  init_steps 2
  next_step "Uninstalling packages"
  for ((i=0; i<${#CASKS[@]}; i++)); do brew_uninstall "${CASKS[$i]}" "${CASK_APP_PATHS[$i]}"; done
  for f in "${FORMULAS[@]}"; do brew_uninstall_formula "$f"; done
  ok_step

  if [[ "$SKIP_CLEANUP" != "true" ]]; then
    next_step "Cleaning up"
    [[ "$DRY_RUN" != "true" ]] && { run_quiet brew autoremove; run_quiet brew cleanup; }
    ok_step
  fi

  echo ""
  echo "${BOLD}Uninstall complete.${NC} Homebrew was kept installed."
  exit 0
fi

# ── Install ──
echo ""
echo "${BOLD}Installing development tools...${NC}"
echo ""

init_steps 5

next_step "Installing packages"
remove_dead_symlinks
if [[ "$DRY_RUN" != "true" ]]; then
  for ((i=0; i<${#CASKS[@]}; i++)); do brew_install "${CASKS[$i]}" "${CASK_APP_PATHS[$i]}"; done
  for f in "${FORMULAS[@]}"; do brew_install_formula "$f"; done
fi
ok_step

next_step "Installing VS Code extension"
[[ "$DRY_RUN" != "true" ]] && install_vscode_extension "${VSCODE_EXTENSIONS[0]}"
ok_step

if [[ "$SKIP_CLEANUP" != "true" ]]; then
  next_step "Cleaning up"
  [[ "$DRY_RUN" != "true" ]] && { run_quiet brew autoremove; run_quiet brew cleanup; }
  ok_step
fi

next_step "Verifying installations"
if [[ "$DRY_RUN" != "true" ]]; then
  print_version "VS Code" code --version
  print_version "opencode" opencode --version
  print_version "gcloud" gcloud --version
  print_version "gws" gws --version
  print_version "node" node --version
  print_version "pnpm" pnpm --version
  print_version "rtk" rtk --version
  verify_rtk
fi
ok_step

next_step "Configuring tools"
[[ "$DRY_RUN" != "true" ]] && init_rtk
ok_step

echo ""
echo "${BOLD}All done.${NC}"
echo ""
echo "Next: gcloud init && gws auth setup"
echo "Tip: use ${BOLD}rtk${NC}, ${BOLD}rg${NC}, ${BOLD}fd${NC} for agent-friendly commands."
