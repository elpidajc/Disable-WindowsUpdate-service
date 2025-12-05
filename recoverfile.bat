@echo off
setlocal

echo ================================================================
echo Removing C:\Windows\SoftwareDistribution (if it is a file)...
echo ================================================================

set "TARGET=C:\Windows\SoftwareDistribution"

:: Check if running as administrator
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    pause
    exit /b 1
)

:: Check if the target exists
if not exist "%TARGET%" (
    echo [INFO] No file or directory found at "%TARGET%".
    echo Nothing to remove.
    pause
    exit /b 0
)

:: Check if it's a DIRECTORY → DO NOT DELETE (it's the normal system folder)
if exist "%TARGET%\" (
    echo [INFO] "%TARGET%" is a directory (normal Windows Update cache).
    echo This script only removes the *file* version, not the real folder.
    echo If you want to reset Windows Update, use official methods.
    pause
    exit /b 0
)

:: At this point, it must be a FILE → safe to delete
echo [INFO] Found file: "%TARGET%"
echo Attempting to delete...

del /f /q "%TARGET%" >nul 2>&1

if exist "%TARGET%" (
    echo [ERROR] Failed to delete the file. It may be in use or locked.
    echo Try closing background apps or run in Safe Mode.
    pause
    exit /b 2
) else (
    echo.
    echo ================================================================
    echo ✅ SUCCESS! The file has been deleted:
    echo     %TARGET%
    echo.
    echo You can now restart Windows Update services if needed:
    echo   net start wuauserv
    echo   net start bits
    echo ================================================================
)

pause
endlocal