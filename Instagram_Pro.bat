@echo off
setlocal enabledelayedexpansion
color 0A

echo ===================================================
echo           Instagram Tools Launcher
echo ===================================================
echo.

:: Check if running as administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    color 0C
    echo Administrative privileges required...
    echo Requesting administrative privileges...
    
    :: Create a temporary VBS script to request elevation
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Check Windows version
ver | findstr /i "10\." > nul
if %errorlevel% equ 0 (
    set "WINDOWS_VERSION=10"
)
ver | findstr /i "11\." > nul
if %errorlevel% equ 0 (
    set "WINDOWS_VERSION=11"
    echo Windows 11 detected - using special compatibility mode.
)

:: Move to the InstagramTools folder
if exist "%~dp0InstagramTools" (
    cd /d "%~dp0InstagramTools"
) else (
    color 0C
    echo ERROR: InstagramTools folder not found!
    echo Make sure the InstagramTools folder exists in the same directory as this batch file.
    echo.
    pause
    exit /B 1
)

:: Windows 11 specific check for PYD files
if "!WINDOWS_VERSION!"=="11" (
    echo Checking compiled modules for Windows 11 compatibility...
    if not exist "instagram_tools.cp313-win_amd64.pyd" (
        color 0E
        echo Warning: Compiled module for Instagram tools not found or not compatible with Windows 11.
        echo This might cause issues when running the application.
        echo.
        timeout /t 3 >nul
    )
)

:: Check if Python 3.13.2 is installed
echo Checking Python version...
python --version 2>nul | findstr /C:"Python 3.13.2" >nul
if %errorlevel% neq 0 (
    color 0E
    echo Python 3.13.2 not found. 
    echo.
    
    set /p choice="Would you like to download Python 3.13.2 now? (Y/N): "
    if /i "!choice!"=="Y" (
        echo.
        echo Downloading Python 3.13.2...
        
        :: Create temp directory for download
        mkdir "%temp%\python_download" 2>nul
        cd /d "%temp%\python_download"
        
        :: Download Python installer with progress
        echo Downloading Python installer...
        echo This may take a few minutes depending on your internet connection...
        echo.
        
        :: Create a PowerShell script to download with progress
        echo $url = 'https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe' > "%temp%\download.ps1"
        echo $output = 'python-installer.exe' >> "%temp%\download.ps1"
        echo $start_time = Get-Date >> "%temp%\download.ps1"
        echo. >> "%temp%\download.ps1"
        echo $wc = New-Object System.Net.WebClient >> "%temp%\download.ps1"
        echo $wc.DownloadFileAsync($url, $output) >> "%temp%\download.ps1"
        echo. >> "%temp%\download.ps1"
        echo $prevProgress = 0 >> "%temp%\download.ps1"
        echo. >> "%temp%\download.ps1"
        echo Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action { >> "%temp%\download.ps1"
        echo     $progress = $EventArgs.ProgressPercentage >> "%temp%\download.ps1"
        echo     if ($progress -ge $prevProgress + 10) { >> "%temp%\download.ps1"
        echo         $prevProgress = $progress - ($progress %% 10) >> "%temp%\download.ps1"
        echo         Write-Host "Download progress: $prevProgress%%" >> "%temp%\download.ps1"
        echo     } >> "%temp%\download.ps1"
        echo } | Out-Null >> "%temp%\download.ps1"
        echo. >> "%temp%\download.ps1"
        echo Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action { >> "%temp%\download.ps1"
        echo     $elapsed = ((Get-Date) - $start_time).TotalSeconds >> "%temp%\download.ps1"
        echo     Write-Host "Download completed in $elapsed seconds." >> "%temp%\download.ps1"
        echo     [System.Environment]::Exit(0) >> "%temp%\download.ps1"
        echo } | Out-Null >> "%temp%\download.ps1"
        echo. >> "%temp%\download.ps1"
        echo while ($true) { Start-Sleep -Milliseconds 100 } >> "%temp%\download.ps1"
        
        :: Run the PowerShell download script
        powershell -ExecutionPolicy Bypass -File "%temp%\download.ps1"
        del "%temp%\download.ps1"
        
        if not exist "python-installer.exe" (
            color 0C
            echo Download failed. Please download and install Python 3.13.2 manually from https://www.python.org/downloads/
            pause
            exit /B 1
        )
        
        color 0A
        echo.
        echo Download completed successfully!
        echo.
        echo Installing Python 3.13.2...
        echo This may take a few minutes...
        echo.
        
        :: Run installer with wait and visible progress - special settings for Windows 11
        if "!WINDOWS_VERSION!"=="11" (
            echo Using Windows 11 specific installation options...
            start /wait python-installer.exe /passive InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1 CompileAll=1
        ) else (
            start /wait python-installer.exe /passive InstallAllUsers=1 PrependPath=1 Include_test=0
        )
        
        :: Special fix for Windows 11 - reload PATH environment
        if "!WINDOWS_VERSION!"=="11" (
            echo Refreshing PATH environment for Windows 11...
            for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH') do set "SYSPATH=%%b"
            for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH') do set "USERPATH=%%b"
            set "PATH=!SYSPATH!;!USERPATH!"
        )
        
        :: Verify installation success
        python --version 2>nul | findstr /C:"Python 3.13.2" >nul
        if %errorlevel% neq 0 (
            color 0C
            echo.
            echo Python installation may have failed or Python was not added to PATH correctly.
            echo.
            echo Let's try to locate Python manually...
            
            for %%d in (C D E F G) do (
                if exist "%%d:\Program Files\Python313\python.exe" (
                    echo Found Python at %%d:\Program Files\Python313\
                    set "PYTHON_PATH=%%d:\Program Files\Python313\python.exe"
                    goto :PYTHON_FOUND
                )
                if exist "%%d:\Program Files (x86)\Python313\python.exe" (
                    echo Found Python at %%d:\Program Files (x86)\Python313\
                    set "PYTHON_PATH=%%d:\Program Files (x86)\Python313\python.exe"
                    goto :PYTHON_FOUND
                )
                if exist "%%d:\Python313\python.exe" (
                    echo Found Python at %%d:\Python313\
                    set "PYTHON_PATH=%%d:\Python313\python.exe"
                    goto :PYTHON_FOUND
                )
            )
            
            color 0C
            echo.
            echo Could not find Python 3.13.2 installation.
            echo Please install Python 3.13.2 manually and ensure it's added to PATH.
            echo Then run this batch file again.
            pause
            exit /B 1
            
            :PYTHON_FOUND
            echo Using Python from: !PYTHON_PATH!
            
            :: Use the found Python path instead of relying on PATH
            set "PYTHON_CMD=!PYTHON_PATH!"
        ) else (
            set "PYTHON_CMD=python"
        )
        
        :: Clean up
        cd /d "%~dp0InstagramTools"
        rmdir /S /Q "%temp%\python_download"
        
        color 0A
        echo.
        echo Python 3.13.2 installed successfully!
        echo Press any key to continue...
        pause > nul
    ) else (
        color 0E
        echo.
        echo Please install Python 3.13.2 manually from https://www.python.org/downloads/
        echo Make sure to check "Add Python to PATH" during installation.
        echo Then run this batch file again.
        pause
        exit /B 1
    )
) else (
    set "PYTHON_CMD=python"
)

