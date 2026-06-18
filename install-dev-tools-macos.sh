#!/usr/bin/env bash
set -euo pipefail

GREEN=$'\033[1;32m'; BLUE=$'\033[1;34m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; BOLD=$'\033[1m'; NC=$'\033[0m'

MODE="install"
ASSUME_YES="false"
DRY_RUN="false"
VERBOSE="false"

LOCAL_BIN="$HOME/.local/bin"
APPS_DIR="$HOME/Applications"
TEMP_DIR=""

SKILLS_DIR="$HOME/.config/opencode/skills"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.jsonc"
SKILL_BASE_URL="https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/skills"
SKILLS=(email-planner)

declare -A RESULTS=()

die() { printf "${RED}✘ %b${NC}\n" "$*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    uninstall|--uninstall|remove) MODE="uninstall" ;;
    -y|--yes) ASSUME_YES="true" ;;
    --dry-run) DRY_RUN="true" ;;
    --verbose) VERBOSE="true" ;;
    -h|--help)
      cat <<EOF
Usage: install-dev-tools-macos.sh [uninstall|--uninstall|remove] [-y|--yes] [--dry-run] [--verbose]

Parallel installation of development tools without Homebrew or sudo.
EOF
      exit 0 ;;
    *) die "Unknown argument: $arg" ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script only supports macOS (detected: $(uname -s))."
fi

ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  ARCH_SUFFIX="arm64"
  ARCH_DARWIN="aarch64-apple-darwin"
elif [[ "$ARCH" == "x86_64" ]]; then
  ARCH_SUFFIX="amd64"
  ARCH_DARWIN="x86_64-apple-darwin"
else
  die "Unsupported architecture: $ARCH"
fi

setup_dirs() {
  mkdir -p "$LOCAL_BIN"
  mkdir -p "$APPS_DIR"
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
}

add_to_path() {
  local shell_rc="$HOME/.zshrc"
  local path_line="export PATH=\"$LOCAL_BIN:\$PATH\""
  if [[ -f "$shell_rc" ]] && grep -qF "$LOCAL_BIN" "$shell_rc"; then
    return 0
  fi
  echo "" >> "$shell_rc"
  echo "# Added by install-dev-tools-macos.sh" >> "$shell_rc"
  echo "$path_line" >> "$shell_rc"
  export PATH="$LOCAL_BIN:$PATH"
}

run_quiet() {
  if [[ "$VERBOSE" == "true" ]]; then
    "$@"
  else
    "$@" >/dev/null 2>&1
  fi
}

get_latest_version() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | cut -d'"' -f4 | head -1
}

install_nodejs() {
  local name="nodejs"
  if command -v node >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash >/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if nvm install --lts >/dev/null 2>&1; then
      RESULTS[$name]="success"
      return 0
    fi
  fi
  RESULTS[$name]="failed"
  return 1
}

