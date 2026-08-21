# PRD — Aplikasi Kasir UMKM Ritel

## 1. Ringkasan Eksekutif

### Pernyataan Masalah

UMKM ritel masih mencatat penjualan, stok, dan pembelian secara terpisah sehingga rawan salah hitung, stok tidak akurat, dan pemilik sulit mengetahui margin secara real-time.

### Solusi yang Diusulkan

Aplikasi POS offline-first untuk HP dan tablet Android yang menggabungkan penjualan kasir, inventori lanjutan, laporan penjualan/profit, dan struk digital dalam satu alur kerja.

### Kriteria Keberhasilan

- Median waktu transaksi 5 item maksimal 15 detik di Android kelas menengah.
- Minimal 99% transaksi offline tersinkronisasi dalam 60 detik setelah koneksi tersedia.
- Selisih stok sistem vs hasil stock opname maksimal 1% untuk produk aktif.
- Minimal 90% kasir dapat menyelesaikan simulasi penjualan tanpa pendampingan pada uji pertama.
- Crash-free session minimal 99% selama pilot 2 minggu.

## 2. Pengalaman Pengguna & Fungsionalitas

### Persona Pengguna

- **Pemilik Toko**: mengelola produk, stok, supplier, pembelian, pengguna, harga, dan laporan.
- **Kasir**: memproses penjualan, pembayaran, diskon sesuai izin, dan struk digital.

### Cerita Pengguna & Kriteria Penerimaan

#### Manajemen Produk

**Sebagai pemilik toko, saya ingin mengelola produk dengan SKU dan barcode sehingga penjualan dan stok konsisten.**

Acceptance Criteria:

- Produk menyimpan nama, SKU, barcode, kategori, satuan, harga jual, status stok, minimum stok, supplier utama, dan status aktif.
- Produk dapat dicari berdasarkan nama, SKU, atau barcode.
- Pencarian 1.000 produk mengembalikan hasil dalam 200 ms.
- Barcode dapat dipindai langsung melalui kamera perangkat.
- Produk nonaktif tidak muncul di layar kasir default.

#### Penjualan Kasir

**Sebagai kasir, saya ingin membuat keranjang, memindai produk, menerima pembayaran, dan memberikan struk digital sehingga pelanggan dilayani cepat.**

Acceptance Criteria:

- Kasir dapat menambah item lewat scan barcode atau pencarian produk.
- Keranjang menampilkan nama, jumlah, harga, diskon item, subtotal, diskon transaksi, total, metode bayar, dan kembalian.
- Aplikasi mendukung pembayaran cash, QRIS statis, atau kombinasi keduanya dalam satu transaksi.
- Pembayaran QRIS statis menampilkan QR merchant, mencatat nilai diterima, dan dikonfirmasi manual oleh kasir.
- Transaksi belum dibayar dapat dibatalkan; transaksi lunas hanya dapat direfund penuh oleh owner.
- Refund membuat jurnal stok balik otomatis dan menyimpan alasan refund.
- Struk digital dapat dibagikan sebagai PDF melalui aplikasi share Android.
- Nomor struk menggunakan format aman offline: `{kode_toko}-{kode_perangkat}-{YYYYMMDD}-{nomor_urut}`.

#### Inventori Lanjutan

**Sebagai pemilik toko, saya ingin mencatat pembelian, penerimaan barang, biaya pokok, penyesuaian stok, dan stok minimum sehingga keputusan restock lebih akurat.**

Acceptance Criteria:

- Sistem mendukung data supplier dan purchase order dengan status `draft`, `ordered`, `partial`, `received`, atau `cancelled`.
- Stok diperbarui dari ledger movement, bukan angka stok yang ditimpa langsung.
- Movement memiliki tipe: `purchase_receive`, `sale`, `refund`, `adjustment_in`, `adjustment_out`.
- Setiap movement menyimpan produk, jumlah bertanda, biaya/unit bila relevan, referensi transaksi, waktu, user ID, dan catatan.
- HPP menggunakan moving average cost.
- Penjualan produk berstok tidak boleh membuat stok menjadi negatif.
- Produk tanpa pelacakan stok tetap bisa dijual tanpa movement stok.
- Aplikasi menampilkan produk di bawah minimum stok dan nilai persediaan berdasarkan HPP.

