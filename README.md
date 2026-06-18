# AI Agent Dev Tools

One-command setup for macOS and Windows development environments, optimized for AI coding agents (opencode, rtk, ripgrep, fd, etc.).

## macOS

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-macos.sh) --yes
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

### One click (recommended)

Download the repo and **double-click `install-dev-tools-windows.cmd`**. That's it — approve the single UAC prompt for the winget step and walk away. The launcher bypasses PowerShell's execution policy, removes the "downloaded from internet" block, and runs the installer for you.

> **Do not "Run as administrator".** Just double-click. The installer runs as your normal user and elevates *only* the winget step (one UAC prompt), because Scoop refuses to install under an administrator account. Running the whole thing elevated is unnecessary and works against Scoop.

> **Tip:** To avoid the one-time "Open File – Security Warning" dialog entirely, get the files with `git clone` instead of downloading a ZIP — git-cloned files are never tagged as downloaded.
>
> ```powershell
> git clone https://github.com/FirstPage-Glass/ai-agent-empowering-script.git
> cd ai-agent-empowering-script
> ```

### One line (PowerShell)

Or open a **normal (non-admin) PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-windows.ps1 | iex
```

### Manual

If you already have the `.ps1` locally, open a **normal (non-admin) PowerShell** and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install-dev-tools-windows.ps1
```

### Flags

| Flag | Description |
|---|---|
| `-dryRun` | Preview without installing |
| `-yes` | Skip confirmation prompts |
| `-uninstall` | Remove all installed tools |

## What gets installed

| Tool | macOS | Windows | Purpose |
|---|---|---|---|
| opencode | brew formula | npm | AI coding agent |
| opencode Desktop | brew cask | winget | Desktop app for opencode |
| VS Code | brew cask | winget | Code editor |
| gcloud CLI | brew cask | scoop | Google Cloud CLI |
| gws CLI | brew formula | npm | Google Workspace CLI |
| Node.js (LTS) | brew formula | winget | JavaScript runtime |
| pnpm | brew formula | npm | Fast package manager |
| rtk | brew formula | npm | LLM token proxy |
| ripgrep | brew formula | scoop | Code search |
| fd | brew formula | scoop | File search |
| jq | brew formula | scoop | JSON processor |
| yq | brew formula | scoop | YAML processor |
| bat | brew formula | scoop | File viewer with syntax |
| gh | brew formula | scoop | GitHub CLI |
| shellcheck | brew formula | scoop | Shell script linter |
| shfmt | brew formula | scoop | Shell formatter |
| tree | brew formula | built-in | Directory tree |
| PowerShell 7 | — | winget | Cross-platform shell |
| Python 3 | brew formula | winget | Python runtime |

## After install

```bash
gcloud init
gws auth setup
```