install_opencode() {
  local name="opencode"
  if command -v opencode >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  if curl -fsSL https://opencode.ai/install | bash >/dev/null 2>&1; then
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

install_gcloud() {
  local name="gcloud"
  if command -v gcloud >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  local url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-${ARCH}.tar.gz"
  local tarball="$TEMP_DIR/gcloud.tar.gz"
  if curl -fsSL "$url" -o "$tarball" && tar -xzf "$tarball" -C "$TEMP_DIR"; then
    if "$TEMP_DIR/google-cloud-sdk/install.sh" --quiet --usage-reporting false --path-update false >/dev/null 2>&1; then
      export PATH="$TEMP_DIR/google-cloud-sdk/bin:$PATH"
      RESULTS[$name]="success"
      return 0
    fi
  fi
  RESULTS[$name]="failed"
  return 1
}

install_vscode() {
  local name="vscode"
  if [[ -d "$APPS_DIR/Visual Studio Code.app" ]]; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  local url="https://update.code.visualstudio.com/latest/darwin-${ARCH}/stable"
  local zipfile="$TEMP_DIR/vscode.zip"
  if curl -fsSL "$url" -o "$zipfile" && unzip -q "$zipfile" -d "$APPS_DIR"; then
    ln -sf "$APPS_DIR/Visual Studio Code.app/Contents/Resources/app/bin/code" "$LOCAL_BIN/code"
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

install_pnpm() {
  local name="pnpm"
  if command -v pnpm >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  if ! command -v node >/dev/null 2>&1; then
    RESULTS[$name]="waiting"
    return 1
  fi
  if curl -fsSL https://get.pnpm.io/install.sh | sh - >/dev/null 2>&1; then
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

install_gws() {
  local name="gws"
  if command -v gws >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  if ! command -v node >/dev/null 2>&1; then
    RESULTS[$name]="waiting"
    return 1
  fi
  if npm install -g @googleworkspace/cli >/dev/null 2>&1; then
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

install_rtk() {
  local name="rtk"
  if command -v rtk >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  if ! command -v node >/dev/null 2>&1; then
    RESULTS[$name]="waiting"
    return 1
  fi
  if npm install -g rtk >/dev/null 2>&1; then
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

download_and_extract() {
  local name="$1"
  local url="$2"
  local archive_type="$3"
  local binary_name="$4"
  local extract_cmd="$5"
  
  if command -v "$binary_name" >/dev/null 2>&1; then
    RESULTS[$name]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS[$name]="dry-run"
    return 0
  fi
  
  local archive="$TEMP_DIR/$name.$archive_type"
  if ! curl -fsSL "$url" -o "$archive"; then
    RESULTS[$name]="failed"
    return 1
  fi
  
  local extract_dir="$TEMP_DIR/$name"
  mkdir -p "$extract_dir"
  
  if [[ "$archive_type" == "tar.gz" ]]; then
    tar -xzf "$archive" -C "$extract_dir"
  elif [[ "$archive_type" == "zip" ]]; then
    unzip -q "$archive" -d "$extract_dir"
  fi
  
  local binary_path
  if [[ -n "$extract_cmd" ]]; then
    binary_path="$(eval "$extract_cmd")"
  else
    binary_path="$extract_dir/$binary_name"
  fi
  
  if [[ -f "$binary_path" ]]; then
    cp "$binary_path" "$LOCAL_BIN/$binary_name"
    chmod +x "$LOCAL_BIN/$binary_name"
    RESULTS[$name]="success"
    return 0
  fi
  RESULTS[$name]="failed"
  return 1
}

install_ripgrep() {
  local version
  version="$(get_latest_version BurntSushi/ripgrep)"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/$version/ripgrep-${version#v}-$ARCH_DARWIN.tar.gz"
  download_and_extract "ripgrep" "$url" "tar.gz" "rg" "find $TEMP_DIR/ripgrep -name rg -type f | head -1"
}

install_fd() {
  local version
  version="$(get_latest_version sharkdp/fd)"
  local url="https://github.com/sharkdp/fd/releases/download/$version/fd-${version}-$ARCH_DARWIN.tar.gz"
  download_and_extract "fd" "$url" "tar.gz" "fd" "find $TEMP_DIR/fd -name fd -type f | head -1"
}

install_jq() {
  local version
  version="$(get_latest_version jqlang/jq)"
  local url="https://github.com/jqlang/jq/releases/download/$version/jq-macos-${ARCH_SUFFIX}"
  if command -v jq >/dev/null 2>&1; then
    RESULTS["jq"]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS["jq"]="dry-run"
    return 0
  fi
  if curl -fsSL "$url" -o "$LOCAL_BIN/jq" && chmod +x "$LOCAL_BIN/jq"; then
    RESULTS["jq"]="success"
    return 0
  fi
  RESULTS["jq"]="failed"
  return 1
}

install_yq() {
  local version
  version="$(get_latest_version mikefarah/yq)"
  local url="https://github.com/mikefarah/yq/releases/download/$version/yq_darwin_${ARCH_SUFFIX}"
  if command -v yq >/dev/null 2>&1; then
    RESULTS["yq"]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS["yq"]="dry-run"
    return 0
  fi
  if curl -fsSL "$url" -o "$LOCAL_BIN/yq" && chmod +x "$LOCAL_BIN/yq"; then
    RESULTS["yq"]="success"
    return 0
  fi
  RESULTS["yq"]="failed"
  return 1
}

install_bat() {
  local version
  version="$(get_latest_version sharkdp/bat)"
  local url="https://github.com/sharkdp/bat/releases/download/$version/bat-${version}-$ARCH_DARWIN.tar.gz"
  download_and_extract "bat" "$url" "tar.gz" "bat" "find $TEMP_DIR/bat -name bat -type f | head -1"
}

install_gh() {
  local version
  version="$(get_latest_version cli/cli)"
  local url="https://github.com/cli/cli/releases/download/$version/gh_${version#v}_macOS_${ARCH_SUFFIX}.zip"
  download_and_extract "gh" "$url" "zip" "gh" "find $TEMP_DIR/gh -name gh -type f | head -1"
}

install_shellcheck() {
  local version
  version="$(get_latest_version koalaman/shellcheck)"
  local url="https://github.com/koalaman/shellcheck/releases/download/$version/shellcheck-${version}.darwin.${ARCH}.tar.xz"
  if command -v shellcheck >/dev/null 2>&1; then
    RESULTS["shellcheck"]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS["shellcheck"]="dry-run"
    return 0
  fi
  local archive="$TEMP_DIR/shellcheck.tar.xz"
  if curl -fsSL "$url" -o "$archive" && tar -xJf "$archive" -C "$TEMP_DIR"; then
    local binary_path
    binary_path="$(find $TEMP_DIR -name shellcheck -type f | head -1)"
    if [[ -f "$binary_path" ]]; then
      cp "$binary_path" "$LOCAL_BIN/shellcheck"
      chmod +x "$LOCAL_BIN/shellcheck"
      RESULTS["shellcheck"]="success"
      return 0
    fi
  fi
  RESULTS["shellcheck"]="failed"
  return 1
}

install_shfmt() {
  local version
  version="$(get_latest_version mvdan/sh)"
  local url="https://github.com/mvdan/sh/releases/download/$version/shfmt_${version}_darwin_${ARCH_SUFFIX}"
  if command -v shfmt >/dev/null 2>&1; then
    RESULTS["shfmt"]="skipped"
    return 0
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    RESULTS["shfmt"]="dry-run"
    return 0
  fi
  if curl -fsSL "$url" -o "$LOCAL_BIN/shfmt" && chmod +x "$LOCAL_BIN/shfmt"; then
    RESULTS["shfmt"]="success"
    return 0
  fi
  RESULTS["shfmt"]="failed"
  return 1
}

install_skills() {
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  local skill
  for skill in "${SKILLS[@]}"; do
    local dest="$SKILLS_DIR/$skill"
    mkdir -p "$dest/scripts"
    curl -fsSL "$SKILL_BASE_URL/$skill/SKILL.md" -o "$dest/SKILL.md"
    curl -fsSL "$SKILL_BASE_URL/$skill/scripts/email_planner.py" -o "$dest/scripts/email_planner.py"
  done
  update_opencode_config
}

strip_jsonc() {
  sed -E 's|//[^\"]*$||g; s|/\*[^*]*\*/||g' "$1" | sed '/^[[:space:]]*$/d'
}

update_opencode_config() {
  local config_dir
  config_dir="$(dirname "$OPENCODE_CONFIG")"
  mkdir -p "$config_dir"
  if [[ ! -f "$OPENCODE_CONFIG" ]]; then
    cat > "$OPENCODE_CONFIG" <<'JSONCEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["~/.config/opencode/skills"]
  }
}
JSONCEOF
    return 0
  fi
  local tmp; tmp="$(mktemp)"
  local stripped; stripped="$(mktemp)"
  strip_jsonc "$OPENCODE_CONFIG" > "$stripped"
  if jq -e '.skills.paths // [] | index("~/.config/opencode/skills")' "$stripped" >/dev/null 2>&1; then
    rm -f "$tmp" "$stripped"
    return 0
  fi
  if jq -e '.skills' "$stripped" >/dev/null 2>&1; then
    jq '.skills.paths = ((.skills.paths // []) + ["~/.config/opencode/skills"] | unique)' "$stripped" > "$tmp"
  else
    jq '. + {"skills": {"paths": ["~/.config/opencode/skills"]}}' "$stripped" > "$tmp"
  fi
  mv "$tmp" "$OPENCODE_CONFIG"
  rm -f "$stripped"
}

uninstall_skills() {
  if [[ "$DRY_RUN" == "true" ]]; then return 0; fi
  local skill
  for skill in "${SKILLS[@]}"; do
    rm -rf "$SKILLS_DIR/$skill"
  done
  if [[ -d "$SKILLS_DIR" ]] && [[ -z "$(ls -A "$SKILLS_DIR" 2>/dev/null)" ]]; then
    rmdir "$SKILLS_DIR" 2>/dev/null || true
  fi
  if [[ -f "$OPENCODE_CONFIG" ]]; then
    local tmp; tmp="$(mktemp)"
    local stripped; stripped="$(mktemp)"
    strip_jsonc "$OPENCODE_CONFIG" > "$stripped"
    jq 'if .skills.paths then .skills.paths = (.skills.paths | map(select(. != "~/.config/opencode/skills"))) | if .skills.paths == [] then del(.skills.paths) else . end else . end | if .skills == {} then del(.skills) else . end' "$stripped" > "$tmp"
    mv "$tmp" "$OPENCODE_CONFIG"
    rm -f "$stripped"
  fi
}

uninstall_all() {
  if [[ "$ASSUME_YES" != "true" && "$DRY_RUN" != "true" ]]; then
    printf "%b" "${YELLOW}!  Uninstall all tools installed by this script? Type 'yes' to continue: ${NC}"
    read -r answer
    [[ "$answer" == "yes" ]] || die "Cancelled."
  fi

  echo ""
  echo "${BLUE}Uninstalling tools...${NC}"
  
  rm -rf "$LOCAL_BIN"
  rm -rf "$APPS_DIR/Visual Studio Code.app"
  rm -rf "$HOME/.nvm"
  rm -rf "$HOME/.opencode"
  
  uninstall_skills
  
  local shell_rc="$HOME/.zshrc"
  if [[ -f "$shell_rc" ]]; then
    sed -i.bak "/# Added by install-dev-tools-macos.sh/d" "$shell_rc"
    sed -i.bak "/$LOCAL_BIN/d" "$shell_rc"
    rm -f "${shell_rc}.bak"
  fi
  
  echo ""
  echo "${BOLD}Uninstall complete.${NC}"
  exit 0
}

print_result() {
  local name="$1"
  local status="${RESULTS[$name]:-unknown}"
  case "$status" in
    success) printf "  ${GREEN}✓${NC} %-16s installed\n" "$name" ;;
    skipped) printf "  ${BLUE}−${NC} %-16s already installed\n" "$name" ;;
    dry-run) printf "  ${YELLOW}?${NC} %-16s would install\n" "$name" ;;
    failed)  printf "  ${RED}✗${NC} %-16s failed\n" "$name" ;;
    *)       printf "  ${YELLOW}?${NC} %-16s unknown\n" "$name" ;;
  esac
}

