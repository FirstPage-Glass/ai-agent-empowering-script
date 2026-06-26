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
set "TOTAL=10"

rem Parse arguments — --quiet/-q suppresses output; pass "uninstall" to uninstall
set "QUIET="
for %%a in (%*) do (
  if /i "%%a"=="--quiet" set "QUIET=1"
  if /i "%%a"=="-q" set "QUIET=1"
  if /i "%%a"=="uninstall" set "MODE=uninstall"
)

if defined MODE goto :uninstall

rem Output redirection helpers
if defined QUIET (
  set "PS_REDIR=*>$null"
  set "WINGET_FLAGS=--silent"
  set "WINGET_REDIR=>nul 2>nul"
) else (
  set "PS_REDIR="
  set "WINGET_FLAGS="
  set "WINGET_REDIR="
)

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

call :step "Installing opencode"
call :install_opencode_ext
call :ok

call :step "Installing npm packages"
call :npm_step
call :ok

call :step "Installing VS Code extension"
call :vscode_step
call :ok

call :step "Verifying installations"
call :verify_step
if %errorlevel% neq 0 (call :fail) else (call :ok)

call :step "Configuring tools"
call :configure_step
call :ok

call :step "Installing skills"
call :install_skills
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
goto :eof

:winstall
winget list --id "%~1" --accept-source-agreements !WINGET_REDIR!
if %errorlevel% equ 0 exit /b 0
winget install --id "%~1" !WINGET_FLAGS! --accept-package-agreements --accept-source-agreements !WINGET_REDIR!
exit /b 0

:install_opencode_ext
rem Download opencode CLI directly from GitHub releases to .local\bin
rem Winget SST.opencode is a portable package with unreliable PATH handling
set "OPENCODE_URL=https://github.com/anomalyco/opencode/releases/latest/download/opencode-windows-x64.zip"
if exist "%RTK_DIR%\opencode.exe" exit /b 0
if not exist "%RTK_DIR%" mkdir "%RTK_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$wc = New-Object Net.WebClient;" ^
  "try { $wc.DownloadFile('%OPENCODE_URL%', '%TEMP%\opencode.zip') } catch { exit 1 };" ^
  "try { Expand-Archive '%TEMP%\opencode.zip' '%RTK_DIR%' -Force } catch { exit 1 };" ^
  "Remove-Item '%TEMP%\opencode.zip' -Force -ea 0;" ^
  "$p = [Environment]::GetEnvironmentVariable('Path','User');" ^
  "if ($p -notlike '*\.local\bin*') { [Environment]::SetEnvironmentVariable('Path',$p+';%RTK_DIR%','User') }"
goto :eof

:scoop_step
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command scoop -ea 0) { exit 0 }; Invoke-Expression (Invoke-RestMethod https://get.scoop.sh); exit 0"
goto :eof

:scoop_apps_step
pwsh -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User')+';'+[Environment]::GetEnvironmentVariable('Path','Machine');" ^
  "$env:Path=$p;" ^
  "scoop bucket list | findstr extras | Out-Null;" ^
  "if ($LASTEXITCODE -ne 0) { scoop bucket add extras }"
for %%p in (gcloud ripgrep fd jq yq bat gh shellcheck shfmt) do (
  pwsh -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command %%p -ea 0) { exit 0 }; scoop install --no-hash-check %%p !PS_REDIR!; exit 0"
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
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command pnpm -ea 0) { exit 0 }; npm install -g pnpm !PS_REDIR!; exit 0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command gws -ea 0) { exit 0 }; npm install -g @googleworkspace/cli !PS_REDIR!; exit 0"
goto :eof

:vscode_step
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$c = @(^
    '%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd',^
    '%ProgramFiles%\Microsoft VS Code\bin\code.cmd',^
    '%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd'^
  ) |? { Test-Path $_ } | select -First 1;" ^
  "if (-not $c) { exit 0 }; " ^
  "if (@(& $c --list-extensions 2>$null) -contains 'sst-dev.opencode') { exit 0 }; " ^
  "& $c --install-extension sst-dev.opencode !PS_REDIR!; exit 0"
goto :eof

:verify_step
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "UPATH=%%B"
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SPATH=%%B"
rem Append registry paths to current PATH instead of overriding (so install-time additions are preserved)
if defined UPATH if defined SPATH (
  set "PATH=!UPATH!;!SPATH!;!PATH!"
) else if defined UPATH (
  set "PATH=!UPATH!;!PATH!"
) else if defined SPATH (
  set "PATH=!SPATH!;!PATH!"
)
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
  exit /b 1
)
goto :eof

