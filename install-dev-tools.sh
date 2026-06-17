#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[1;32m'; BLUE='\033[1;34m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; BOLD='\033[1m'; NC='\033[0m'

info() { printf "${BLUE}==>${NC} %b\n" "$*"; }
ok()   { printf "${GREEN}✔ %b${NC}\n" "$*"; }
warn() { printf "${YELLOW}!  %b${NC}\n" "$*"; }
die()  { printf "${RED}✘ %b${NC}\n" "$*" >&2; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script only supports macOS (detected: $(uname -s))."
fi

if ! command -v brew >/dev/null 2>&1; then
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
  if brew list --cask "$name" >/dev/null 2>&1; then
    ok "$name (cask) already installed."
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

print_version() {
  local label="$1"; shift
  local out
  if out="$("$@" 2>&1)"; then
    ok "$label: $(printf '%s' "$out" | head -n1)"
  else
    warn "$label: installed, but '$1' is not on this shell's PATH yet."
  fi
}

info "Installing development tools..."

install_cask    visual-studio-code
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
