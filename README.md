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

Download the repo and **double-click `install-dev-tools.cmd`**. That's it.

The installer handles everything:
- Installs Git, Node.js, Python, VS Code, opencode CLI via winget
- Installs gcloud CLI, ripgrep, fd, bat, gh, and more via Scoop
- Downloads and installs rtk (Rust Token Killer) from GitHub
- Installs pnpm and Google Workspace CLI via npm
- Configures rtk for opencode

> **Tip:** To avoid the "Open File – Security Warning" dialog, use `git clone` instead of downloading a ZIP:
> ```powershell
> git clone https://github.com/FirstPage-Glass/ai-agent-empowering-script.git
> cd ai-agent-empowering-script
> ```

### One line (PowerShell)

Open a **normal (non-admin) PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools.cmd | iex
```

### Flags

| Flag | Description |
|---|---|
| `uninstall` | Remove all installed tools |

## What gets installed

| Tool | macOS | Windows | Purpose |
|---|---|---|---|
| opencode CLI | brew formula | winget (SST.opencode) | AI coding agent (TUI) |
| opencode Desktop | brew cask | winget (SST.OpenCodeDesktop) | Desktop app for opencode |
| VS Code | brew cask | winget | Code editor |
| gcloud CLI | brew cask | scoop (extras) | Google Cloud CLI |
| gws CLI | brew formula | npm | Google Workspace CLI |
| Node.js (LTS) | brew formula | winget | JavaScript runtime |
| pnpm | brew formula | npm | Fast package manager |
| rtk | brew formula | GitHub release | LLM token proxy (Rust) |
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