# ── Main ──
if [[ "$MODE" == "uninstall" ]]; then
  uninstall_all
fi

echo ""
echo "${BOLD}Installing development tools (parallel mode)...${NC}"
echo ""

setup_dirs
add_to_path

echo "${BLUE}Phase 1: Parallel downloads${NC}"

install_nodejs &
NODE_PID=$!

install_opencode &
install_gcloud &
install_vscode &
install_ripgrep &
install_fd &
install_jq &
install_yq &
install_bat &
install_gh &
install_shellcheck &
install_shfmt &

wait $NODE_PID

echo ""
echo "${BLUE}Phase 2: npm packages (requires Node.js)${NC}"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

install_pnpm
install_gws
install_rtk

wait

echo ""
echo "${BLUE}Phase 3: Skills${NC}"
install_skills

echo ""
echo "${BOLD}Installation Summary${NC}"
echo ""

print_result "nodejs"
print_result "opencode"
print_result "gcloud"
print_result "vscode"
print_result "pnpm"
print_result "gws"
print_result "rtk"
print_result "ripgrep"
print_result "fd"
print_result "jq"
print_result "yq"
print_result "bat"
print_result "gh"
print_result "shellcheck"
print_result "shfmt"

local success=0
local total=0
for key in "${!RESULTS[@]}"; do
  total=$((total + 1))
  if [[ "${RESULTS[$key]}" == "success" || "${RESULTS[$key]}" == "skipped" ]]; then
    success=$((success + 1))
  fi
done

echo ""
echo "${GREEN}$success/$total tools installed successfully${NC}"
echo ""
echo "Next: ${BOLD}source ~/.zshrc${NC} then ${BOLD}gcloud init${NC} && ${BOLD}gws auth setup${NC}"
echo "Tip: use ${BOLD}rtk${NC}, ${BOLD}rg${NC}, ${BOLD}fd${NC} for agent-friendly commands."
