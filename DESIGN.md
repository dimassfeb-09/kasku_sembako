# DESIGN.md — Kasirku Sembako UI/UX Design System

> Dokumen ini adalah panduan desain visual lengkap aplikasi **Kasirku Sembako**, terinspirasi langsung dari referensi visual antarmuka kasir modern premium (Tasty Station POS). Digunakan sebagai acuan resmi bagi Designer dan Developer.

---

## 1. Fondasi Visual (Design Foundation)

### 1.1 Filosofi Desain

| Prinsip | Deskripsi |
|:--|:--|
| **Clean & Airy** | Latar belakang putih bersih dengan ruang putih (*whitespace*) yang lega. UI tidak pernah terasa sesak. |
| **Soft & Rounded** | Tidak ada sudut kotak yang kaku. Semua card, tombol, dan input menggunakan sudut melingkar lebar. |
| **Functional First** | Setiap elemen visual harus memiliki alasan fungsional. Tidak ada dekorasi yang tidak perlu. |
| **High Clarity** | Hierarki teks yang kuat. Pengguna selalu tahu apa yang paling penting di layar. |
| **Tactile & Responsive** | Setiap elemen interaktif memberikan feedback visual instan saat disentuh. |

---

## 2. Sistem Warna (Color System)

### 2.1 Palet Warna Utama

| Token | Nama | Hex | Kegunaan |
|:--|:--|:--|:--|
| `color-primary` | Teal 600 | `#0D9488` | Aksi utama, tab aktif, tombol kuantitas `+`, tombol checkout, border card aktif. |
| `color-primary-pressed` | Teal 700 | `#0F766E` | Pressed / hover state untuk tombol primer. |
| `color-primary-light` | Teal 50 | `#F0FDFA` | Latar belakang chip aktif, highlight row, tag label aktif. |
| `color-primary-border` | Teal 200 | `#99F6E4` | Border card produk yang sedang aktif/dipilih. |

### 2.2 Palet Warna Netral (Canvas & Surfaces)

| Token | Nama | Hex | Kegunaan |
|:--|:--|:--|:--|
| `color-background` | Slate 50 | `#F8FAFC` | Background dasar halaman / scaffold. |
| `color-surface` | White | `#FFFFFF` | Sidebar, card produk, panel kasir kanan, dialog, bottom sheet. |
| `color-surface-subtle` | Slate 100 | `#F1F5F9` | Latar belakang input search bar, latar row tabel alternatif. |
| `color-border` | Slate 100 | `#F1F5F9` | Garis pemisah antarmuka yang sangat tipis dan samar. |
| `color-border-medium` | Slate 200 | `#E2E8F0` | Border card pasif, divider antar section. |

### 2.3 Palet Warna Teks

| Token | Nama | Hex | Kegunaan |
|:--|:--|:--|:--|
| `color-text-primary` | Slate 900 | `#0F172A` | Judul halaman, nama produk, nominal harga, teks penting. |
| `color-text-secondary` | Slate 500 | `#64748B` | Label kategori, sub-judul, barcode, deskripsi item, metadata. |
| `color-text-muted` | Slate 400 | `#94A3B8` | Placeholder input, ikon navigasi tidak aktif, timestamp. |
| `color-text-on-primary` | White | `#FFFFFF` | Teks di atas tombol berwarna primer (Teal). |

### 2.4 Palet Warna Status (Semantic Colors)

| Token | Hex | Kegunaan |
|:--|:--|:--|
| `color-success` | `#10B981` | Kembalian tunai cukup, transaksi lunas, stok tersedia. |
| `color-success-light` | `#ECFDF5` | Background badge "Served" / "Lunas" / "Tersedia". |
| `color-error` | `#EF4444` | Pengeluaran, stok habis, void transaksi, pesan error form. |
| `color-error-light` | `#FEF2F2` | Background badge "Kosong" / error state. |
| `color-warning` | `#F59E0B` | Stok menipis, hutang berjalan, status "Wait List". |
| `color-warning-light` | `#FFFBEB` | Background badge "Wait List" / "Stok Tipis". |
| `color-info` | `#3B82F6` | Notifikasi informasi, status "In Kitchen". |
| `color-info-light` | `#EFF6FF` | Background badge "In Kitchen" / status proses. |

### 2.5 Warna Pastel Kartu Antrean (Order Card Palette)

Kartu status antrean menggunakan warna latar belakang pastel lembut yang berbeda-beda untuk identifikasi cepat secara visual:

