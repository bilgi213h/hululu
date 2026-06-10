@echo off
title Discord Connection Test
chcp 65001 >nul

set "WEBHOOK=https://discord.com/api/webhooks/1514159972081074298/mKZ8mYuuUM_c_PN77hBGFX1AhfesXzh7NSi4XTaKkFfM0UlIdw3HSbAJjbqxLepeAdqa"

:: Bilgileri Topla
for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"
for /f "tokens=*" %%b in ('curl -s https://api.ipify.org') do set "IP=%%b"

:: JSON Gönderimi (Kaçış karakterleri optimize edildi)
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"**✅ Baglanti Basarili!**\\n**Bilgisayar:** %HOST%\\n**IP Adresi:** %IP%\"}" "%WEBHOOK%"

echo.
echo Islem tamamlandi. Discord kanalini kontrol et.
pause