#### Laporan

**Sebagai pemilik toko, saya ingin melihat performa penjualan dan laba sehingga dapat mengatur harga dan stok.**

Acceptance Criteria:

- Dashboard menampilkan omzet, jumlah transaksi, item terjual, laba kotor, rata-rata nilai transaksi, produk terlaris, stok rendah, dan nilai persediaan.
- Laporan dapat difilter harian, mingguan, bulanan, dan rentang tanggal kustom.
- Laporan dapat diekspor ke XLSX.
- Laba kotor dihitung dari `(harga jual - diskon - HPP saat penjualan) x qty`.

#### Pengguna & Keamanan

**Sebagai pemilik toko, saya ingin membedakan hak akses owner dan kasir sehingga operasi sensitif tetap terkendali.**

Acceptance Criteria:

- Role tersedia: `owner` dan `cashier`.
- Owner dapat mengelola produk, stok, supplier, purchase order, pengguna, harga, refund, dan laporan.
- Kasir dapat menjual, melihat produk, memproses pembayaran, dan membagikan struk.
- Kasir dapat memberi diskon transaksi hingga batas yang ditentukan owner; default maksimum 10%.
- Login menggunakan Firebase Authentication email/password.
- Owner dapat membuat akun kasir dengan temporary password; kasir wajib mengganti password pada login pertama.
- Aplikasi mendukung PIN 4–6 digit atau biometrik dan auto-lock setelah 5 menit idle.

### Bukan Tujuan MVP

- Integrasi payment gateway atau konfirmasi QRIS otomatis.
- Pembayaran kartu debit/kredit atau integrasi EDC fisik.
- Cetak thermal USB/LAN/Bluetooth.
- Multi-outlet, franchise, loyalty point, e-commerce, akuntansi penuh, payroll, dan AI.
- Pajak/service charge; harga jual diperlakukan sebagai harga akhir.
- Refund parsial; masuk roadmap `v1.1`.

## 3. Persyaratan Sistem AI

Tidak berlaku untuk MVP. Tidak ada fitur generatif, rekomendasi otomatis, atau keputusan bisnis otomatis berbasis AI.

## 4. Spesifikasi Teknis

### Tinjauan Arsitektur

- Aplikasi tetap menggunakan Flutter dan GetX.
- Firebase Authentication digunakan untuk login dan role.
- Cloud Firestore menjadi backend sinkronisasi multi-perangkat.
- Cloudinary menyimpan logo toko dan gambar QRIS statis.
- Drift/SQLite menjadi sumber kebenaran lokal di perangkat agar kasir tetap berjalan offline.
- Background sync worker mengirim operasi lokal ke Firestore secara idempoten menggunakan UUID dan `updated_at`.
- Master data seperti produk dan supplier menggunakan resolusi konflik last-writer-wins.
- Perubahan stok bersifat additive ledger sehingga tidak saling menimpa saat sinkronisasi.
- UI mengikuti `DESIGN.md`: target sentuh minimal 44x44 px, layout responsif HP/tablet, zona produk fleksibel, dan panel transaksi tetap mudah dijangkau.

### Model Data Utama

- `Business`: `id`, `name`, `code`, `address`, `phone`, `currency=IDR`, `qris_image_url`.
- `AppUser`: `uid`, `business_id`, `name`, `email`, `role`, `is_active`, `must_change_password`.
- `Product`: `id`, `business_id`, `name`, `sku`, `barcode`, `category_id`, `unit`, `selling_price`, `track_stock`, `min_stock`, `avg_cost`, `supplier_id`, `is_active`.
- `Supplier`: `id`, `business_id`, `name`, `phone`, `address`, `notes`.
- `PurchaseOrder`: `id`, `supplier_id`, `status`, `expected_at`, `received_at`, `total_cost`.
- `PurchaseOrderLine`: `product_id`, `ordered_qty`, `received_qty`, `unit_cost`.
- `StockMovement`: `id`, `product_id`, `movement_type`, `quantity_delta`, `unit_cost`, `reference_type`, `reference_id`, `occurred_at`, `user_id`, `note`.
- `Sale`: `id`, `receipt_number`, `status`, `subtotal`, `discount`, `total`, `paid_amount`, `change_amount`, `profit`, `cashier_id`, `created_at`, `synced_at`.
- `SaleLine`: `product_id`, `product_name_snapshot`, `qty`, `unit_price`, `line_discount`, `unit_cogs_snapshot`, `line_total`.
- `Payment`: `method=cash|qris_static`, `amount`, `reference_note`, `confirmed_by_cashier`, `created_at`.
- `AuditLog`: actor, action, entity, entity ID, before/after ringkas, timestamp.

