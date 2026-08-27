# 📋 MASTER CHECKLIST DEPLOYMENT - ENTERTAINMENT AI ASSISTANT V1 (MRS. AFNY MARKETING)

Dokumen ini adalah **Master Checklist Deployment Lengkap dari NOL** (mulai dari Reinstall OS VPS Ubuntu 22.04, Setup Git, Instalasi aaPanel/Docker, SSL HTTPS & Static Assets, hingga Bot Telegram Aktif).

Gunakan fitur checklist markdown (`- [x]`) untuk menandai setiap langkah yang selesai!

---

## 📌 TAHAP 0: REINSTALL OS VPS (FRESH START 0)

- [ ] **0.1. Reinstall OS VPS di Jagoan Hosting**
  - Login ke Member Area Jagoan Hosting (`member.jagoanhosting.com`).
  - Masuk ke **Services** -> Pilih VPS Anda.
  - Klik **Reinstall OS** -> Pilih **Ubuntu 22.04 LTS**.
  - Masukkan password root baru & simpan.
  - Tunggu 3–5 menit hingga status VPS `Running`.

- [ ] **0.2. Connect SSH Pertama Kali dari Laptop**
  - Buka Terminal / PowerShell di laptop:
    ```bash
    ssh root@IP_VPS_ANDA
    ```
  - Masukkan password root VPS baru Anda.

---

## 📌 TAHAP 1: SETUP GIT REPOSITORY (LAPTOP ↔ GITHUB)

