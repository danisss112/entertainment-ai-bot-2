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


---

## 📚 11. STANDAR 15 KNOWLEDGE BASE BOT AI – EL GROUP
1. **Jam Operasional**: Jam buka per cabang (Open Every Day), jika umum tanyakan cabang tujuan.
2. **Alamat Cabang**: Alamat detail + link Google Maps per cabang (Centro, Pangjay, Seven, Fenix, KG, Norte, Orca, Casa, Memento).
3. **Reservasi / Booking**: Alur 2 tahap (Nama, No HP, Cabang, Tanggal, Jam, Jumlah Tamu/Layanan) + auto lead notifier ke Admin.
4. **Harga & Price List**: Link foto resmi price list per cabang.
5. **Promo**: Promo selalu diperbarui secara berkala, tanyakan nama cabang.
6. **Room Karaoke (KTV)**: KTV Room di El Centro & El Fenix (Regular 2 Voucher, Party 4 Voucher, Pool Spa 3 Voucher, Close Voucher).
7. **Spa & Therapist**: Cek ketersediaan therapist sesuai cabang dan jam kedatangan.
8. **Metode Pembayaran**: Tunai, Debit, Kredit, QRIS (Pembayaran di kasir).
9. **Area Parkir**: Tersedia area parkir aman untuk kendaraan roda 2 dan roda 4 di seluruh outlet.
10. **Reservasi Mendadak / Walk-in**: Boleh datang langsung & pilih room/therapist di lokasi, namun disarankan reservasi agar siap.
11. **Kontak Cabang / Telepon**: Nomor kontak admin/asst per cabang (Madam Tika, Kim Asst Norte, Dori Asst Fenix).
12. **Keluhan / Komplain**: Minta data cabang, tanggal, jam, nama talent/therapist, kronologi + tag `[ESCALATE_QUESTION]`.
13. **Lowongan Kerja (Loker)**: Posisi LC & Therapist. Seleksi awal via foto/video, jika lolos lanjut QC & bawa KTP asli.
14. **Membership**: Keuntungan & syarat membership, kartu digital di `https://app.elgroupapp.com/`.
15. **Salam Penutup**: *"Terima kasih telah menghubungi EL Group ❤️ Apabila masih ada pertanyaan lain, silakan kirimkan pesan kapan saja."*

---

## 💬 12. RESPON RESMI FR (FIELD REPORT) / REVIEW (BY MRS. AFNY)
Jika tamu menanyakan FR, review, testimoni, atau feedback tamu lain:
> *"Hai kak , Nggak semua tamu kasih feedback/review, FR sebagian lebih pilih privacy. Tapi kakak nggak usah khawatir ya. Talent EL GROUP semua udah berpengalaman & rutin ikut training. Standar pelayanan kami selalu dijaga biar kakak nyaman & puas. Ditunggu kedatangannya di EL Group ✨"*