color 0A
echo Python 3.13.2 found!
echo.

:: Check if requirements.txt exists and install dependencies
if exist "requirements.txt" (
    echo Checking and installing required dependencies...
    
    :: Use timeout to ensure pip is available after Python installation (especially on Windows 11)
    timeout /t 2 >nul
    
    :: Windows 11 specific handling
    if "!WINDOWS_VERSION!"=="11" (
        echo Using Windows 11 specific pip installation...
        
        :: Try to install dependencies with different methods for Windows 11
        echo Upgrading pip...
        !PYTHON_CMD! -m ensurepip --upgrade
        !PYTHON_CMD! -m pip install --upgrade pip
        
        :: Install all requirements with progress indication - one by one for Windows 11
        echo Installing required packages individually (for Windows 11 compatibility)...
        
        for /f "tokens=1,2 delims==" %%a in (requirements.txt) do (
            echo Installing %%a...
            !PYTHON_CMD! -m pip install %%a==%%b
            if !errorlevel! neq 0 (
                echo Retrying with alternative method...
                !PYTHON_CMD! -m pip install %%a
            )
        )
    ) else (
        :: Standard installation for other Windows versions
        echo Installing dependencies...
        !PYTHON_CMD! -m pip install --upgrade pip
        !PYTHON_CMD! -m pip install -r requirements.txt
        
        if !errorlevel! neq 0 (
            color 0E
            echo.
            echo There was an issue installing dependencies.
            echo Trying alternative approach...
            
            :: Try with direct pip command
            pip install -r requirements.txt
        )
    )
    
    :: Verify key modules are installed for Instagram tools
    echo Verifying key modules...
    !PYTHON_CMD! -c "import instaloader" 2>nul
    if !errorlevel! neq 0 (
        color 0E
        echo.
        echo Warning: Instaloader module not properly installed.
        echo Installing directly...
        !PYTHON_CMD! -m pip install instaloader==4.10.0
    )
    
    !PYTHON_CMD! -c "import telegram" 2>nul
    if !errorlevel! neq 0 (
        color 0E
        echo.
        echo Warning: Telegram module not properly installed.
        echo Installing directly...
        !PYTHON_CMD! -m pip install python-telegram-bot==13.15
    )
) else (
    color 0E
    echo Warning: requirements.txt not found. Dependencies might not be installed correctly.
    echo.
    
    :: Install critical dependencies directly
    echo Installing critical dependencies directly...
    !PYTHON_CMD! -m pip install instaloader==4.10.0 python-telegram-bot==13.15
    timeout /t 3 >nul
)