| Status | Background | Border |
|:--|:--|:--|
| Dine In / Active | `#F0FDFA` (Teal 50) | `#99F6E4` (Teal 200) |
| Wait List | `#FFF7ED` (Orange 50) | `#FED7AA` (Orange 200) |
| Take Away | `#FDF4FF` (Purple 50) | `#E9D5FF` (Purple 200) |
| Ready / Served | `#F0FDF4` (Green 50) | `#BBF7D0` (Green 200) |

---

## 3. Tipografi (Typography)

**Font Utama**: `Inter` (Primary). Fallback: `Plus Jakarta Sans`, `system-ui`.

### 3.1 Skala Tipografi

| Nama Gaya | Size | Weight | Line Height | Kegunaan |
|:--|:--|:--|:--|:--|
| `text-2xl` | `24px` | `700` Bold | `32px` | Nominal besar: Total Harga Bayar. |
| `text-xl` | `20px` | `600` SemiBold | `28px` | Judul section utama (e.g. "Order Line", "Foodies Menu"). |
| `text-lg` | `18px` | `600` SemiBold | `26px` | Judul panel kanan (e.g. "Table No #04"). |
| `text-base-bold` | `15px` | `700` Bold | `22px` | Harga produk, total tagihan, nama item di keranjang. |
| `text-base` | `14px` | `400` Regular | `20px` | Nama produk di card, teks isi form, isi list item. |
| `text-sm-semibold` | `13px` | `600` SemiBold | `18px` | Label status chip, teks tombol sekunder, label metode bayar. |
| `text-sm` | `13px` | `400` Regular | `18px` | Metadata transaksi (waktu, jumlah orang), sub-label. |
| `text-xs-bold` | `11px` | `700` Bold | `14px` | Label kategori produk (di atas nama), label input field (CAPS). |
| `text-xs` | `11px` | `400` Regular | `14px` | Timestamp kecil, jumlah item kategori. |

### 3.2 Aturan Penulisan Angka Rupiah
- Selalu gunakan format **Bold** untuk nominal uang agar mudah dibaca kasir.
- Format penulisan: `Rp 150.000` (spasi setelah "Rp", titik sebagai pemisah ribuan).
- Warna default nominal: `#0F172A`. Warna kembalian/keuntungan: `#0D9488`.

---

## 4. Spasi & Tata Letak (Spacing & Layout)

### 4.1 Skala Spasi (Spacing Scale)
Semua padding, margin, dan gap mengikuti kelipatan 4px:

| Token | Nilai | Kegunaan Umum |
|:--|:--|:--|
| `space-1` | `4px` | Jarak antar ikon dan teks dalam satu tombol. |
| `space-2` | `8px` | Padding dalam badge/chip, jarak kecil dalam card. |
| `space-3` | `12px` | Padding dalam card produk kecil, jarak antar item list. |
| `space-4` | `16px` | Padding standar card dan halaman, jarak antar card. |
| `space-5` | `20px` | Padding lebar card besar, jarak antar section. |
| `space-6` | `24px` | Jarak antar section utama halaman. |
| `space-8` | `32px` | Padding luar halaman utama (horizontal margin layar). |

### 4.2 Sudut Membulat (Border Radius)

| Elemen | Radius | Contoh |
|:--|:--|:--|
| Card Produk & Antrean | `16px` | Grid produk, kartu status antrean. |
| Card Kategori | `16px` | Chip kategori "Foodies Menu". |
| Sidebar Menu Item | `12px` | Row menu navigasi kiri. |
| Input (Search, Text Field) | `12px` | Search bar atas. |
| Tombol Aksi Utama | `12px` | Tombol "Place Order", "Bayar". |
| Tombol Sekunder & Toggle | `10px` | Tombol "Print", metode pembayaran. |
| Chip Status / Badge | `20px` | Pill badge "In Kitchen", "Ready", "Lunas". |
| Dialog / Bottom Sheet | `24px` | Modal konfirmasi, bottom sheet checkout. |
| Avatar Pengguna | `9999px` | Foto profil operator. |

### 4.3 Sistem Bayangan (Shadow Tokens)

| Token | CSS Shadow | Kegunaan |
|:--|:--|:--|
| `shadow-none` | `none` | Card pasif, elemen di dalam surface. |
| `shadow-sm` | `0 2px 8px rgba(0,0,0,0.05)` | Card produk dengan hover ringan. |
| `shadow-md` | `0 4px 16px rgba(0,0,0,0.08)` | Panel sidebar, panel checkout kanan. |
| `shadow-lg` | `0 8px 30px rgba(0,0,0,0.10)` | Modal dialog, bottom sheet. |
| `shadow-active` | `0 0 0 1.5px #0D9488` | Ring outline card produk yang aktif/dipilih. |