### Aturan Bisnis

- Mata uang MVP adalah IDR bilangan bulat tanpa desimal.
- Semua ID offline menggunakan UUID v4.
- Timestamp disimpan UTC ISO-8601 dan ditampilkan dalam zona waktu perangkat.
- Total transaksi: `sum((unit_price x qty) - line_discount) - transaction_discount`.
- Kembalian cash dihitung dari uang diterima dikurangi bagian cash yang harus dibayar.
- Jika pembayaran campuran, total cash + QRIS harus sama dengan total tagihan sebelum transaksi diselesaikan.
- HPP penjualan disimpan snapshot saat transaksi terjadi agar laporan historis stabil.
- Firestore Security Rule wajib membatasi dokumen berdasarkan `business_id`, role, dan status aktif user.

### Titik Integrasi

- Firebase Authentication: sesi, role, ganti password.
- Cloud Firestore: sinkronisasi data dan audit.
- Cloudinary: logo dan QRIS statis.
- Mobile scanner: pemindaian barcode kamera belakang.
- Android Share Sheet: distribusi struk PDF.
- XLSX generator: ekspor laporan.

## 5. Risiko & Peta Jalan

### Peluncuran Bertahap

#### MVP

- Login, role owner/cashier, profil toko, QRIS statis.
- Produk, barcode, kategori, harga, diskon dasar.
- Penjualan offline-first, cash, QRIS statis, refund penuh, struk digital.
- Supplier, purchase order, penerimaan barang, stock adjustment, HPP moving average.
- Dashboard penjualan, laba kotor, stok rendah, nilai persediaan, ekspor XLSX.
- Audit log dan Firestore Security Rules.

#### v1.1

- Refund parsial dan retur pembelian.
- Cetak thermal Bluetooth.
- Varian produk dan batch/expiry.
- Laporan per periode lanjutan dan target penjualan.
- Backup/restore lokal.

#### v2.0

- Multi-outlet dan transfer stok antar cabang.
- Integrasi payment gateway dan rekonsiliasi QRIS.
- Loyalty, promo otomatis, dan pajak/service charge.
- Portal web owner.

### Risiko Teknis

- Konflik sinkronisasi offline dapat merusak stok jika ledger tidak konsisten.
- QRIS statis bergantung konfirmasi manual sehingga ada risiko salah catat pembayaran.
- Perangkat hilang dapat membocorkan data lokal jika auto-lock dan permission Android tidak diterapkan ketat.
- Kamera barcode kurang akurat di cahaya rendah atau barcode rusak.
- Biaya Firestore dapat naik jika sinkronisasi melakukan read/write berlebihan.
- Fragmentasi Android memengaruhi scanner, storage, dan background job.

### Test Plan

- Unit test: harga, diskon, pembayaran campuran, kembalian, HPP, stock ledger, nomor struk.
- Widget test: alur kasir, validasi pembayaran, hak akses owner/kasir, auto-lock.
- Integration test: buat sale offline, restore koneksi, verifikasi Firestore dan stok.
- Concurrency test: dua perangkat menjual produk stok terbatas secara bersamaan.
- Security test: kasir tidak dapat akses/refund/mutasi data lintas toko atau melewati batas diskon.
- Performance test: pencarian 1.000 produk <200 ms dan checkout 5 item <15 detik.
- Field pilot: 3 toko ritel selama 2 minggu dengan skenario normal, jam ramai, offline, refund, dan stock opname.

### Asumsi

- MVP single-outlet.
- Bahasa utama adalah Bahasa Indonesia.
- Perangkat utama adalah HP dan tablet Android.
- Stack tetap Flutter, Firebase Auth, Firestore, dan Cloudinary.
- Tidak ada printer fisik pada MVP.
- Internet tersedia saat setup, login awal, dan sinkronisasi; operasi kasir tetap berjalan offline.