:: Check if main.py exists
if not exist "main.py" (
    color 0C
    echo ERROR: main.py not found in the InstagramTools folder!
    echo Please make sure all files are in the correct location.
    pause
    exit /B 1
)

:: Windows 11 specific setup before running
if "!WINDOWS_VERSION!"=="11" (
    echo Setting up Windows 11 compatibility environment...
    
    :: Fix common Windows 11 Python issues with environment variables
    set "PYTHONIOENCODING=utf-8"
    set "PYTHONUTF8=1"
    set "PYTHONDONTWRITEBYTECODE=1"
    
    :: Set specific environment variables to help with module loading
    set "PYTHONPATH=%CD%"
    
    :: Disable Windows 11 security measures that might interfere
    echo Temporarily adjusting Python environment for Windows 11...
)

:: Run the Instagram Tools with error handling
echo Starting Instagram Tools...
echo.

:: Run with specific command for Windows 11 compatibility if needed
if "!WINDOWS_VERSION!"=="11" (
    :: Create a temporary file to capture any errors
    !PYTHON_CMD! -B main.py 2>python_error.log
) else (
    :: Regular execution for other Windows versions
    !PYTHON_CMD! main.py 2>python_error.log
)

:: Check if there was an error
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo An error occurred while running the program.
    
    :: Check common errors
    type python_error.log | findstr /C:"ModuleNotFoundError" >nul
    if %errorlevel% equ 0 (
        echo.
        echo Missing module detected. Attempting to fix...
        
        :: Try to extract module name from error log
        for /f "tokens=*" %%a in ('type python_error.log ^| findstr /C:"ModuleNotFoundError"') do (
            set "ERROR_LINE=%%a"
        )
        
        echo !ERROR_LINE! | findstr /C:"No module named" >nul
        if %errorlevel% equ 0 (
            for /f "tokens=4 delims='" %%m in ("!ERROR_LINE!") do (
                set "MISSING_MODULE=%%m"
            )
            
            echo.
            echo Attempting to install missing module: !MISSING_MODULE!
            !PYTHON_CMD! -m pip install !MISSING_MODULE!
            
            echo.
            echo Retrying to run the program...
            !PYTHON_CMD! main.py
            
            if %errorlevel% neq 0 (
                echo Program still failed to start.
                echo.
                echo If you're on Windows 11, try these steps manually:
                echo 1. Open Command Prompt as administrator
                echo 2. Navigate to the InstagramTools folder
                echo 3. Run: python -m pip install --upgrade pip
                echo 4. Run: python -m pip install -r requirements.txt
                echo 5. Run: python main.py
            )
        ) else (
            echo.
            echo Could not identify the missing module.
            echo Error details:
            type python_error.log
        )
    ) else if "!WINDOWS_VERSION!"=="11" (
        :: For Windows 11, check for common import errors
        type python_error.log | findstr /C:"ImportError" >nul
        if %errorlevel% equ 0 (
            echo.
            echo Import error detected on Windows 11.
            echo This is likely due to a Python module path issue on Windows 11.
            echo.
            echo Attempting Windows 11 specific fix...
            
            :: Create a special startup script
            echo import sys > win11_starter.py
            echo import os >> win11_starter.py
            echo sys.path.insert(0, os.path.abspath('.')) >> win11_starter.py
            echo os.environ['PYTHONPATH'] = os.path.abspath('.') >> win11_starter.py
            echo exec(open('main.py').read()) >> win11_starter.py
            
            echo.
            echo Trying alternative startup method for Windows 11...
            !PYTHON_CMD! win11_starter.py
            
            if exist "win11_starter.py" del win11_starter.py
        ) else (
            echo.
            echo Error details:
            type python_error.log
        )
    ) else (
        echo.
        echo Error details:
        type python_error.log
    )
)

:: Clean up error log
if exist "python_error.log" del python_error.log

echo.
pause
exit /B 0 