# 🚀 PANDUAN DEPLOYMENT DARI NOL (FRESH REINSTALL VPS & AAPANEL)

Panduan ini disusun khusus untuk **VPS yang baru saja di-reinstall / reset bersih**, menggunakan **aaPanel** (atau Terminal SSH) untuk meng-clone proyek dari GitHub sampai bot Telegram jalan 100%.

---

## 🔄 0. CARA RESET / REINSTALL OS VPS DI JAGOAN HOSTING

Jika VPS Anda saat ini masih penuh dengan sisa bot lama/file lama yang berat dan ingin di-reset 100% bersih dari panel Jagoan Hosting:

1. **Login Member Area Jagoan Hosting**:
   - Buka URL: `https://member.jagoanhosting.com` (atau client area tempat Anda membeli VPS).
   - Login dengan email dan password akun Anda.

2. **Pilih VPS Anda**:
   - Klik menu **Services** / **Layanan Saya** -> Klik paket **VPS** Anda.

3. **Buka Menu Reinstall OS**:
   - Di dashboard management VPS, cari dan klik tombol **Reinstall OS** (atau **Rebuild Server** / **SolusVM Panel**).

4. **Pilih Operating System (OS)**:
   - Rekomendasi OS: Pilih **Ubuntu 22.04 LTS** atau **Ubuntu 20.04 LTS** (paling stabil untuk Docker & n8n).
   - Masukkan **Password Root Baru** Anda (catat password ini baik-baik).

5. **Eksekusi Reinstall**:
   - Klik tombol **Confirm / Reinstall**.
   - Tunggu proses sekitar **3 - 5 menit** hingga status VPS berubah menjadi **Active / Running**.

6. **Koneksi Pertama Kali**:
   - Buka Terminal / CMD / PuTTY di laptop Anda:
     ```bash
     ssh root@IP_VPS_ANDA
     ```
   - Masukkan password root baru yang baru dibuat.
   - VPS Anda sekarang **100% FRESH & BERSIH!**

---

## 📌 RANGKUMAN ALUR (DARI NOL ➔ OPERASIONAL)

```text
[0] Reinstall OS VPS di Member Area Jagoan Hosting (Ubuntu 22.04 LTS)
       ↓
[1] Connect SSH & Install aaPanel / Docker
       ↓
[2] Clone Project dari GitHub ke VPS (`git clone`)
       ↓
[3] Setup .env & SSL Domain (Certbot)
       ↓
[4] Jalankan Container (`docker compose up -d`)
       ↓
[5] Login n8n, Import Workflows & Set Credentials
       ↓
[6] Set Webhook Telegram
```

---

## 🔹 TAHAP 1: KONEKSI SSH & PERSIAPKAN DOCKER

