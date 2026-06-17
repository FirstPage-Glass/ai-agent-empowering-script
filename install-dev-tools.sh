#!/usr/bin/env bash
set -euo pipefail

GREEN=$'\033[1;32m'; BLUE=$'\033[1;34m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

info() { printf "${BLUE}==>${NC} %b\n" "$*"; }
ok()   { printf "${GREEN}✔ %b${NC}\n" "$*"; }
warn() { printf "${YELLOW}!  %b${NC}\n" "$*"; }
die()  { printf "${RED}✘ %b${NC}\n" "$*" >&2; exit 1; }

MODE="install"
ASSUME_YES="false"

for arg in "$@"; do
  case "$arg" in
    uninstall|--uninstall|remove)
      MODE="uninstall"
      ;;
    -y|--yes)
      ASSUME_YES="true"
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 [uninstall|--uninstall|remove] [-y|--yes]

Without arguments, installs development tools.
Use uninstall, --uninstall, or remove to uninstall development tools.
Use -y or --yes to skip uninstall confirmation.
EOF
      exit 0
      ;;
    *)
      die "Unknown argument: $arg"
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script only supports macOS (detected: $(uname -s))."
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$MODE" == "uninstall" ]]; then
    warn "Homebrew not found. Nothing to uninstall."
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

install_cask() {
  local name="$1"
  local app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then
    ok "$name (cask) already installed."
  elif [[ -n "$app_path" && -e "$app_path" ]]; then
    ok "$name already exists at $app_path."
  else
    info "Installing $name (cask)..."
    brew install --cask "$name"
    ok "$name installed."
  fi
}

install_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    ok "$name already installed."
  else
    info "Installing $name..."
    brew install "$name"
    ok "$name installed."
  fi
}

uninstall_cask() {
  local name="$1"
  local app_path="${2:-}"
  if brew list --cask "$name" >/dev/null 2>&1; then
    info "Uninstalling $name (cask)..."
    brew uninstall --cask "$name"
    ok "$name uninstalled."
  elif [[ -n "$app_path" && -e "$app_path" ]]; then
    info "Removing $app_path..."
    rm -rf "$app_path"
    ok "$name app removed."
  else
    ok "$name (cask) is not installed."
  fi
}

uninstall_formula() {
  local name="$1"
  if brew list "$name" >/dev/null 2>&1; then
    info "Uninstalling $name..."
    brew uninstall "$name"
    ok "$name uninstalled."
  else
    ok "$name is not installed."
  fi
}

confirm_uninstall() {
  if [[ "$ASSUME_YES" == "true" ]]; then
    return 0
  fi

  printf "%b" "${YELLOW}!  This will uninstall VS Code, opencode, gcloud-cli, and googleworkspace-cli. Type 'yes' to continue: ${NC}"
  read -r answer
  [[ "$answer" == "yes" ]] || die "Uninstall cancelled."
}

install_vscode_extension() {
  local extension="$1"
  local code_bin=""

  if command -v code >/dev/null 2>&1; then
    code_bin="$(command -v code)"
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  else
    warn "VS Code command not found. Install extension manually: $extension"
    return 0
  fi

  if "$code_bin" --list-extensions 2>/dev/null | grep -Fx "$extension" >/dev/null; then
    ok "$extension extension already installed."
  else
    info "Installing VS Code extension $extension..."
    "$code_bin" --install-extension "$extension"
    ok "$extension extension installed."
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
  uninstall_cask    visual-studio-code "/Applications/Visual Studio Code.app"
  uninstall_formula opencode
  uninstall_cask    gcloud-cli
  uninstall_formula googleworkspace-cli

  cat <<EOF

${BOLD}Uninstall complete.${NC}

Homebrew was kept installed.
EOF
  exit 0
fi

info "Installing development tools..."

install_cask    visual-studio-code "/Applications/Visual Studio Code.app"
install_vscode_extension sst-dev.opencode
install_formula opencode
install_cask    gcloud-cli
install_formula googleworkspace-cli

info "Verifying installations..."
print_version "VS Code"                 code     --version
print_version "opencode"                opencode --version
print_version "gcloud"                  gcloud   --version
print_version "gws (Google Workspace)"  gws      --version

cat <<EOF

${BOLD}All done.${NC}

Next steps (run these yourself whenever you're ready):
  gcloud init        # sign in and configure the Google Cloud CLI
  gws auth setup     # one-time Google Workspace auth (requires gcloud)

Tip: if any command above was reported as not on PATH, open a ${BOLD}new terminal window${NC}
so your PATH refreshes, then try again.
EOF
