# PRD — Aplikasi Kasir/POS Toko Kelontong (MVP)

## 1. Ringkasan Eksekutif

**Masalah**: Pencatatan penjualan manual di toko kelontong menyebabkan salah hitung, stok tak terpantau, laba tidak jelas, dan piutang pelanggan sering lupa ditagih.

**Solusi**: Aplikasi kasir Android tablet (Flutter + Firebase Firestore) — scan barcode, transaksi cepat, stok real-time, struk digital, laporan laba dengan ekspor Excel, piutang pelanggan, dan backup cloud.

**Kriteria Keberhasilan (KPI)**:
- Transaksi 10 item selesai < 60 detik dari scan hingga struk terkirim.
- Selisih stok fisik vs sistem ≤ 2% pada stok opname bulanan.
- 100% transaksi tersimpan di cloud (nol kehilangan data).
- Struk digital terkirim < 5 detik setelah pembayaran.
- Crash-free rate ≥ 99% (dipantau Firebase Crashlytics).

## 2. Pengalaman Pengguna & Fungsionalitas

**Persona**: Pemilik toko kelontong (non-teknis), kasir, dan pelanggan penerima struk digital. MVP memakai satu akun pemilik (email/password); tidak ada akun kasir terpisah.

**Cerita Pengguna + Kriteria Penerimaan**:

- **Kasir scan barcode produk** — scan EAN/UPC via kamera; lookup ≤ 2 detik; produk tanpa barcode bisa dicari/dipilih manual; jumlah item bisa diubah.
- **Kasir selesaikan transaksi tunai** — subtotal, diskon per item/total, input nominal bayar, kembalian otomatis, struk PDF tersimpan.
- **Kasir catat piutang pelanggan** — pilih/daftar pelanggan (nama, telepon), transaksi utang penuh, pelunasan sebagian/penuh, riwayat pembayaran, saldo pelanggan tampil.
- **Pemilik kelola produk & stok** — CRUD produk (nama, kategori, barcode, harga jual, harga modal, satuan); stok berkurang otomatis saat transaksi; peringatan stok menipis; fitur stok opname; void transaksi hari yang sama dengan alasan (oleh pemilik).
- **Pemilik lihat laba** — laporan penjualan per periode (omzet, laba kotor, jumlah transaksi), laba per produk, ekspor `.xlsx`.
- **Pemilik kirim struk** — struk digital (PDF) dibagikan via share Android (WhatsApp/HP), salinan otomatis tersimpan.

**Bukan Tujuan (MVP)**: multi-cabang/multi-perangkat, hutang ke supplier, member/poin, printer thermal, retur parsial, pajak, integrasi marketplace, fitur AI.

## 3. Persyaratan Sistem AI

Tidak berlaku — MVP tanpa fitur AI/ML. Kandidat masa depan: rekomendasi stok ulang dan deteksi produk via foto.

## 4. Spesifikasi Teknis

- **Arsitektur**: Flutter (repo `aplikasi_kasir_umkm` existing) — target Android tablet landscape, min SDK 24; state management Getx; Firestore dengan offline persistence (transaksi antre lokal saat internet putus, sinkron otomatis saat kembali online); satu perangkat/toko sehingga memakai last-write-wins tanpa konflik.
- **Paket kunci**: `mobile_scanner` (barcode kamera), `pdf` + `share_plus` (struk digital), `excel` (ekspor laporan), `firebase_core` + `cloud_firestore` + `firebase_auth` + `firebase_crashlytics`.
- **Skema Firestore**:
  - `stores/{id}` — nama, alamat, telepon.
  - `products/{id}` — storeId, nama, kategori, barcode, hargaJual, hargaModal, stok, satuan, stokMinimum.
  - `transactions/{id}` — storeId, items[] (produkId, nama, qty, harga, diskon), subtotal, diskon, total, metodePembayaran (`tunai`/`piutang`), customerId?, voidInfo?, createdAt.
  - `customers/{id}` — storeId, nama, telepon, alamat.
  - `debtPayments/{id}` — customerId, jumlah, metode, createdAt.
  - Saldo piutang pelanggan = total transaksi `piutang` − Σ `debtPayments`; penurunan stok dan pembuatan transaksi ditulis atomik via Firestore batch.
- **Integrasi**: Firebase Auth (email/password), Firestore, Crashlytics.
- **Keamanan & Privasi**: Firestore Security Rules membatasi akses per `storeId` (user hanya baca data tokonya); data pelanggan (nama/telepon) tidak dibagikan ke pihak ketiga; backup otomatis di cloud; penghapusan akun menghapus data toko.

## 5. Risiko, Pengujian & Peta Jalan

**Risiko**:
- Internet putus → mitigasi: offline persistence + retry.
- Biaya read Firestore → mitigasi: cache lokal + ringkasan penjualan harian.
- Akurasi stok → mitigasi: opname berkala.
- Perangkat murah RAM kecil → mitigasi: pagination daftar produk.
- Keamanan → mitigasi: Security Rules + Auth.

**Pengujian**:
- Unit test logika harga/diskon/kembalian/saldo piutang.
- Widget test alur kasir, scan barcode, dan void.
- Test sinkronisasi offline (mode pesawat → online).
- Uji lapangan di toko nyata dengan ≥ 50 transaksi dan stok opname 1 bulan.

**Roadmap**:
- **MVP**: fitur di atas (POS, stok, laporan, barcode, struk digital, ekspor Excel, piutang pelanggan).
- **v1.1**: printer thermal 58mm Bluetooth ESC/POS, PIN kasir, notifikasi stok menipis, retur parsial.
- **v2.0**: multi-cabang, hutang supplier, member/poin, analitik lanjutan.

## Asumsi Default

- Satu tablet, satu toko, satu akun pemilik; barcode via kamera tablet (tanpa scanner USB/BT di MVP); struk digital tanpa printer; bahasa Indonesia + mata uang Rupiah; retur dibatasi void transaksi hari yang sama.
