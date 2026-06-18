# AI Agent Dev Tools

One-command setup for macOS and Windows development environments, optimized for AI coding agents (opencode, rtk, ripgrep, fd, etc.).

## macOS

No Homebrew or sudo required. Installs to `~/.local/bin`.

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
| `--verbose` | Show detailed download/install output |
| `--dry-run` | Preview without installing |
| `--yes` | Skip confirmation prompts |
| `uninstall` | Remove all installed tools |

## Windows

### One click (recommended)

Download the repo and **double-click `install-dev-tools.cmd`**. That's it.

### One line (PowerShell)

Open a **normal (non-admin) PowerShell** and run:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools.cmd -OutFile $env:TEMP\_install.cmd; & $env:TEMP\_install.cmd
```

The installer handles everything:
- Installs Git, Node.js, Python, VS Code, opencode CLI via winget
- Installs gcloud CLI, ripgrep, fd, bat, gh, shellcheck, shfmt and more via Scoop
- Downloads and installs rtk (Rust Token Killer) from GitHub
- Installs pnpm and Google Workspace CLI via npm
- Configures rtk for opencode and adds it to PATH
- Installs opencode skills (email-planner)

> **Tip:** To avoid the "Open File – Security Warning" dialog, use `git clone` instead of downloading a ZIP:
> ```powershell
> git clone https://github.com/FirstPage-Glass/ai-agent-empowering-script.git
> cd ai-agent-empowering-script
> ```

### Flags

| Flag | Description |
|---|---|
| `uninstall` | Remove all installed tools |

## What gets installed

| Tool | macOS | Windows | Purpose |
|---|---|---|---|
| opencode CLI | curl | winget (SST.opencode) | AI coding agent (TUI) |
| opencode Desktop | — | winget (SST.OpenCodeDesktop) | Desktop app for opencode |
| VS Code | zip download | winget | Code editor |
| gcloud CLI | tarball | scoop (extras) | Google Cloud CLI |
| gws CLI | npm | npm | Google Workspace CLI |
| Node.js (LTS) | nvm (curl) | winget | JavaScript runtime |
| pnpm | npm | npm | Fast package manager |
| rtk | npm | GitHub release | LLM token proxy (Rust) |
| ripgrep | GitHub release | scoop | Code search |
| fd | GitHub release | scoop | File search |
| jq | GitHub release | scoop | JSON processor |
| yq | GitHub release | scoop | YAML processor |
| bat | GitHub release | scoop | File viewer with syntax |
| gh | GitHub release | scoop | GitHub CLI |
| shellcheck | GitHub release | scoop | Shell script linter |
| shfmt | GitHub release | scoop | Shell formatter |
| PowerShell 7 | — | winget | Cross-platform shell |
| Python 3 | — | winget | Python runtime |

## After install

```bash
gcloud init
gws auth setup
```
