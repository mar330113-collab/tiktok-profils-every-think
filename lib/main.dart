import re
import sys
import time
from datetime import datetime

try:
    import requests
except ImportError:
    print("\033[1;31m[X] مكتبة requests غير مثبتة!")
    sys.exit()

# ألوان الشاشة التكتيكية للمصممين
CYAN = "\033[1;36m"
GREEN = "\033[1;32m"
WHITE = "\033[1;37m"
RED = "\033[1;31m"
YELLOW = "\033[1;33m"

print(CYAN + "=======================================")
print(CYAN + "[+] صائد التواريخ والنك نيم الذكي V10 🔥")
print(CYAN + "[+] مصلح بالكامل لترجمة النك نيم إلى يوزر")
print(CYAN + "=======================================\n" + WHITE)

# الإدخالات الثلاثة المرنة
in_username = input("[*] 1. أدخل يوزر الحساب (اختياري): ").strip()
in_video_url = input("[*] 2. أدخل رابط الفيديو (اختياري): ").strip()
in_nickname = input("[*] 3. أدخل النك نيم / الاسم العادي (اختياري): ").strip()

if not in_username and not in_video_url and not in_nickname:
    print(RED + "\n[X] يا الذهب، لازم تكتب خيار واحد على الأقل!")
    sys.exit()

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept-Language": "ar,en;q=0.9"
}

username = ""

# --- تكتيك الفرز والترجمة الذكية للمدخلات ---

# 1. لو دخلت يوزر مباشر
if in_username:
    username = in_username.replace("@", "")

# 2. لو تركت اليوزر ودخلت بس رابط فيديو
elif in_video_url and "tiktok.com" in in_video_url:
    print(CYAN + "\n[~] رصدت رابط فيديو.. جاري قشط اليوزر منه...")
    try:
        res = requests.get(in_video_url, headers=headers, allow_redirects=True, timeout=10)
        match = re.search(r"@([^/?#]+)", res.url)
        if match:
            username = match.group(1)
    except Exception:
        print(RED + "[X] خلل بالنت أثناء فك الرابط!")
        sys.exit()

# 3. لو تركت اليوزر والرابط ودخلت "بس النك نيم" (هنا اللوفة المصلحة)
elif in_nickname:
    print(CYAN + f"\n[~] رصدت نك نيم [{in_nickname}].. جاري البحث وتحويله لـ يوزر حقيقي...")
    try:
        # استخدام سيرفر وسيط يبحث بالاسم العادي ويطلع اليوزر
        search_url = f"https://countik.com/api/search/user?query={in_nickname}"
        search_res = requests.get(search_url, headers=headers, timeout=10)
        if search_res.status_code == 200:
            users_list = search_res.json().get("users", [])
            if users_list:
                # ياخذ أول يوزر حقيقي يطابق البحث
                username = users_list[0].get("username", "")
    except Exception:
        pass
    
    # حل احتياطي إذا علق السيرفر الوسيط
    if not username:
        username = in_nickname.replace(" ", "")

# التشييك النهائي
if not username:
    print(RED + "\n[X] تعذر استخراج أو ترجمة اليوزر! تأكد من الإدخال.")
    sys.exit()

print(CYAN + f"[~] جاري قشط البيانات للحساب الحقيقي المكتشف: @{username}...")
time.sleep(1)

try:
    tiktok_url = f"https://www.tiktok.com/@{username}"
    response = requests.get(tiktok_url, headers=headers, timeout=12)
    
    if response.status_code == 200:
        html = response.text
        
        # قشط البيانات بالتحديث الجديد لتيك توك
        id_match = re.search(r'"id":"(\d+)"', html) or re.search(r'"userId":"(\d+)"', html) or re.search(r'"authorId":"(\d+)"', html)
        nickname_match = re.search(r'"nickname":"([^"]+)"', html) or re.search(r'<title>([^<]+) \(@', html)
        
        followers = re.search(r'"followerCount":(\d+)', html) or re.search(r'"Followers":(\d+)', html)
        following = re.search(r'"followingCount":(\d+)', html) or re.search(r'"Following":(\d+)', html)
        hearts = re.search(r'"heartCount":(\d+)', html) or re.search(r'"Likes":(\d+)', html)
        
        if id_match or nickname_match:
            print(GREEN + "\n[★] تم صيد معلومات الحساب بنجاح طيارة! 😎🚀")
            print(WHITE + "---------------------------------------")
            
            # استخراج النك نيم الحقيقي وتصفيته
            live_nickname = nickname_match.group(1) if nickname_match else "لا يوجد اسم"
            if "(@" in live_nickname: live_nickname = live_nickname.split("(@")[0].strip()
            if '\\u' in live_nickname: live_nickname = live_nickname.encode('utf-8').decode('unicode-escape', errors='ignore')
            
            # طباعة النتائج مصفطة توب
            print(GREEN + "[+] النك نيم الحقيقي بالبروفايل: " + WHITE + f"{live_nickname}")
            print(GREEN + "[+] يوزر الحساب الشخصي: " + YELLOW + f"@{username}")
            print(GREEN + "[+] رابط الحساب المباشر: " + WHITE + f"{tiktok_url}")
            
            # فك تشفير الـ ID والتاريخ الأسطوري مالتك
            if id_match:
                user_id = int(id_match.group(1))
                timestamp = user_id >> 32
                date_created = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')
                print(GREEN + "[+] رقم الـ ID الفريد: " + WHITE + f"{user_id}")
                print(RED + "[🔥] تاريخ إنشاء الحساب: " + WHITE + f"{date_created}")
            
            # الإحصائيات
            f_count = followers.group(1) if followers else "0"
            fl_count = following.group(1) if following else "0"
            h_count = hearts.group(1) if hearts else "0"
            
            print(GREEN + "[+] المتابعين (Followers): " + WHITE + f"{int(f_count):,}" if f_count.isdigit() else f"[+] المتابعين: {f_count}")
            print(GREEN + "[+] اليتابعهم (Following): " + WHITE + f"{int(fl_count):,}" if fl_count.isdigit() else f"[+] اليتابعهم: {fl_count}")
            print(GREEN + "[+] مجموع اللايكات (Likes): " + WHITE + f"{int(h_count):,}" if h_count.isdigit() else f"[+] مجموع اللايكات: {h_count}")
            print(WHITE + "---------------------------------------")
        else:
            print(RED + "\n[X] تيك توك قفل الصفحة تماماً هسة، شغل الـ VPN وجرب فوراً.")
            
    elif response.status_code == 404:
        print(RED + f"\n[X] الحساب @{username} غير موجود أصلاً!")
    else:
        print(RED + "\n[X] تيك توك صك الكود ببلوك، شغل الـ VPN وغير الـ IP.")

except Exception as e:
    print(RED + "\n[X] صار خلل تكتيكي بالاتصال!")

print(CYAN + "\n[+] قفلنا ملف الذكاء المصلح! 🚀🔋") 