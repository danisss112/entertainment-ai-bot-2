# 🤖 MEMORY & PROJECT RULES - EL GROUP TELEGRAM BOT

Dokumen ini berisi konfigurasi tetap, aturan sistem, arsitektur, dan SOP yang selalu diingat untuk proyek **EL Group Entertainment AI Assistant**.

---

## 🔑 1. IDENTITAS & ADMIN
- **Bot Token**: `8924197987:AAEcQKF28QNMZgxV4tkU0SCb_RMonMxEynk`
- **Username Bot**: `@Group_EL_Bot`
- **Admin Resmi (Madam Tika)**: `5437246207` (HANYA ID INI yang memiliki akses Admin / Takeover).
- **Akun User / Tester (Danis)**: `5660757898` (Diperlakukan sebagai Customer / Regular User, BUKAN Admin).
- **Grup Telegram Resmi**: `@spakaraokejakarta` (Sesi Forum Topic ID: `1` untuk diskusi).

---

## 📱 2. ATURAN TELEGRAM BUSINESS & SMART AUTO-TAKEOVER
1. **Khusus DM Pribadi (1-on-1 Business Chat & Private Bot Chat)**.
2. **Auto-Pause (5 Menit)**:
   - Ketika Admin (`5437246207`) membalas pesan tamu dari HP/Desktop (`fromId !== chatId`), bot otomatis **DIAM (PAUSED)** selama **5 menit**.
   - Setiap kali Admin membalas lagi, timer 5 menit di-reset dari awal.
3. **Auto-Resume (24/7)**:
   - Jika setelah 5 menit Admin tidak membalas lagi dan tamu chat baru, bot otomatis **mengambil alih** dan membalas tamu.
4. **Perintah Cepat Admin**:
   - `/pause`: Mengunci bot diam 2 jam.
   - `/resume` (atau `/unpause`): Membuka kunci bot agar aktif kembali seketika.
5. **Chat Langsung / Testing (`fromId === chatId`)**:
   - Bot selalu membalas normal tanpa masuk mode takeover.

---

## 💬 3. ALUR PERCAKAPAN RESERVASI & PERTANYAAN KHUSUS
1. **Pertanyaan Aneh / Di Luar SOP / Di Luar Knowledge**:
   - Bot membalas ramah: *"Mohon bersabar ya kak, pertanyaan Kakak sudah kami teruskan dan akan segera dijawab langsung oleh Madam Tika 🙏✨"*
   - AI menyertakan tag `[ESCALATE_QUESTION: <ringkasan>]`.
   - Node `Send AI Reply Smart` mengirim notifikasi alert lengkap ke Admin Telegram Madam Tika (`5437246207`).
2. **Alur Reservasi Interaktif**:
   - **Tahap 1 (Tanya detail)**: Bot menanyakan outlet tujuan (*Centro, Pangjay, Seven, Norte, Fenix, KG, Orca, Casa, Memento*) dan rencana jam kedatangan.
   - **Tahap 2 (Konfirmasi)**: Setelah tamu menyebutkan cabang & jam, bot mengonfirmasi data dicatat dan diteruskan ke Madam Tika (`[BOOKING_LEAD: ...]`), lalu mengirim notifikasi rincian booking lengkap ke Admin Telegram.

---

## 🛠️ 4. WORKFLOW GENERATION
- **Generator Script**: `scratch/build_clean_workflow.js`
- **Output Target**: `workflows/master_bot_workflow.json`
- **Aturan Pemanggilan Node di n8n**:
  - Selalu gunakan `.first().json` (contoh: `$('Parse & Send Direct Reply').first().json`) dan **HINDARI** `.item.json` untuk mencegah error *Paired item data unavailable* di n8n.


---

## 👑 10. FORMAT PESAN PEMBUKA / GREETING RESMI
Setiap kali ada user baru yang mengetik sapaan (*hi, halo, helo, hello, hai, p, start, /start*, dll), bot langsung membalas dengan teks pembuka resmi:
```text
👑 <b>EL SPA JAKARTA</b> 👑

Hadir dengan berbagai outlet premium di lokasi strategis Jakarta dan sekitarnya:

📍 EL CENTRO – Pangjay
📍 EL FENIX – Kelapa Gading
📍 EL NORTE – PIK
📍 EL ORCA – Jakarta Barat
📍 EL CASSA – Tangerang
📍 EL MEMENTO – Jaksel

🔗 Official Telegram: https://t.me/SpagrupEL

💎 Semua informasi, promo, event, dan reservasi terbaru tersedia di sini.

✨ Join sekarang dan jadilah yang pertama mendapatkan update terbaru dari EL Group.
```
