@echo off
setlocal EnableDelayedExpansion

for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "G=%ESC%[92m"
set "R=%ESC%[91m"
set "Y=%ESC%[93m"
set "B=%ESC%[94m"
set "W=%ESC%[1m"
set "N=%ESC%[0m"

set "RTK_VER=v0.42.4"
set "RTK_URL=https://github.com/rtk-ai/rtk/releases/download/%RTK_VER%/rtk-x86_64-pc-windows-msvc.zip"
set "RTK_DIR=%USERPROFILE%\.local\bin"

set "STEP=0"
set "TOTAL=8"

set "ARGS=%*"
for %%a in (%ARGS%) do set "MODE=%%a"

if "%MODE%"=="uninstall" goto :uninstall

echo.
echo %W%AI Agent Dev Tools - Windows Installer%N%
echo.

call :step "Installing winget packages"
call :winget_step
call :ok

call :step "Installing Scoop"
call :scoop_step
call :ok

call :step "Installing Scoop packages"
call :scoop_apps_step
call :ok

call :step "Installing rtk"
call :rtk_step
call :ok

call :step "Installing npm packages"
call :npm_step
call :ok

call :step "Installing VS Code extension"
call :vscode_step
call :ok

call :step "Verifying installations"
call :verify_step
call :ok

call :step "Configuring tools"
call :configure_step
call :ok

echo.
echo %W%All done.%N%
echo.
echo Next: gcloud init ^&^& gws auth setup
echo Tip: use rtk, rg, fd for agent-friendly commands.
echo.
pause
exit /b 0

:step
set /a STEP+=1
<nul set /p "=%B%[%STEP%/%TOTAL%]%N% %~1... "
goto :eof

:ok
echo %G%OK%N%
goto :eof

:fail
echo %R%FAIL%N%
goto :eof

:skip
echo %Y%SKIP%N% %~1
goto :eof

:winget_step
call :winstall Git.Git
call :winstall OpenJS.NodeJS.LTS
call :winstall Python.Python.3.14
call :winstall Microsoft.PowerShell
call :winstall Microsoft.VisualStudioCode
call :winstall SST.opencode
goto :eof

:winstall
winget list --id "%~1" --accept-source-agreements >nul 2>nul
if %errorlevel% equ 0 exit /b 0
winget install --id "%~1" --silent --accept-package-agreements --accept-source-agreements >nul 2>nul
exit /b 0

:scoop_step
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command scoop -ea 0) { exit 0 }; Invoke-Expression (Invoke-RestMethod https://get.scoop.sh); exit 0"
goto :eof

:scoop_apps_step
powershell -NoProfile -ExecutionPolicy Bypass -Command "scoop bucket list | findstr extras >nul; if ($LASTEXITCODE -ne 0) { scoop bucket add extras }"
for %%p in (gcloud ripgrep fd jq yq bat gh shellcheck shfmt) do (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command %%p -ea 0) { exit 0 }; $null = scoop install %%p 2>&1; exit 0"
)
goto :eof

:rtk_step
if exist "%RTK_DIR%\rtk.exe" exit /b 0
if not exist "%RTK_DIR%" mkdir "%RTK_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$wc = New-Object Net.WebClient;" ^
  "try { $wc.DownloadFile('%RTK_URL%', '%TEMP%\rtk.zip') } catch { exit 1 };" ^
  "try { Expand-Archive '%TEMP%\rtk.zip' '%RTK_DIR%' -Force } catch { exit 1 };" ^
  "Remove-Item '%TEMP%\rtk.zip' -Force -ea 0;" ^
  "$p = [Environment]::GetEnvironmentVariable('Path','User');" ^
  "if ($p -notlike '*\.local\bin*') { [Environment]::SetEnvironmentVariable('Path',$p+';%RTK_DIR%','User') }"
goto :eof

:npm_step
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command pnpm -ea 0) { exit 0 }; $null = npm install -g pnpm 2>&1; exit 0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command gws -ea 0) { exit 0 }; $null = npm install -g @googleworkspace/cli 2>&1; exit 0"
goto :eof

:vscode_step
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$c = @('%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd','%ProgramFiles%\Microsoft VS Code\bin\code.cmd','%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd') |? { Test-Path $_ } | select -First 1;" ^
  "if (-not $c) { exit 0 };" ^
  "if (@(& $c --list-extensions 2>$null) -contains 'sst-dev.opencode') { exit 0 };" ^
  "$null = & $c --install-extension sst-dev.opencode 2>&1; exit 0"
goto :eof

:verify_step
set "TOOLS=code opencode gcloud node pnpm rg fd jq yq bat gh shellcheck shfmt rtk gws python pwsh"
set "FAILED="
set "RP=%RTK_DIR%"
for %%t in (%TOOLS%) do (
  where %%t >nul 2>nul || if exist "%RP%\%%t.exe" (cd .) else set "FAILED=!FAILED! %%t"
)
if defined FAILED (
  echo.
  echo %Y%!  Not found:!FAILED!%N%
  echo %Y%   Open a new terminal and try again.%N%
)
goto :eof

:configure_step
if not exist "%RTK_DIR%\rtk.exe" exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $null = & '%RTK_DIR%\rtk.exe' init -g --opencode 2>&1 } catch { }"
goto :eof

:uninstall
echo.
echo %W%Uninstalling tools...%N%
echo.
call :step "Uninstalling npm packages"
powershell -NoProfile -ExecutionPolicy Bypass -Command "@('pnpm','@googleworkspace/cli') | %% { $null = npm uninstall -g $_ 2>&1 }"
call :ok
call :step "Uninstalling Scoop packages"
powershell -NoProfile -ExecutionPolicy Bypass -Command "@('gcloud','ripgrep','fd','jq','yq','bat','gh','shellcheck','shfmt') | %% { $null = scoop uninstall $_ 2>&1 }"
call :ok
call :step "Uninstalling winget packages"
for %%p in (SST.opencode Google.CloudSDK) do winget uninstall --id %%p --silent --accept-source-agreements >nul 2>nul
call :ok
call :step "Removing rtk"
if exist "%RTK_DIR%\rtk.exe" del "%RTK_DIR%\rtk.exe"
call :ok
echo.
echo %W%Uninstall complete.%N%
echo.
pause
exit /b 0
