@echo off
setlocal

echo ================================================================
echo Stopping Windows Update related services...
echo ================================================================

:: Stop critical services (continue even if some fail)
net stop wuauserv /y
net stop bits /y
net stop cryptsvc /y
net stop msiserver /y

echo.
echo ================================================================
echo Processing C:\Windows\SoftwareDistribution ...
echo ================================================================

set "TARGET=C:\Windows\SoftwareDistribution"

:: If directory exists, try to delete it
if exist "%TARGET%\" (
    echo [INFO] Directory "%TARGET%" found. Deleting...
    rd /s /q "%TARGET%" 2>nul
    if exist "%TARGET%\" (
        echo [WARN] Normal deletion failed. Forcibly taking ownership and retrying...
        attrib -s -h -r "%TARGET%" /s /d 2>nul
        takeown /f "%TARGET%" /r /d Y >nul 2>&1
        icacls "%TARGET%" /grant Administrators:F /t >nul 2>&1
        rd /s /q "%TARGET%" 2>nul
    )
)

:: If anything remains (file or folder), force remove
if exist "%TARGET%" (
    echo [INFO] Cleaning up residual file/directory...
    del /f /q "%TARGET%" 2>nul
    rd /s /q "%TARGET%" 2>nul
)

:: Verify the path is fully cleared
if exist "%TARGET%" (
    echo [ERROR] Failed to clear "%TARGET%". It may be in use by a process.
    echo Please try running this script in Safe Mode.
    pause
    exit /b 1
)

:: Create a 0-byte empty file
echo [INFO] Creating 0-byte empty file: %TARGET%
fsutil file createnew "%TARGET%" 0 >nul 2>&1

:: Verify it's a file, not a directory
if exist "%TARGET%\" (
    echo [ERROR] Creation failed: "%TARGET%" is still a directory!
    pause
    exit /b 2
)

if exist "%TARGET%" (
    echo.
    echo ================================================================
    echo  SUCCESS! Created 0-byte empty file:
    echo     %TARGET%
    echo.
    echo Note: Windows Update will be unable to cache updates at this path.
    echo To restore Windows Update, manually delete this file and restart services.
    echo ================================================================
) else (
    echo.
    echo [ERROR] Failed to create the empty file. Possible reasons:
    echo   - Insufficient privileges (run as Administrator)
    echo   - Disk write protection
    echo   - Antivirus software blocking access
    pause
    exit /b 3
)

pause
endlocal