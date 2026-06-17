param(
  [switch]$uninstall,
  [switch]$yes,
  [switch]$dryRun,
  [switch]$verbose
)

$GREEN = "$([char]0x1b)[1;32m"
$BLUE = "$([char]0x1b)[1;34m"
$YELLOW = "$([char]0x1b)[1;33m"
$RED = "$([char]0x1b)[1;31m"
$BOLD = "$([char]0x1b)[1m"
$NC = "$([char]0x1b)[0m"

$MODE = if ($uninstall) { "uninstall" } else { "install" }
$SKIP_CLEANUP = $false

$WINGET_APPS = @(
  "OpenJS.NodeJS.LTS"
  "Python.Python.3.14"
  "Microsoft.PowerShell"
  "pnpm.pnpm"
  "SST.opencode"
  "SST.OpenCodeDesktop"
  "rtk-ai.rtk"
  "Microsoft.VisualStudioCode"
  "Google.CloudSDK"
  "Google.WorkspaceCLI"
  "BurntSushi.ripgrep.MSVC"
  "sharkdp.fd"
  "jqlang.jq"
  "MikeFarah.yq"
  "sharkdp.bat"
  "GitHub.cli"
  "koalaman.shellcheck"
  "mvdan.shfmt"
)

$VSCODE_EXTENSION = "sst-dev.opencode"

function Die {
  param([string]$msg)
  Write-Host "${RED}✘ $msg${NC}"
  exit 1
}

$STEP = 0; $TOTAL = 0
function InitSteps { param([int]$n); $script:STEP = 0; $script:TOTAL = $n }
function NextStep { param([string]$label); $script:STEP += 1; Write-Host "${BLUE}[$($script:STEP)/$($script:TOTAL)]${NC} $label..." -NoNewline }
function OkStep { Write-Host " ${GREEN}✓${NC}" }

function RunQuiet {
  param([scriptblock]$block)
  if ($verbose) {
    & $block
    if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" }
  } else {
    $output = & $block 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host "`n${RED}$output${NC}" -ForegroundColor Red
      throw "Command failed with exit code $LASTEXITCODE"
    }
  }
}

function WingetInstall {
  param([string]$id)
  $installed = & winget list --id "$id" --accept-source-agreements 2>$null
  if ($LASTEXITCODE -eq 0 -and $installed -match [regex]::Escape($id)) { return }
  if ($dryRun) { return }
  RunQuiet { & winget install --id "$id" --silent --accept-package-agreements --accept-source-agreements }
}

function WingetUninstall {
  param([string]$id)
  $installed = & winget list --id "$id" --accept-source-agreements 2>$null
  if ($LASTEXITCODE -ne 0 -or $installed -notmatch [regex]::Escape($id)) { return }
  if ($dryRun) { return }
  RunQuiet { & winget uninstall --id "$id" --silent --accept-source-agreements }
}

function FindCodeCmd {
  $paths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
    "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd"
    "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
  )
  foreach ($p in $paths) { if (Test-Path $p) { return $p } }
  return $null
}

function InstallVSCodeExtension {
  param([string]$ext)
  $code = FindCodeCmd
  if (-not $code) { return }
  $list = & $code --list-extensions 2>$null
  if ($list -contains $ext) { return }
  if ($dryRun) { return }
  RunQuiet { & $code --install-extension $ext }
}

function VerifyRtk {
  if (-not (Get-Command rtk -ErrorAction SilentlyContinue)) { return }
  $null = & rtk gain 2>&1
}

function InitRtk {
  if (-not (Get-Command rtk -ErrorAction SilentlyContinue)) { return }
  if ($dryRun) { return }
  $show = & rtk init --show 2>$null
  if ($show -match "opencode") { return }
  RunQuiet { & rtk init -g --opencode }
}

# ── Auto-elevate ──
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $elevatedArgs = @()
  if ($uninstall) { $elevatedArgs += "-uninstall" }
  if ($yes) { $elevatedArgs += "-yes" }
  if ($dryRun) { $elevatedArgs += "-dryRun" }
  if ($verbose) { $elevatedArgs += "-verbose" }
  $shell = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
  Start-Process -FilePath $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($elevatedArgs -join ' ')" -Verb RunAs
  exit
}

# ── Uninstall ──
if ($MODE -eq "uninstall") {
  if (-not $yes -and -not $dryRun) {
    Write-Host "${YELLOW}!  Uninstall VS Code, opencode, gcloud-cli, and other tools? Type 'yes' to continue: ${NC}" -NoNewline
    $answer = Read-Host
    if ($answer -ne "yes") { Die "Cancelled." }
  }

  Write-Host ""
  InitSteps 2
  NextStep "Uninstalling packages"
  foreach ($app in $WINGET_APPS) { WingetUninstall $app }
  OkStep

  Write-Host ""
  Write-Host "${BOLD}Uninstall complete.${NC}"
  exit 0
}

# ── Install ──
Write-Host ""
Write-Host "${BOLD}Installing development tools...${NC}"
Write-Host ""

InitSteps 5

NextStep "Installing packages"
foreach ($app in $WINGET_APPS) { WingetInstall $app }
OkStep

NextStep "Installing VS Code extension"
InstallVSCodeExtension $VSCODE_EXTENSION
OkStep

NextStep "Verifying installations"
if (-not $dryRun) {
  $tools = @("code", "opencode", "gcloud", "gws", "node", "pnpm", "rtk", "rg", "fd", "jq", "yq", "bat", "gh", "shellcheck", "shfmt", "pwsh", "python")
  foreach ($tool in $tools) {
    $ver = & $tool --version 2>$null
    if ($LASTEXITCODE -ne 0) { $ver = & $tool --help 2>$null; if ($LASTEXITCODE -ne 0) { $ver = "not found" } }
  }
  VerifyRtk
}
OkStep

NextStep "Configuring tools"
InitRtk
OkStep

Write-Host ""
Write-Host "${BOLD}All done.${NC}"
Write-Host ""
Write-Host "Next: gcloud init && gws auth setup"
Write-Host "Tip: use ${BOLD}rtk${NC}, ${BOLD}rg${NC}, ${BOLD}fd${NC} for agent-friendly commands."
