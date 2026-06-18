@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  AI Agent Dev Tools - Windows one-click launcher
REM
REM  Double-click this file. It will:
REM    1. Bypass PowerShell's execution policy (no manual step)
REM    2. Remove the "downloaded from internet" block (MOTW)
REM    3. Run install-dev-tools-windows.ps1 (local, or latest from GitHub)
REM
REM  NOTE: This runs as your normal user on purpose. The installer
REM  elevates only the winget step (one UAC prompt) and keeps Scoop,
REM  npm, etc. un-elevated, because Scoop refuses to run as admin.
REM  Do NOT "Run as administrator" - just double-click.
REM ============================================================

set "REPO_RAW=https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-windows.ps1"
set "PS1=%~dp0install-dev-tools-windows.ps1"

echo.
echo Running AI Agent dev tools installer...
echo.

if exist "%PS1%" (
    REM Local script present: unblock MOTW, then run with policy bypassed
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path '%PS1%' -ErrorAction SilentlyContinue; & '%PS1%' %*"
) else (
    REM No local script: download the latest to a temp file and run it.
    REM Using a real file (not irm^|iex) so the installer can self-elevate the winget step.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=Join-Path $env:TEMP 'install-dev-tools-windows.ps1'; Invoke-RestMethod -Uri '%REPO_RAW%' -OutFile $t; & $t %*"
)

echo.
echo Done. You can close this window.
pause >nul