### Pilihan A: Murni Terminal SSH (Paling Ringan & Diadopsi):
Connect ke VPS via SSH di laptop:
```bash
ssh root@IP_VPS_ANDA
```
Jalankan perintah install Docker 1 baris:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
```

### Pilihan B: Jika Ingin Memakai aaPanel:
1. Install aaPanel di VPS Ubuntu:
   ```bash
   wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
   ```
2. Setelah selesai, buka URL Dashboard aaPanel yang diberikan di terminal.
3. Masuk ke **App Store** di aaPanel -> Install **Docker Manager** & **Nginx**.

---

## 🔹 TAHAP 2: CLONE PROYEK DARI GITHUB KE VPS

Di terminal VPS (atau Terminal aaPanel):

1. Masuk ke direktori `/opt`:
   ```bash
   mkdir -p /opt
   cd /opt
   ```

2. Clone repository Anda dari GitHub:
   ```bash
   git clone https://github.com/USERNAME_ANDA/entertainment-ai-bot.git entertainment-ai
   ```
   *(Masukkan Username & Personal Access Token / Password GitHub Anda jika repository Private)*.

3. Masuk ke folder proyek yang baru di-clone:
   ```bash
   cd /opt/entertainment-ai
   ```

4. Beri izin eksekusi pada script auto deploy:
   ```bash
   chmod +x deploy.sh
   ```

---

## 🔹 TAHAP 3: SETUP FILE `.env` & SERTIFIKAT SSL

1. Buat file `.env` di VPS:
   ```bash
   cp .env.example .env
   nano .env
   ```
   Isi konfigurasi berikut di file `.env`:
   - `N8N_HOST=n8n.domainanda.com` (ganti dengan domain aktual Anda).
   - `POSTGRES_USER=elgroup_user`
   - `POSTGRES_PASSWORD=BuatPasswordDatabaseAman123!`
   - `TELEGRAM_BOT_TOKEN=8924197987:AAEcQKF28QNMZgxV4tkU0SCb_RMonMxEynk`
   - `OPENAI_API_KEY=sk-proj-xxxx...`
   - `ADMIN_TELEGRAM_ID=5437246207`
   *(Simpan: `Ctrl + O`, `Enter`. Keluar: `Ctrl + X`)*.

2. Adjust Nginx Domain Config:
   ```bash
   nano nginx/conf.d/n8n.conf
   ```
   Ganti `n8n.madamafni.com` (ada 2 tempat) menjadi domain Anda (misal `n8n.domainanda.com`).

3. Install Sertifikat SSL (HTTPS) Gratis via Certbot:
   ```bash
   apt update && apt install -y certbot
   certbot certonly --standalone -d n8n.domainanda.com
   ```
   *(Pastikan DNS A Record `n8n.domainanda.com` sudah mengarah ke IP VPS Anda)*.

---

## 🔹 TAHAP 4: JALANKAN CONTAINER DOCKER

Jalankan container dengan 1 perintah:
```bash
docker compose up -d
```

Periksa statusnya:
```bash
docker compose ps
```
> Ketiga service (`entertainment_db`, `entertainment_n8n`, dan `entertainment_nginx`) harus berstatus **Up / Running**.

---

## 🔹 TAHAP 5: CONFIGURASI N8N DI BROWSER

1. Buka browser dan akses: `https://n8n.domainanda.com`
2. Form **Owner Setup**: Isi Email, Nama, dan Password baru Anda -> Klik **Finish Setup**.
3. Menu **Workflows** -> Klik **Import from File** -> Import 5 file JSON dari folder `workflows/`:
   - `1_telegram_router.json`
   - `2_admin_barcode_handler.json`
   - `3_ai_chat_knowledge.json`
   - `4_group_mention_handler.json`
   - `5_booking_lead_notifier.json`
4. Menu **Credentials** -> **Add Credential**:
   - **PostgreSQL**: Host: `postgres`, DB: `elgroup_db`, User: `elgroup_user`, Password: (Password DB di `.env`), Port: `5432`.
   - **OpenAI**: Masukkan `OPENAI_API_KEY`.
   - **Telegram API**: Masukkan `TELEGRAM_BOT_TOKEN`.
5. Aktifkan kelima workflow (Geser Toggle **Active** ke **ON** / Warna Hijau).

---

## 🔹 TAHAP 6: SET TELEGRAM WEBHOOK

Buka tab baru di browser Anda dan jalankan link ini:
```text
https://api.telegram.org/bot8924197987:AAEcQKF28QNMZgxV4tkU0SCb_RMonMxEynk/setWebhook?url=https://n8n.domainanda.com/webhook/telegram-webhook
```

Jika muncul `{"ok": true, "result": true}`, artinya Bot Telegram Anda **100% SUDAH AKTIF DAN SIAP DIGUNAKAN!** 🎉

---

## 🔄 CARA UPDATE DI MASA DEPAN (SETELAH HARI DEPLOYMENT)

Jika suatu saat Anda mengubah prompt AI / kodingan di laptop:

1. **Di Laptop**:
   ```bash
   git add .
   git commit -m "update bot"
   git push origin main
   ```
2. **Di VPS / Terminal aaPanel**:
   ```bash
   cd /opt/entertainment-ai
   ./deploy.sh
   ```
   *(Selesai! Script `./deploy.sh` akan me-pull dari GitHub dan me-restart container secara otomatis)*.
