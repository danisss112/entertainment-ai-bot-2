-- =============================================================================
-- ENTERTAINMENT AI ASSISTANT - DATABASE SCHEMA & INITIAL SEED DATA
-- EL GROUP SPA & KARAOKE ASSISTANT (MRS. AFNY MARKETING)
-- =============================================================================

-- Enable extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    first_name VARCHAR(255),
    username VARCHAR(255),
    phone VARCHAR(50),
    platform VARCHAR(50) DEFAULT 'telegram',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. ADMINS TABLE
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. OUTLETS TABLE
CREATE TABLE IF NOT EXISTS outlets (
    id SERIAL PRIMARY KEY,
    outlet_key VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    location_url TEXT,
    operational_hours VARCHAR(255),
    pricelist_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. BARCODES TABLE (With 02:00 WIB daily expiration logic)
CREATE TABLE IF NOT EXISTS barcodes (
    id SERIAL PRIMARY KEY,
    outlet_key VARCHAR(50) UNIQUE NOT NULL REFERENCES outlets(outlet_key) ON DELETE CASCADE,
    file_id TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES admins(telegram_id)
);

-- 4b. BOT_BARCODES TABLE (Used by n8n workflow - standalone, no FK constraint)
CREATE TABLE IF NOT EXISTS bot_barcodes (
    outlet_key VARCHAR(50) PRIMARY KEY,
    file_id TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT
);

-- 4c. BOT_ADMIN_STATE TABLE (Tracks which outlet Admin selected before sending photo)
CREATE TABLE IF NOT EXISTS bot_admin_state (
    admin_id BIGINT PRIMARY KEY,
    outlet_key VARCHAR(50) NOT NULL,
    selected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4d. BOT_CHAT_SESSIONS TABLE (Tracks Telegram Business Chatbot & Human Takeover state)
CREATE TABLE IF NOT EXISTS bot_chat_sessions (
    chat_id BIGINT PRIMARY KEY,
    is_paused BOOLEAN DEFAULT FALSE,
    paused_until TIMESTAMP WITH TIME ZONE,
    last_admin_activity TIMESTAMP WITH TIME ZONE,
    business_connection_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. TALENTS TABLE
CREATE TABLE IF NOT EXISTS talents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100), -- Platinum, Pink Lady, Model, Diamond, Celeb, Gold
    availability VARCHAR(50) DEFAULT 'Available',
    rate VARCHAR(100),
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. EVENTS TABLE
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    event_date TIMESTAMP WITH TIME ZONE,
    location VARCHAR(255),
    description TEXT,
    status VARCHAR(50) DEFAULT 'Upcoming',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. BOOKINGS & LEADS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT NOT NULL,
    customer_name VARCHAR(255),
    outlet_key VARCHAR(50),
    service_type VARCHAR(100),
    event_date VARCHAR(100),
    budget VARCHAR(100),
    notes TEXT,
    status VARCHAR(50) DEFAULT 'NEW', -- NEW, NEED_ADMIN, QUALIFIED, BOOKED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. CHAT HISTORY TABLE
CREATE TABLE IF NOT EXISTS chat_history (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. KNOWLEDGE BASE TABLE (For AI Context & RAG)
CREATE TABLE IF NOT EXISTS knowledge (
    id SERIAL PRIMARY KEY,
    category VARCHAR(100),
    question_pattern VARCHAR(255),
    answer_text TEXT NOT NULL,
    keywords VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =============================================================================
-- SEED DATA INITIALIZATION
-- =============================================================================

-- Seed Admin
INSERT INTO admins (telegram_id, name, role) 
VALUES 
    (5437246207, 'Mrs. Afny Admin', 'super_admin'),
    (6576926570, 'Mrs. Afny Admin 2', 'admin')
ON CONFLICT (telegram_id) DO NOTHING;

-- Seed Outlets (9 Cabang Resmi EL Group)
INSERT INTO outlets (outlet_key, name, location_url, operational_hours, pricelist_photo_url) VALUES
('centro',          'El Centro',              'https://g.co/kgs/XsooJhR', '13.00 - 01.00 WIB | Last Order 00.30', '/assets/pricelist/el-centro.jpeg'),
('spaPangjay',      'El Spa Pangjay',         'https://g.co/kgs/XsooJhR', '10.00 - 23.00 WIB | Last Order 22.30', '/assets/pricelist/el-spa-pangjay.jpeg'),
('seven',           'El Seven',               'https://g.co/kgs/XsooJhR', '18.00 - 04.00 WIB | Last Order 03.30', '/assets/pricelist/el-seven.jpeg'),
('norte',           'El Norte',               'https://g.co/kgs/2x2ah1j', '12.00 - 24.00 WIB | Last Order 23.30', '/assets/pricelist/el-norte.jpeg'),
('fenix',           'El Fenix',               'https://g.co/kgs/boEFS4t', '13.00 - 24.00 WIB | Last Order 23.30', '/assets/pricelist/el-fenix.jpeg'),
('spaKelapaGading', 'El Spa Kelapa Gading',   'https://g.co/kgs/boEFS4t', '12.00 - 24.00 WIB | Last Order 23.30', '/assets/pricelist/el-spa-kelapa-gading.jpeg'),
('orca',            'El Orca',                'https://g.co/kgs/uftGAAa', '12.00 - 23.00 WIB | Last Order 22.30', '/assets/pricelist/el-orca.jpeg'),
('cassa',           'El Cassa',               'https://g.co/kgs/JbtEvHK', '13.00 - 24.00 WIB | Last Order 23.30', '/assets/pricelist/el-cassa.jpeg'),
('memento',         'El Memento',             'https://share.google/NkCFC2E5gQHcVXI7Y', '13.00 - 01.00 WIB | Last Order 00.30', '/assets/pricelist/el-memento.jpeg')
ON CONFLICT (outlet_key) DO UPDATE SET 
    name = EXCLUDED.name,
    location_url = EXCLUDED.location_url,
    operational_hours = EXCLUDED.operational_hours,
    pricelist_photo_url = EXCLUDED.pricelist_photo_url;

-- Seed Knowledge Base
INSERT INTO knowledge (category, question_pattern, answer_text, keywords) VALUES
('jamops', 'Jam Operasional / Jam Buka Outlet', 
'⏰ 𝗝𝗮𝗺 𝗢𝗽𝗲𝗿𝗮𝘀𝗶𝗼𝗻𝗮𝗹 𝗘𝗟 𝗚𝗿𝗼𝘂𝗽:

📍 EL CENTRO: 13.00 - 01.00 WIB (Last Order: 00.30 WIB)
📍 EL SPA PANGJAY: 10.00 – 23.00 WIB (Last Order: 22.30 WIB)
📍 EL SEVEN CLUB: 18.00 – 04.00 WIB (Last Order: 03.30 WIB)
📍 EL NORTE: 12.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL FENIX: 13.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL SPA GADING: 12.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL ORCA: 12.00 – 23.00 WIB (Last Order: 22.30 WIB)
📍 EL CASSA: 13.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL MEMENTO: 13.00 – 01.00 WIB (Last Order: 00.30 WIB)

━━━━━━━━━━━━━━━  
𝗡𝗼𝘁𝗲: 𝗪𝗲 𝗔𝗿𝗲 𝗢𝗽𝗲𝗻 𝗘𝘃𝗲𝗿𝘆 𝗗𝗮𝘆 😘', 'jam, ops, buka, tutup, operasional, jadwal, kapan'),

('donotdo', 'Peraturan dan Larangan (Do Not Do)', 
'PERATURAN & KETENTUAN EL GROUP ⚠️

DILARANG:
1. Membawa/mengonsumsi narkoba & zat terlarang
2. Membawa senjata tajam/senjata api
3. Membawa makanan & minuman dari luar
4. Merekam video/mengambil foto selama room service
5. Memaksa terapis melakukan tindakan di luar SOP
6. Merusak fasilitas atau membawa pulang inventaris kamar

KEBIJAKAN:
Pelanggan yang melanggar akan dikenakan Sanksi tegas berupa:
- Pemutusan layanan tanpa refund
- Denda sesuai kerusakan/kerugian
- BLACKLIST PERMANEN dari semua Outlet EL Group.

Demi kenyamanan & keamanan bersama. Terima kasih atas pengertiannya.', 'aturan, dilarang, larangan, rules, donotdo, narkoba, fasilitas, sanksi, blacklist'),

('applymember', 'Registrasi Member EL Group', 
'Hai kak! ✨

Untuk menjadi member EL, kamu membutuhkan:
1. Nama
2. Nomor WhatsApp yang aktif (untuk pengiriman kode OTP)

Pendaftaran 100% GRATIS tanpa biaya!
Silakan klik link berikut untuk mendaftar sebagai member EL:
👉 https://app.elgroupapp.com/

Keuntungan Member:
- Member Regular: Cashback Rp 30.000 / voucher di aplikasi (berlaku max 3 hari dari tanggal kedatangan).
- Member Prioritas (Spend Rp 70.000.000+/bln): Cashback Rp 50.000 / voucher di aplikasi.
- Update promo eksklusif perusahaan langsung di aplikasi.', 'member, registrasi, daftar, cashback, kartu, join, prioritas, otp'),

('payment', 'Metode Pembayaran', 
'💳 Metode Pembayaran Resmi EL Group:
• QRIS
• NFC Card EL
• Debit / Credit Card (CC kena biaya 3%)
• Transfer Bank (CIMB Niaga)
• Cash / Tunai

⚠️ Catatan: Pembayaran hanya dilakukan di kasir resmi.', 'payment, pembayaran, bayar, qris, transfer, cash, kartu, cc, cimb'),

('contact', 'Kontak Reservasi & Admin', 
'𝗕𝗮𝗿𝗰𝗼𝗱𝗲 & 𝗥𝗲𝘀𝗲𝗿𝘃𝗮𝘀𝗶 🔗

🩵 Mrs.Afni (Marketing Utama)
WhatsApp: https://wa.me/6281280100080
Direct Link: https://kontak.com/wa/7c5e8f

TELEGRAM GRUP:
https://t.me/SpagrupEL

💙 Sansan Asst (Pangjay): https://wa.me/6282114093109
💙 Uci Asst (Spa Pangjay): https://wa.me/6282123333268
💙 Indra Asst (El-Memento): https://wa.me/6282321292661
💙 Bella Asst (El Orca): https://wa.me/6287899272760
💙 Rico Asst (El Cassa): https://wa.me/6281933561210

Admin:
🫦 @Mrs.Afni | @Sansan | @Uci | @Indra | @Bella | @Ricco

"🔥 Reservasi lebih awal untuk mendapatkan pilihan tempat terbaik."', 'contact, kontak, admin, afni, afny, whatsapp, wa, telegram, sansan, uci, indra, bella, rico, reservasi'),

('layanan_options', 'Ketentuan Layanan & Fasilitas Ladies', 
'Hai kak 👋 EL Group memiliki 2 tipe layanan:

1. 💃 Ladies Companion (LC) - No Massage (Durasi 1 Jam langsung ke kamar):
- 1 Voucher: Menemani 1 jam di kamar (eksekusi).
- 2 Voucher: Menemani Karaoke KTV durasi 3 jam.
- 3 Voucher: Menemani di ruangan Pool + Karaoke durasi 4 jam.
* Grade LC: Platinum, Pink Lady, Model, Diamond, Celeb.

2. 💆‍♀️ Therapist (Include Massage) - Durasi 90 Menit:
- Menemani berendam bersama di pool, lanjut ke kamar untuk massage & eksekusi.
* Grade Therapist: Gold, Platinum, Pink, Model.

Note: Grade ladies & therapist berbeda di masing-masing cabang ya kak.', 'layanan, lc, companion, therapist, terapis, massage, pijat, grade, perbedaan, fasilitas'),

('ruangan_ktv', 'Tipe Ruangan Karaoke KTV & Minimum Charge',
'🎤 𝗥𝗜𝗡𝗖𝗜𝗔𝗡 𝗥𝗨𝗔𝗡𝗚𝗔𝗡 𝗞𝗔𝗥𝗔𝗢𝗞𝗘 𝗞𝗧𝗩:

1. 🎤 <b>Ruangan New-VIP:</b>
• Ruangan besar muat kisaran <b>20 orang</b> (cocok untuk party rame-rame).
• Minimum charge: <b>Rp 4.000.000</b>.

2. 🎤 <b>Ruangan POOL + KTV:</b>
• Karaoke eksklusif + Private Pool (Hanya 2 room: <b>Room 88</b> & <b>Room 99</b>).
• Minimum charge: <b>Rp 4.000.000</b>.

3. 🎤 <b>Ruangan Standar:</b>
• Ruangan nyaman muat hingga <b>8 orang</b>.
• Minimum charge: <b>Rp 2.000.000</b>.

Untuk reservasi room, silakan hubungi asisten cabang terkait atau Mrs. Afny ya kak! ✨', 'room, ruangan, ktv, vip, new vip, pool, standar, muat berapa, kapasitas, min charge'),

('paket_karaoke_elcentro', 'Pricelist Paket Karaoke KTV El Centro', 
'🎤 Paket Karaoke KTV El Centro (Durasi 3 Jam Package):
• PLATINUM: Rp 2.040.000
• PINK LADY: Rp 2.680.000
• MODEL: Rp 3.280.000
• DIAMOND: Rp 7.000.000 (Durasi 3 Jam KTV + 90 mnt ke kamar. Jika hanya ke kamar saja tanpa KTV: Rp 3.000.000)
• CELEB: Rp 8.000.000 (Durasi 3 Jam KTV + 90 mnt ke kamar)

🏢 Minimum Charge Room KTV El Centro:
- Room VIP: Min Charge Rp 4.000.000 (muat ~20 org)
- Room Standar: Min Charge Rp 2.000.000 (muat ~8 org)
- Room KTV & Pool: Min Charge Rp 4.000.000 (Room 88 & 99)
* Saran: Untuk lebih mudah & efektif bisa ambil paket botolan (ladies + bottle)!', 'karaoke, ktv, elcentro, paket, harga ktv, vip, room, diamond, celeb, platinum, pink lady, model'),

('estafet', 'Paket Estafet', 
'🔥 New Package Additional - ESTAFET:
- Pilih 3 ladies Platinum langsung di lokasi (tidak bisa booking).
- Total durasi 90 menit (3x FJ 💦).
- Ladies ke-1: 30 menit
- Ladies ke-2: 30 menit
- Ladies ke-3: 30 menit', 'estafet, paket, ladies, platinum, 30 menit, 90 menit'),

('threesome', 'Paket Threesome', 
'💦 PAKET THREESOME (KAMAR):
1. Durasi 2 Jam: 2x FJ 💦, Total 4 Voucher (1 Ladies 2 Voucher).
2. Durasi 1 Jam: 1x FJ 💦, Total 2 Voucher (1 Ladies 1 Voucher).', 'threesome, 3some, voucher, kamar, 2 jam, 1 jam'),

('doublejackpot', 'Paket Double Jackpot & All You Can F', 
'🎰 PAKET KHUSUS EL SEVEN:
• Double Jackpot: Durasi 60 menit, 2x 💦 (1x FJ + 1x HJ).
• All You Can F: Durasi 90 menit, max ganti 3 ladies @30 menit, 3x 💦 (khusus grade GOLD).', 'jackpot, double, seven, all you can f, gold'),

('celeb_diamond', 'Aturan Booking Celeb & Diamond', 
'⭐ ATURAN BOOKING CELEB & DIAMOND:
1. Wajib melakukan reservasi H-1 (1 hari sebelumnya).
2. Wajib membayar DP (uang muka) 50%.
3. Bisa request di semua Outlet EL Group.
Mohon hubungi Mrs. Afny untuk ketersediaan jadwal ya kak! 😊', 'celeb, diamond, booking, dp, h-1, aturan'),

('rules_sop', 'SOP Barcode Masuk & Cara Booking', 
'📌 SOP KEDATANGAN & BARCODE MASUK:
1. Setiap tamu wajib melakukan reservasi & memiliki Barcode Masuk harian resmi.
2. Tunjukkan Barcode Masuk kepada petugas di lokasi dan sebutkan nama Mrs. Afny di depan.
3. Tamu bisa booking ladies sebelumnya dengan meminta absen ladies yang hadir hari ini, atau bisa pilih langsung di lokasi (showing/kontes ladies).
*(Barcode otomatis expired setiap pukul 02.00 WIB).*', 'sop, barcode, lift, keamanan, security, reservasi, akses, cara booking, showing, kontes'),

('lokasi_cabang', 'Daftar Lokasi & Alamat Cabang Resmi EL Group', 
'👑 <b>EL GROUP — SPA MASSAGE, KARAOKE, LOUNGE, BAR, CLUB</b>

📍 <b>1. EL CENTRO HOTEL MAXWELL</b>
Jl. Pangjay No.40, Jakarta Pusat
• EL Centro — Lt. 8
• EL Spa Pangjay — Lt. 3
• EL Seven Club — Lt. 2
🗺️ Maps Maxwell: https://g.co/kgs/XsooJhR

📍 <b>2. EL NORTE</b>
Ruko Galery II Mediterania Blok N8-M8, Jl. Pantai Indah Kapuk (PIK), Jakarta Utara
🗺️ Maps PIK: https://g.co/kgs/2x2ah1j

📍 <b>3. EL FENIX</b>
Tower Harton City Hub, Jl. Boulevard Artha Gading Lt. 9-10, Jakarta Utara
• EL Fenix — Lt. 10
• EL Spa Kelapa Gading — Lt. 9
🗺️ Maps Kelapa Gading: https://g.co/kgs/boEFS4t

📍 <b>4. EL ORCA</b>
Green Lake City, Ruko Food City No.122-123, Duri Kosambi, Cengkareng, Jakarta Barat
🗺️ Maps Orca: https://g.co/kgs/uftGAAa

📍 <b>5. EL CASA</b>
Ruko Neo Arcade, Jl. CBD Gading No.1-2 Blok A, Tangerang
🗺️ Maps Cassa: https://g.co/kgs/JbtEvHK

📍 <b>6. EL MEMENTO</b>
Jl. Wijaya I No.21, Jakarta Selatan
🗺️ Maps Memento: https://share.google/NkCFC2E5gQHcVXI7Y

━━━━━━━━━━━━━━━
📱 <b>RESERVASI & BARCODE:</b>
Hubungi Mrs. Afny (081280100080)
WhatsApp: https://wa.me/6281280100080', 'lokasi, cabang, alamat, outlet, dimana, maps, maxwell, pangjay, pik, kelapa gading, glc, gading serpong, jaksel, wijaya, cassa, orca, fenix, norte, centro'),

('kesehatan_ladies', 'Kesehatan & Kebersihan Talent EL Group', 
'Kak tenang aja ya 🙏 Ladies & Therapist EL Group semuanya rutin cek kesehatan dan dokter secara berkala, serta dipastikan higienis & bebas HIV. Standar pelayanan kami selalu dijaga biar kakak nyaman dan aman 😃', 'sehat, hiv, penyakit, dokter, aman, kesehatan, ladies, terapis, higienis'),

('rekomendasi_wilayah', 'Panduan Rekomendasi Outlet Terdekat Berdasarkan Wilayah', 
'📍 <b>REKOMENDASI OUTLET EL GROUP TERDEKAT BERDASARKAN WILAYAH ANDA:</b>

1. 🚗 <b>Dari Bekasi / Jakarta Timur / Cawang / Pulo Gadung:</b>
   👉 Rekomendasi Utama: <b>EL FENIX & EL SPA KELAPA GADING</b> (Tower Harton City Hub, Jl. Blvd Artha Gading Lt. 9-10). Akses tercepat via Tol Becakayu / Tol Kelapa Gading.
   👉 Alternatif: <b>EL CENTRO HOTEL MAXWELL</b> (Jl. Pangjay No.40, Jakpus).

2. 🚗 <b>Dari Tangerang / Gading Serpong / BSD / Karawaci / Alam Sutera:</b>
   👉 Rekomendasi Utama: <b>EL CASA</b> (Ruko Neo Arcade, Jl. CBD Gading Blok A, Gading Serpong, Tangerang).
   👉 Alternatif: <b>EL ORCA</b> (Green Lake City / Cengkareng).

3. 🚗 <b>Dari Bandara Soekarno-Hatta (Soetta) / PIK / Pluit / Jakbar:</b>
   👉 Rekomendasi Utama: <b>EL NORTE (PIK)</b> (Ruko Galery II Mediterania Blok N8-M8, Pantai Indah Kapuk) atau <b>EL ORCA</b> (Green Lake City).

4. 🚗 <b>Dari Jakarta Selatan / Blok M / Senopati / Kemang / Pondok Indah:</b>
   👉 Rekomendasi Utama: <b>EL MEMENTO</b> (Jl. Wijaya I No.21, Kebayoran Baru, Jakarta Selatan).

5. 🚗 <b>Dari Jakarta Pusat / Mangga Besar / Kota / Monas:</b>
   👉 Rekomendasi Utama: <b>EL CENTRO HOTEL MAXWELL</b> (Jl. Pangjay No.40, Jakpus - Lt. 8 Centro, Lt. 3 Spa Pangjay, Lt. 2 Seven Club).

6. 🚗 <b>Dari Depok / Bogor:</b>
   👉 Rekomendasi: <b>EL MEMENTO (Jaksel)</b> via Tol Jagorawi / Tol TB Simatupang.

Untuk reservasi & barcode akses harian, hubungi Mrs. Afny (081280100080) ya kak! ✨', 'bekasi, tangerang, serpong, bsd, karawaci, bandara, soetta, pik, cengkareng, jaksel, jakbar, jaktim, jakpus, depok, bogor, cawang, terdekat, dari mana, akses, rute, rekomendasi, dekat mana'),

('fr_review', 'Testimoni & Field Report (FR)', 
'Halo kak! Sebagian tamu memang lebih menjaga privasi sehingga tidak semua memberikan feedback/FR publik. Tapi kakak tidak perlu khawatir, seluruh talent EL GROUP berpengalaman dan rutin mengikuti training SOP pelayanan ramah & terbaik. Ditunggu kedatangannya di EL Group ya! ✨', 'fr, review, field report, testimoni, masukan, feedback');