:configure_step
if not exist "%RTK_DIR%\rtk.exe" exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { & '%RTK_DIR%\rtk.exe' init -g --opencode !PS_REDIR! } catch { }"
goto :eof

:install_skills
set "SKILL_DIR=%USERPROFILE%\.config\opencode\skills"
set "SKILL_NAME=email-planner"
set "BASE_URL=https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/skills"
if not exist "%SKILL_DIR%\%SKILL_NAME%\scripts" mkdir "%SKILL_DIR%\%SKILL_NAME%\scripts"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$wc = New-Object Net.WebClient;" ^
  "$wc.DownloadFile('%BASE_URL%/%SKILL_NAME%/SKILL.md', '%SKILL_DIR%\%SKILL_NAME%\SKILL.md');" ^
  "$wc.DownloadFile('%BASE_URL%/%SKILL_NAME%/scripts/email_planner.py', '%SKILL_DIR%\%SKILL_NAME%\scripts\email_planner.py')"
REM Update opencode config to register skills path
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$c='%USERPROFILE%\.config\opencode\opencode.json';" ^
  "$p='%USERPROFILE%\.config\opencode\skills';" ^
  "if (-not (Test-Path $c)) {" ^
  "  @{ '$schema'='https://opencode.ai/config.json'; skills=@{ paths=@($p) } } | ConvertTo-Json -Depth 3 | Set-Content $c -Encoding UTF8;" ^
  "  exit 0" ^
  "};" ^
  "$o = Get-Content $c -Raw | ConvertFrom-Json;" ^
  "if (-not $o.skills) { $o | Add-Member skills @{ paths=@() } -Force };" ^
  "if (-not $o.skills.paths) { $o.skills | Add-Member paths @() -Force };" ^
  "if ($o.skills.paths -notcontains $p) { $o.skills.paths = @($o.skills.paths + @($p) | Select-Object -Unique) };" ^
  "$o | ConvertTo-Json -Depth 3 | Set-Content $c -Encoding UTF8"
goto :eof

:uninstall_skills
set "SKILL_DIR=%USERPROFILE%\.config\opencode\skills"
set "SKILL_NAME=email-planner"
if exist "%SKILL_DIR%\%SKILL_NAME%" rmdir /s /q "%SKILL_DIR%\%SKILL_NAME%"
if exist "%SKILL_DIR%" (rd "%SKILL_DIR%" 2>nul || cd .)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$c='%USERPROFILE%\.config\opencode\opencode.json';" ^
  "$p='%USERPROFILE%\.config\opencode\skills';" ^
  "if (-not (Test-Path $c)) { exit 0 };" ^
  "$o = Get-Content $c -Raw | ConvertFrom-Json;" ^
  "if ($o.skills -and $o.skills.paths) { $o.skills.paths = @($o.skills.paths | Where-Object { $_ -ne $p }) };" ^
  "if ($o.skills -and $o.skills.paths -and @($o.skills.paths).Count -eq 0) { $o.skills.PSObject.Properties.Remove('paths') };" ^
  "if ($o.skills -and $o.skills.PSObject.Properties.Count -eq 0) { $o.PSObject.Properties.Remove('skills') };" ^
  "$o | ConvertTo-Json -Depth 3 | Set-Content $c -Encoding UTF8"
goto :eof

:uninstall
set "TOTAL=5"
echo.
echo %W%Uninstalling tools...%N%
echo.
call :step "Uninstalling npm packages"
powershell -NoProfile -ExecutionPolicy Bypass -Command "@('pnpm','@googleworkspace/cli') | %% { npm uninstall -g $_ !PS_REDIR! }"
call :ok
call :step "Uninstalling Scoop packages"
powershell -NoProfile -ExecutionPolicy Bypass -Command "@('gcloud','ripgrep','fd','jq','yq','bat','gh','shellcheck','shfmt') | %% { scoop uninstall $_ !PS_REDIR! }"
call :ok
call :step "Uninstalling winget packages"
for %%p in (Google.CloudSDK) do winget uninstall --id %%p !WINGET_FLAGS! --accept-source-agreements !WINGET_REDIR!
call :ok
call :step "Removing rtk and opencode"
if exist "%RTK_DIR%\rtk.exe" del "%RTK_DIR%\rtk.exe"
if exist "%RTK_DIR%\opencode.exe" del "%RTK_DIR%\opencode.exe"
call :ok
call :step "Removing skills"
call :uninstall_skills
call :ok
echo.
echo %W%Uninstall complete.%N%
echo.
pause
exit /b 0