- [ ] **1.1. Buat Repository di GitHub**
  - Buka [GitHub.com](https://github.com) -> Klik **New Repository**.
  - Nama Repo: `entertainment-ai-bot` (set ke **Private** atau **Public**).
  - Biarkan: `Add README` (Off), `Add .gitignore` (No .gitignore).
  - Klik **Create repository**. Salin URL repo Anda.

- [ ] **1.2. Push Kodingan dari Laptop ke GitHub**
  - Buka Terminal / PowerShell di laptop Anda di folder project:
    ```bash
    git init
    git branch -M main
    git add .
    git commit -m "feat: complete entertainment ai assistant with mrs afny assets & knowledge"
    git remote add origin https://github.com/USERNAME_ANDA/entertainment-ai-bot.git
    git push -u origin main
    ```

---

## 📌 TAHAP 2: INSTALASI AAPANEL & DOCKER DI VPS

- [ ] **2.1. Perintah Instalasi aaPanel di Ubuntu 22.04**
  - Copy-paste perintah berikut di Terminal VPS:
    ```bash
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
    ```
  - Saat ada pertanyaan `Do you want to install aaPanel to the /www directory now?(y/n):`, ketik **`y`** lalu tekan **Enter**.
  - Tunggu 2–4 menit hingga proses instalasi selesai.

- [ ] **2.2. Catat Informasi Login aaPanel**
  - Di akhir instalasi terminal, aaPanel akan menampilkan informasi login.
  - **Catat / Copy** URL Internet Address, Username, dan Password tersebut.

- [ ] **2.3. Login & Install Software di aaPanel App Store**
  - Buka URL aaPanel Internet Address di browser laptop Anda.
  - Masukkan Username & Password aaPanel Anda.
  - Buka menu **App Store** -> Install **Docker Manager** & **Nginx**.

- [ ] **2.4. (Alternatif 1-Line) Install Docker Murni via Terminal**
  - Jika tanpa UI aaPanel, jalankan di terminal VPS:
    ```bash
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
    ```

- [ ] **2.5. Clone Proyek dari GitHub ke /www/wwwroot**
  - Jalankan di Terminal VPS:
    ```bash
    cd /www/wwwroot
    git clone https://github.com/USERNAME_ANDA/entertainment-ai-bot.git
    cd /www/wwwroot/entertainment-ai-bot
    chmod +x deploy.sh
    ```

---

## 📌 TAHAP 3: POINTING DOMAIN, ENVIRONMENT & SSL

- [ ] **3.1. Pointing A Record DNS Domain**
  - Buka DNS Manager domain Anda (Cloudflare / Namecheap / Rumahweb / dll).
  - Tambahkan A Record: Subdomain `n8n` -> Target **IP Public VPS** Anda.

- [ ] **3.2. Buat & Edit File `.env` di VPS**
  - Jalankan di Terminal VPS:
    ```bash
    cd /www/wwwroot/entertainment-ai-bot
    cp .env.example .env
    nano .env
    ```
  - Isi variabel konfigurasi:
    - `N8N_HOST=n8n.domainanda.com`
    - `POSTGRES_USER=elgroup_user`
    - `POSTGRES_PASSWORD=PasswordAman123!`
    - `TELEGRAM_BOT_TOKEN=8924197987:AAEcQKF28QNMZgxV4tkU0SCb_RMonMxEynk`
    - `OPENAI_API_KEY=sk-proj-xxxx...`
    - `ADMIN_TELEGRAM_ID=6576926570`

- [ ] **3.3. Set Domain Nginx di VPS**
  - Edit file Nginx:
    ```bash
    nano nginx/conf.d/n8n.conf
    ```
  - Ganti `n8n.madamafni.com` dengan domain Anda.

- [ ] **3.4. Generate Sertifikat SSL Gratis (Certbot)**
  - Jalankan di Terminal VPS:
    ```bash
    apt update && apt install -y certbot
    certbot certonly --standalone -d n8n.domainanda.com
    ```

---

## 📌 TAHAP 4: MENJALANKAN DOCKER SERVICE

- [ ] **4.1. Start Container Docker**
  - Jalankan di VPS:
    ```bash
    cd /www/wwwroot/entertainment-ai-bot
    docker compose up -d
    ```

- [ ] **4.2. Cek Status Container**
  - Periksa status:
    ```bash
    docker compose ps
    ```
  - Pastikan `entertainment_db`, `entertainment_n8n`, dan `entertainment_nginx` berstatus **Up**.

---

## 📌 TAHAP 5: SETUP N8N & WORKFLOWS DI BROWSER

- [ ] **5.1. Buka n8n & Register Akun Admin Baru**
  - Akses `https://n8n.domainanda.com` di browser laptop.
  - Isi Form **Set up owner account** (Email, Nama, Password).

- [ ] **5.2. Import Workflow JSON**
  - Klik menu **Workflows** -> **Import from File**.
  - Pilih `workflows/master_bot_workflow.json` (All-in-One Master Workflow).

- [ ] **5.3. Menambahkan Credentials**
  - PostgreSQL: Host `postgres`, DB `elgroup_db`, User `elgroup_user`, Pass (dari `.env`), Port `5432`.
  - OpenAI / Groq: Masukkan API Key.
  - Telegram API: Masukkan `TELEGRAM_BOT_TOKEN`.

- [ ] **5.4. Aktifkan Workflow**
  - Buka workflow -> Geser toggle **Active** ke **ON** (Warna Hijau).

---

## 📌 TAHAP 6: SET TELEGRAM WEBHOOK & TESTING

- [ ] **6.1. Set Telegram Webhook**
  - Buka URL ini di browser:
    ```text
    https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/setWebhook?url=https://n8n.domainanda.com/webhook/telegram-webhook
    ```
  - Pastikan muncul respon `{"ok": true, "result": true}`.

- [ ] **6.2. Uji Coba (Testing) Bot**
  - Test `/start` di Telegram -> Keyboard menu resmi muncul.
  - Test `💎 Price List EL` -> Muncul pilihan 9 cabang & foto pricelist.
  - Test `🎫 Barcode Masuk` -> Cek barcode harian (expired pukul 02.00 WIB).
  - Test AI Knowledge: *"Jam buka El Norte jam berapa?"* & *"Ada paket karaoke apa saja di El Centro?"*.
  - Test Booking Handover ke Mrs. Afny.
  - Test Admin Command: `/updatebarcode`.
