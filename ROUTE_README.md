# Custom Routing Bash Script

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ![Script Version](https://img.shields.io/badge/version-1.3-blue.svg) ![Bash](https://img.shields.io/badge/shell-bash-informational.svg)

## 🔍 هدف
این اسکریپت ترافیک ورودی روی یک اینترفیس (مثل OpenVPN/WireGuard/SoftEther) را از طریق یک اینترفیس خروجی دلخواه (مثلاً کلاینت‌هایی مثل v2ray، SSTP و غیره) مسیریابی می‌کند. قوانین مسیریابی جداگانه، NAT و جدول سفارشی به صورت امن تنظیم می‌شوند تا ترافیک به‌درستی از مسیر مشخص‌شده عبور کند.

## 📦 پیش‌نیازها
- دسترسی root (یا اجرای با `sudo`)
- ابزارهای نصب‌شده:
  - `ip` (از بسته `iproute2`)
  - `iptables`
- وجود دو اینترفیس شبکه فعال: یکی برای ورودی (`INCOMING`) و دیگری برای خروجی (`DESTINATION`).
- دایرکتوری `/Golden1` (اسکریپت آن را در صورت نبودن می‌سازد) برای ذخیره نسخه‌های بازتولید شونده.

## 🚀 نصب و اجرا
1. فایل را دانلود یا کپی کنید و دسترسی اجرایی بدهید:
   ```bash
mkdir -p /Golden1
cd /Golden1
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/route_a.sh
chmod +x /Golden1/route_a.sh

   ```
2. اسکریپت را اجرا کنید:
   ```bash
   bash /Golden1/route_a.sh
   ```
3. هنگام اجرا:
   - اینترفیس ورودی را انتخاب کنید (پیش‌فرض از جدول مسیریابی پیش‌فرض می‌آید)
   - اینترفیس خروجی را انتخاب کنید (نمی‌تواند همان ورودی باشد)
   - شماره جدول مسیریابی سفارشی را تعیین کنید (پیش‌فرض 1000)
4. اسکریپت قوانین مسیریابی، NAT را تنظیم کرده و فایل قابل بازتولید را در `/Golden1/route_<TABLE>.sh` می‌سازد.

## 🧪 مثال اجرا
```bash
$ sudo ./route_setup.sh
Available incoming interfaces: eth0 wlan0
[INCOMING]: Enter interface name (default eth0): eth0
Available destination interfaces: wlan0
[DESTINATION]: Enter interface name: wlan0
Enter the Value for Routing Table [1000]: 2000

✔ تنظیم جدول مسیریابی سفارشی 2000
✔ فعال‌سازی IPv4 forwarding
✔ اعمال قوانین NAT برای شبکه 192.168.1.0/24 از طریق wlan0
✔ ذخیره اسکریپت بازتولید شونده در /Golden1/route_2000.sh
```

## ⚙️ چک‌لیست عملکردی
- [x] بررسی اجرا به‌صورت root
- [x] اعتبارسنجی اینترفیس‌ها
- [x] استخراج آدرس‌های IPv4 و شبکه /24
- [x] فعال‌سازی IPv4 forwarding
- [x] افزودن مسیرهای سفارشی به جدول انتخابی
- [x] تنظیم قوانین `ip rule`
- [x] پاک‌سازی و تنظیم NAT با `iptables`
- [x] تولید فایل قابل بازتولید

## 🔒 نکات امنیتی
- فقط اسکریپت را در سیستم‌های قابل اعتماد اجرا کنید.
- دایرکتوری `/Golden1` باید مجوزهای مناسب داشته باشد: مثال:
  ```bash
  chmod 700 /Golden1
  ```
- در صورت لاگ‌برداری، اطلاعات حساس (مثل IPها) را محافظت کنید.
- اگر نیاز دارید فقط ترافیک خاص مسیریابی شود، قوانین iptables اضافی اضافه کنید (مبدا/مقصد محدود).

## 🛠️ بهبودهای آینده پیشنهادی
- پشتیبانی از IPv6
- ذخیره‌سازی پیکربندی قبلی قبل از اعمال تغییرات
- رول‌بک اتوماتیک در صورت خطا
- آزمایش و صحت‌سنجی قبل از نوشتن در جدول‌ها

## 📁 فایل‌های تولید شده
- `route_setup.sh` : اسکریپت اصلی قابل اجرا
- `/Golden1/route_<TABLE>.sh` : نسخه ثابت‌شده از پیکربندی برای اجراهای بعدی

## 📝 لایسنس
این پروژه تحت مجوز MIT منتشر می‌شود.