---

## 5. Komponen UI (Component Library)

### 5.1 Tombol (Buttons)

**Tinggi Standar**: `44px` (Mobile), `40px` (Desktop/Tablet).

#### Primary Button (Tombol Utama)
```
Background  : #0D9488 (Teal 600)
Text        : #FFFFFF, 14px, SemiBold
Border Radius: 12px
Padding     : 12px 20px
State Pressed: Background -> #0F766E (Teal 700), scale(0.97)
State Disabled: Background -> #F1F5F9, Text -> #94A3B8
State Loading : Circular spinner putih mengganti teks, lebar tombol tidak berubah
```

#### Secondary / Outlined Button (Tombol Sekunder)
```
Background  : #FFFFFF
Border      : 1px solid #E2E8F0
Text        : #0F172A, 14px, SemiBold
Border Radius: 12px
State Pressed: Background -> #F8FAFC
```

#### Ghost Button (Tombol Teks Saja)
```
Background  : transparent
Text        : #0D9488 (Primary), 14px, Medium
State Pressed: Background -> #F0FDFA (Primary Light)
```

#### Danger Button (Tombol Aksi Kritis)
```
Background  : #EF4444
Text        : #FFFFFF, 14px, SemiBold
Border Radius: 12px
State Pressed: Background -> #DC2626
```

---

### 5.2 Input & Search Bar

#### Search Bar
```
Background  : #F1F5F9 (Slate 100)
Border      : 1px solid #F1F5F9 (tidak terlihat, menyatu dengan background)
Border Radius: 12px
Height      : 42px
Padding     : 0 12px
Icon Kiri   : Ikon pencarian (kaca pembesar), warna #94A3B8
Placeholder : "Cari produk, menu, pelanggan...", warna #94A3B8, 14px Regular
Focused     : Background -> #FFFFFF, Border -> 1px solid #0D9488
```

#### Text Field (Input Form)
```
Label (atas field): 11px, Bold, #64748B, letter-spacing 0.5px (UPPERCASE)
Background  : #F8FAFC
Border      : 1px solid #E2E8F0
Border Radius: 12px
Height      : 48px
Padding     : 0 14px
Text Input  : 14px, Regular, #0F172A
Placeholder : 14px, Regular, #94A3B8
Focused     : Border -> 1.5px solid #0D9488 + glow tipis rgba(13,148,136,0.1)
Error       : Border -> 1.5px solid #EF4444 + helper text merah di bawah
Disabled    : Background -> #F1F5F9, Text -> #94A3B8
```

---

### 5.3 Card Produk (Product Card)

```
Background    : #FFFFFF
Border Radius : 16px
Border Default: 1px solid #F1F5F9
Border Active : shadow-active (ring 1.5px #0D9488)
Shadow        : shadow-sm
Padding       : 12px
Layout (dari atas ke bawah):
  1. Foto Produk: Gambar lingkaran (circle, 72px x 72px), centered, object-fit: cover.
  2. Label Kategori: 11px, Regular, #64748B, centered, margin-top 8px.
  3. Nama Produk: 14px, Bold, #0F172A, centered, max 2 baris.
  4. Baris Harga & Quantity Controls:
     - Harga: 15px, Bold, #0F172A, aligned left.
     - Tombol [-]: Outlined circle/square, border #E2E8F0, teks #0F172A.
     - Angka Qty: 14px, Bold, #0F172A, centered.
     - Tombol [+]: Solid Teal background #0D9488, teks putih, border-radius 8px.
```

---

### 5.4 Kartu Status Antrean (Order Status Card)

```
Layout      : Horizontal card
Border Radius: 16px
Padding     : 14px 16px
Background  : Warna pastel sesuai status (lihat Palet Warna Antrean di Sekte 2.5)
Border      : 1px solid sesuai status
Content:
  - Baris atas  : Order ID (Bold, #0F172A) | Nomor Meja (Regular, #64748B)
  - Baris tengah: "Item: 8X" (SemiBold, besar, #0F172A)
  - Baris bawah : Timestamp (Small, #94A3B8) | Status Badge (Pill chip)
```

---

### 5.5 Chip Kategori (Category Chip)

