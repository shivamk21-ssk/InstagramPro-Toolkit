@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo           Instagram Tools Launcher
echo ===================================================
echo.

:: Check if running as administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    echo Administrative privileges required...
    echo Requesting administrative privileges...
    
    :: Create a temporary VBS script to request elevation
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Move to the InstagramTools folder
cd /d "%~dp0InstagramTools"

:: Check if Python 3.13.2 is installed
echo Checking Python version...
python --version 2>nul | findstr /C:"Python 3.13.2" >nul
if %errorlevel% neq 0 (
    echo Python 3.13.2 not found. 
    echo.
    
    set /p choice="Would you like to download Python 3.13.2 now? (Y/N): "
    if /i "!choice!"=="Y" (
        echo.
        echo Downloading Python 3.13.2...
        
        :: Create temp directory for download
        mkdir "%temp%\python_download" 2>nul
        cd /d "%temp%\python_download"
        
        :: Download Python installer
        echo Downloading Python installer...
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe', 'python-installer.exe')"
        
        if not exist "python-installer.exe" (
            echo Download failed. Please download and install Python 3.13.2 manually from https://www.python.org/downloads/
            pause
            exit /B 1
        )
        
        echo Installing Python 3.13.2...
        start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
        
        :: Clean up
        cd /d "%~dp0"
        rmdir /S /Q "%temp%\python_download"
        
        echo.
        echo Please restart this batch file after installation completes.
        pause
        exit /B 0
    ) else (
        echo.
        echo Please install Python 3.13.2 manually from https://www.python.org/downloads/
        echo Then run this batch file again.
        pause
        exit /B 1
    )
)

echo Python 3.13.2 found!
echo.

:: Run the Instagram Tools
echo Starting Instagram Tools...
python main.py

echo.
pause
exit /B 0 