param(
  [switch]$uninstall,
  [switch]$yes,
  [switch]$dryRun,
  [switch]$wingetOnly
)

$GREEN = "$([char]0x1b)[1;32m"
$BLUE = "$([char]0x1b)[1;34m"
$YELLOW = "$([char]0x1b)[1;33m"
$RED = "$([char]0x1b)[1;31m"
$BOLD = "$([char]0x1b)[1m"
$NC = "$([char]0x1b)[0m"

$MODE = if ($uninstall) { "uninstall" } else { "install" }

$WINGET_APPS = @(
  "OpenJS.NodeJS.LTS"
  "Python.Python.3.14"
  "Microsoft.PowerShell"
  "Microsoft.VisualStudioCode"
  "SST.OpenCodeDesktop"
)

$NPM_PACKAGES = @(
  "pnpm"
  "opencode-ai"
  "@googleworkspace/cli"
  "rtk"
)

$SCOOP_PACKAGES = @(
  "ripgrep"
  "fd"
  "jq"
  "yq"
  "bat"
  "gh"
  "shellcheck"
  "shfmt"
)

$SCOOP_EXTRAS = @(
  "gcloud"
)

$VSCODE_EXTENSION = "sst-dev.opencode"

function Die {
  param([string]$msg)
  Write-Host "${RED}X $msg${NC}"
  exit 1
}

$STEP = 0; $TOTAL = 0
function InitSteps { param([int]$n); $script:STEP = 0; $script:TOTAL = $n }
function NextStep { param([string]$label); $script:STEP += 1; Write-Host "${BLUE}[$($script:STEP)/$($script:TOTAL)]${NC} $label..." -NoNewline }
function OkStep { Write-Host " ${GREEN}OK${NC}" }

function RefreshPath {
  $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machinePath;$userPath"
}

function Run {
  param([scriptblock]$block)
  & $block
  if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" }
}

function WingetInstall {
  param([string]$id)
  $installed = & winget list --id "$id" --accept-source-agreements 2>$null
  if ($LASTEXITCODE -eq 0 -and $installed -match [regex]::Escape($id)) { return }
  if ($dryRun) { return }
  try {
    Run {& winget install --id "$id" --silent --accept-package-agreements --accept-source-agreements }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to install $id${NC}"
  }
}

function WingetUninstall {
  param([string]$id)
  $installed = & winget list --id "$id" --accept-source-agreements 2>$null
  if ($LASTEXITCODE -ne 0 -or $installed -notmatch [regex]::Escape($id)) { return }
  if ($dryRun) { return }
  try {
    Run {& winget uninstall --id "$id" --silent --accept-source-agreements }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to uninstall $id${NC}"
  }
}

function NpmInstall {
  param([string]$pkg)
  $name = ($pkg -split '/')[0]
  if ($name -eq "@googleworkspace") { $name = "gws" }
  if (Get-Command $name -ErrorAction SilentlyContinue) { return }
  if ($dryRun) { return }
  try {
    Run {& npm install -g "$pkg" }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to install $pkg${NC}"
  }
}

function NpmUninstall {
  param([string]$pkg)
  $name = ($pkg -split '/')[0]
  if ($name -eq "@googleworkspace") { $name = "gws" }
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { return }
  if ($dryRun) { return }
  try {
    Run {& npm uninstall -g "$pkg" }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to uninstall $pkg${NC}"
  }
}

function ScoopInstall {
  param([string]$pkg)
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) { return }
  $installed = & scoop list 2>$null
  if ($installed -match "\b$pkg\b") { return }
  if ($dryRun) { return }
  try {
    Run {& scoop install "$pkg" }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to install $pkg${NC}"
  }
}

function ScoopUninstall {
  param([string]$pkg)
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) { return }
  $installed = & scoop list 2>$null
  if ($installed -notmatch "\b$pkg\b") { return }
  if ($dryRun) { return }
  try {
    Run {& scoop uninstall "$pkg" }
  } catch {
    Write-Host "`n${YELLOW}!  Failed to uninstall $pkg${NC}"
  }
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
  Run { & $code --install-extension $ext }
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
  Run { & rtk init -g --opencode }
}