```
Layout       : Horizontal (ikon kiri + teks nama + jumlah item di bawah nama)
Background Active  : #FFFFFF, border 1.5px solid #0D9488, shadow-sm
Background Inactive: #F8FAFC, border 1px solid #F1F5F9
Border Radius: 16px
Padding      : 10px 14px
Ikon         : Ilustrasi kecil (emoji atau gambar ikon kategori)
Nama         : 13px, SemiBold, #0F172A (aktif) / #64748B (tidak aktif)
Jumlah Item  : 11px, Regular, #94A3B8
```

---

### 5.6 Badge / Status Pill

```
Border Radius: 20px (pill penuh)
Padding      : 3px 10px
Font Size    : 12px, SemiBold

Status       | Background   | Text Color
"In Kitchen" | #EFF6FF      | #3B82F6
"Wait List"  | #FFFBEB      | #F59E0B
"Ready"      | #F0FDF4      | #10B981
"Served"     | #F0FDFA      | #0D9488
"Hutang"     | #FFFBEB      | #F59E0B
"Lunas"      | #ECFDF5      | #10B981
"Stok Habis" | #FEF2F2      | #EF4444
"Void"       | #FEF2F2      | #EF4444
```

---

### 5.7 Navigation Sidebar

```
Width       : 200px (Desktop/Tablet)
Background  : #FFFFFF
Shadow Kanan: shadow-md (ke arah kanan)
Padding     : 20px 12px

Header Toko:
  - Logo: Rounded square icon dengan warna primer Teal.
  - Nama Toko: 15px, Bold, #0F172A.

Menu Item (Row):
  - Height     : 44px
  - Border Radius: 12px
  - Padding    : 0 12px
  - Ikon       : 20px, stroke 1.5px, warna sesuai state.
  - Label      : 14px, Medium, warna sesuai state.
  - State Default: Ikon #94A3B8, Teks #64748B, Background transparent.
  - State Active : Ikon #0D9488, Teks #0D9488, Background #F0FDFA.

Footer Sidebar:
  - Tombol Pengaturan dan Logout.
  - Style: sama dengan menu item default.
```

---

### 5.8 Panel Checkout Kanan (Order Summary Panel)

```
Width       : 280-320px
Background  : #FFFFFF
Border Kiri : 1px solid #F1F5F9
Padding     : 20px

Bagian Header:
  - Nomor Meja: 18px, SemiBold, #0F172A. (e.g. "Table No #04")
  - Nomor Order: 14px, Regular, #64748B. (e.g. "Order #FO30")
  - Ikon Edit dan Hapus: Ikon kecil stroke 1.5px, #94A3B8.

Bagian Item List:
  - Divider: 1px solid #F1F5F9 antara judul dan list.
  - Item Row:
    - Qty & Nama: "2x Pasta with Roast Beef", 14px, Regular, #0F172A.
    - Harga Item: "Rp 20.000", 14px, Bold, #0F172A, align kanan.
  - Count Badge: Angka jumlah total item di kanan judul "Ordered Items", 
                 format Pill Chip Teal (Background #F0FDFA, Teks #0D9488).

Bagian Payment Summary:
  - Divider tebal (heading "Payment Summary") sebelum section.
  - Row Subtotal, Pajak, Diskon: 14px, Regular, #64748B (label) | #0F172A (nilai).
  - Row Total: 16px, Bold, #0F172A (label "Total Payable") | 18px, Bold, #0F172A (nilai).

Bagian Metode Pembayaran:
  - Heading: 14px, SemiBold, #0F172A, "Payment Method".
  - Grid 3 toggle button (Tunai / Card / QRIS Scan):
    - Default: Background #F8FAFC, Border #E2E8F0, Teks #64748B.
    - Active   : Background #F0FDFA, Border #0D9488 1.5px, Teks #0D9488.

Bagian Action Button Row:
  - Layout: Dua tombol berdampingan (gap 8px).
  - Tombol Kiri "Print": Outlined button, border #E2E8F0, ikon printer, teks "Print". Lebar fleksibel.
  - Tombol Kanan "Place Order": Primary Teal button, full width flex, 44px height.
```

---

### 5.9 Bottom Navigation Bar (Mobile)

```
Background  : #FFFFFF
Border Atas : 1px solid #F1F5F9
Height      : 60px
Padding     : 0 8px

Item Navigasi:
  - Default: Ikon stroke 24px, warna #94A3B8. Label 11px, Regular, #94A3B8.
  - Active : Ikon filled 24px, warna #0D9488. Label 11px, Bold, #0D9488.
  - Tanpa background kotak atau underline pada item aktif.

Menu Susunan (dari kiri ke kanan):
  1. Kasir / POS (ikon kasir/receipt)
  2. Produk (ikon box/package)
  3. Pelanggan (ikon people)
  4. Lainnya (ikon menu/more)
```

