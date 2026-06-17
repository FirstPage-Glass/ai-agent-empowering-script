# AI Agent Dev Tools

One-command setup for macOS and Windows development environments, optimized for AI coding agents (opencode, rtk, ripgrep, fd, etc.).

## macOS

```bash
curl -fsSL https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-macos.sh | bash
```

Or download and run:

```bash
chmod +x install-dev-tools-macos.sh
./install-dev-tools-macos.sh
```

### Flags

| Flag | Description |
|---|---|
| `--verbose` | Show detailed brew output |
| `--dry-run` | Preview without installing |
| `--yes` | Skip confirmation prompts |
| `--no-cleanup` | Skip brew autoremove/cleanup |
| `uninstall` | Remove all installed tools |

## Windows

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install-dev-tools-windows.ps1
```

Or download and run directly:

```powershell
irm https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-windows.ps1 | iex
```

### Flags

| Flag | Description |
|---|---|
| `-verbose` | Show detailed winget output |
| `-dryRun` | Preview without installing |
| `-yes` | Skip confirmation prompts |
| `-uninstall` | Remove all installed tools |

## What gets installed

| Tool | macOS | Windows | Purpose |
|---|---|---|---|
| opencode | brew cask | winget | AI coding agent |
| opencode Desktop | brew cask | winget | Desktop app for opencode |
| VS Code | brew cask | winget | Code editor |
| gcloud CLI | brew cask | winget | Google Cloud CLI |
| gws CLI | brew formula | winget | Google Workspace CLI |
| Node.js (LTS) | brew formula | winget | JavaScript runtime |
| pnpm | brew formula | winget | Fast package manager |
| rtk | brew formula | winget | LLM token proxy |
| ripgrep | brew formula | winget | Code search |
| fd | brew formula | winget | File search |
| jq | brew formula | winget | JSON processor |
| yq | brew formula | winget | YAML processor |
| bat | brew formula | winget | File viewer with syntax |
| gh | brew formula | winget | GitHub CLI |
| shellcheck | brew formula | winget | Shell script linter |
| shfmt | brew formula | winget | Shell formatter |
| tree | brew formula | built-in | Directory tree |
| PowerShell 7 | — | winget | Cross-platform shell |
| Python 3 | — | winget | Python runtime |

## After install

```bash
gcloud init
gws auth setup
```