function EnsureScoop {
  if (Get-Command scoop -ErrorAction SilentlyContinue) { return }
  if ($dryRun) { return }
  Write-Host "`n${BLUE}==>${NC} Installing Scoop..."
  try {
    if (IsAdmin) {
      # Scoop blocks elevated installs unless explicitly allowed.
      $installer = "$env:TEMP\scoop-install.ps1"
      Invoke-RestMethod -Uri https://get.scoop.sh -OutFile $installer
      & $installer -RunAsAdmin
    } else {
      Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    RefreshPath
    & scoop bucket add extras
  } catch {
    Write-Host "`n${YELLOW}!  Failed to install Scoop: $_${NC}"
  }
}

function IsAdmin {
  return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Run the winget batch with admin rights without elevating the whole script
# (Scoop refuses to run as admin, so only this step is elevated).
function InvokeWingetBatch {
  param([string]$mode)  # "install" or "uninstall"
  if ($dryRun) { return }

  # Already elevated, or no script file to re-launch (irm | iex): run in place.
  # winget will raise its own per-package UAC prompt when a package needs it.
  if ((IsAdmin) -or [string]::IsNullOrEmpty($PSCommandPath)) {
    if ($mode -eq "uninstall") { foreach ($app in $WINGET_APPS) { WingetUninstall $app } }
    else { foreach ($app in $WINGET_APPS) { WingetInstall $app } }
    return
  }

  # Normal user: elevate a short-lived child that only does the winget step.
  $childArgs = @("-wingetOnly")
  if ($mode -eq "uninstall") { $childArgs += "-uninstall" }
  $shell = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
  try {
    Start-Process -FilePath $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($childArgs -join ' ')" -Verb RunAs -Wait
  } catch {
    Write-Host "`n${YELLOW}!  Elevation was cancelled; winget packages may not be installed.${NC}"
  }
}

# == Winget-only sub-step (invoked elevated by InvokeWingetBatch) ==
if ($wingetOnly) {
  if ($MODE -eq "uninstall") { foreach ($app in $WINGET_APPS) { WingetUninstall $app } }
  else { foreach ($app in $WINGET_APPS) { WingetInstall $app } }
  exit 0
}

# == Uninstall ==
if ($MODE -eq "uninstall") {
  if (-not $yes -and -not $dryRun) {
    Write-Host "${YELLOW}!  Uninstall VS Code, opencode, gcloud-cli, and other tools? Type 'yes' to continue: ${NC}" -NoNewline
    $answer = Read-Host
    if ($answer -ne "yes") { Die "Cancelled." }
  }

  Write-Host ""
  InitSteps 3
  NextStep "Uninstalling winget packages"
  InvokeWingetBatch "uninstall"
  OkStep

  NextStep "Uninstalling npm packages"
  foreach ($pkg in $NPM_PACKAGES) { NpmUninstall $pkg }
  OkStep

  NextStep "Uninstalling scoop packages"
  foreach ($pkg in $SCOOP_PACKAGES) { ScoopUninstall $pkg }
  foreach ($pkg in $SCOOP_EXTRAS) { ScoopUninstall $pkg }
  OkStep

  Write-Host ""
  Write-Host "${BOLD}Uninstall complete.${NC}"
  exit 0
}

# == Install ==
Write-Host ""
Write-Host "${BOLD}Installing development tools...${NC}"
Write-Host ""

InitSteps 7

NextStep "Installing winget packages (Node.js, Python, VS Code...)"
InvokeWingetBatch "install"
RefreshPath
OkStep

NextStep "Installing Scoop"
EnsureScoop
OkStep

NextStep "Installing scoop packages (gcloud, ripgrep, fd, jq, gh...)"
foreach ($pkg in $SCOOP_EXTRAS) { ScoopInstall $pkg }
foreach ($pkg in $SCOOP_PACKAGES) { ScoopInstall $pkg }
RefreshPath
OkStep

NextStep "Installing npm packages (pnpm, opencode, gws, rtk)"
foreach ($pkg in $NPM_PACKAGES) { NpmInstall $pkg }
RefreshPath
OkStep

NextStep "Installing VS Code extension"
InstallVSCodeExtension $VSCODE_EXTENSION
OkStep

NextStep "Verifying installations"
if (-not $dryRun) {
  $tools = @("code", "opencode", "gcloud", "gws", "node", "pnpm", "rtk", "rg", "fd", "jq", "yq", "bat", "gh", "shellcheck", "shfmt", "pwsh", "python")
  $failed = @()
  foreach ($tool in $tools) {
    $ver = & $tool --version 2>$null
    if ($LASTEXITCODE -ne 0) {
      $ver = & $tool --help 2>$null
      if ($LASTEXITCODE -ne 0) {
        $failed += $tool
      }
    }
  }
  VerifyRtk
  if ($failed.Count -gt 0) {
    Write-Host "`n${YELLOW}!  These tools were not found: $($failed -join ', ')${NC}"
    Write-Host "${YELLOW}   Open a new terminal window and try again.${NC}"
  }
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