---

### 5.10 Dialog Modal & Bottom Sheet

```
Bottom Sheet (Mobile):
  - Border Radius Atas : 24px
  - Background        : #FFFFFF
  - Drag Handle       : Garis horizontal 40px x 4px, warna #E2E8F0, centered atas.
  - Shadow            : shadow-lg
  - Padding           : 20px 24px

Dialog Konfirmasi (Aksi Kritis):
  - Border Radius : 24px
  - Background    : #FFFFFF
  - Max Width     : 380px
  - Shadow        : shadow-lg
  - Padding       : 24px
  - Overlay       : rgba(0,0,0,0.4)
  - Layout        : Judul (Bold) -> Deskripsi (Regular, #64748B) -> Baris Tombol (gap 12px)
```

---

### 5.11 Snackbar / Toast Notification

```
Border Radius: 12px
Padding      : 14px 16px
Max Width    : 360px
Position     : Bawah tengah layar, margin 16px dari tepi bawah
Shadow       : shadow-md

Varian:
  Success: Background #ECFDF5, Ikon ✓ hijau, Teks #065F46.
  Error  : Background #FEF2F2, Ikon ✕ merah, Teks #991B1B.
  Warning: Background #FFFBEB, Ikon ⚠ amber, Teks #92400E.
  Info   : Background #EFF6FF, Ikon ℹ biru, Teks #1E40AF.
Durasi Auto-dismiss: 3 detik.
```

---

### 5.12 Empty State & Loading State

```
Empty State:
  - Ikon garis tipis minimalis (stroke, 64px x 64px), warna #94A3B8.
  - Judul: 16px, SemiBold, #0F172A.
  - Deskripsi: 14px, Regular, #64748B, max 2 baris.
  - Tombol Aksi (Opsional): Primary atau Ghost button.

Loading State:
  - Full screen atau in-card: Circular progress indicator warna #0D9488 (Teal).
  - Skeleton loader: Placeholder abu-abu #F1F5F9 dengan animasi shimmer kiri-ke-kanan.
```

---

## 6. Panduan UX & Interaksi (Interaction Patterns)

### 6.1 Transaksi POS
- Ketuk kartu produk sekali → item langsung masuk ke keranjang dengan kuantitas 1.
- Tombol `+` pada kartu produk → menambah kuantitas secara langsung.
- Ketuk angka kuantitas di keranjang → membuka numeric input pad untuk edit manual.
- Swipe kiri pada item di keranjang → muncul tombol hapus merah.

### 6.2 Konfirmasi Aksi Kritis
Aksi berikut wajib memunculkan dialog konfirmasi sebelum dieksekusi:
- Menghapus / Mengosongkan keranjang belanja.
- Void / Membatalkan transaksi lama.
- Hapus produk dari katalog.
- Hapus data pelanggan.
- Reset / Restore database.
- Logout dari sistem.

### 6.3 Feedback Visual
- Setiap tombol harus merespons sentuhan dengan perubahan warna atau skala minimal.
- Setelah checkout berhasil → tampilkan layar sukses penuh (bukan sekadar snackbar).
- Setelah simpan form berhasil → tampilkan snackbar `Success` selama 3 detik.
- Setelah terjadi error koneksi printer → tampilkan snackbar `Error` permanen hingga printer terhubung.

### 6.4 Form Validation
- Validasi error ditampilkan real-time saat pengguna meninggalkan field (on-blur).
- Pesan error menggunakan bahasa yang manusiawi, bukan kode teknis.
  - ✅ "Harga jual tidak boleh lebih kecil dari harga beli."
  - ❌ "Error: price_sell < price_buy"
- Tombol Submit disabled secara default hingga semua field wajib terisi dengan benar.

---

## 7. Ikonografi (Iconography)

- **Library**: Lucide Icons atau Material Rounded Icons (pilih satu, gunakan konsisten).
- **Ukuran Standar**: `20px` untuk ikon di dalam tombol dan list. `24px` untuk ikon navigasi.
- **Stroke Width**: `1.5px` untuk gaya ikon garis tipis yang elegan.
- **Warna Default**: `#94A3B8` (muted). Mengikuti warna teks elemen induknya saat aktif.
- **Aturan Penggunaan**: Gunakan ikon hanya jika membantu identifikasi cepat pengguna. Jangan menambahkan ikon dekoratif semata-mata untuk estetika.
