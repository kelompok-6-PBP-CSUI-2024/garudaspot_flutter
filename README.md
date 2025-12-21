# GarudaSpot — Flutter Mobile Application

## 1. Daftar Anggota Kelompok
- Rifqy Pradipta Kurniawan
- Petrus Wermasaubun
- Daffa Syafitra
- Muhammad Azzam Fathurrahman
- Hasanul Muttaqin 
- Fernando Lawrence

## 2. Tautan APK
Belum tersedia.

## 3. Deskripsi Aplikasi
**GarudaSpot** adalah aplikasi mobile berbasis Flutter yang terintegrasi dengan layanan web (Django/PWS) yang telah dikembangkan pada Proyek Tengah Semester.  
Aplikasi ini berfungsi sebagai platform yang menyediakan berbagai modul sesuai perencanaan kelompok, termasuk autentikasi, modul pribadi setiap anggota, serta navigasi yang lengkap.

### Modul yang Tersedia
- **News**: Menyajikan daftar dan detail berita terbaru seputar timnas. Pengguna dapat menyortir dan membuka detail, sedangkan admin dapat membuat, mengedit, dan menghapus berita langsung dari aplikasi. Konten diambil dari endpoint backend dengan pagination dan dukungan filter.
- **Squad (Statistik Pemain)**: Menampilkan daftar pemain dengan data posisi, klub, caps, dan statistik lain. Admin dapat menambah, mengedit, atau menghapus pemain; pengguna umum bisa melihat detail tiap pemain. Data diambil dari backend dan disinkronkan setiap kali halaman dibuka atau setelah aksi CRUD.
- **Schedule (Jadwal Pertandingan)**: Memuat jadwal lengkap dengan kategori, lokasi, dan skor jika tersedia. Pengguna dapat memfilter dan menyortir jadwal, sementara admin bisa menambah, mengedit, dan menghapus pertandingan. Detail jadwal memuat informasi tambahan seperti statistik pertandingan.
- **Ticket**: Menampilkan daftar pertandingan yang bisa dibeli tiketnya beserta link vendor. Admin dapat membuat, mengedit, dan menghapus tiket serta link vendor; pengguna dapat membuka link untuk membeli di browser. Detail tiket menampilkan seluruh link dan informasi pertandingan terkait.
- **Merch**: Katalog merchandise dengan filter kategori dan urutan harga/popularitas. Admin bisa menambah, mengedit, dan menghapus item, sementara pengguna bisa membuka link vendor untuk membeli. Data ditarik dari endpoint JSON dan mendukung tampilan thumbnail serta stok.
- **Forum**: Menyediakan area diskusi matchday dan topik suporter. Pengguna terautentikasi dapat membuat thread, memberi upvote/downvote, dan berdiskusi. Admin dapat melakukan moderasi sesuai peran yang disetel di backend.

### 3a. Teknologi & Struktur
- Flutter + Dart, state via `provider` (`CookieRequest`) dan `http`.
- Folder utama: `lib/` dengan sub-modul `news/`, `Squad/`, `schedule/`, `merch/`, `tiket/`, `auth/`, serta `right_drawer.dart` untuk navigasi.
- Backend: Django (repo saudara `garuda_spot/` di folder tetangga). Base URL default `http://localhost:8000` di service masing-masing modul.

## 4. Daftar Modul yang Diimplementasikan dan Pembagian Kerja

### **Fase 0 - Inisiasi Git**
- **Inisiasi Git, Inisiasi Repository dan README.md**: Hasanul Muttaqin

### **Fase 1 – Design**
- **Design Figma**: Muhammad Azzam Fathurrahman & Hasanul Muttaqin

### **Fase 2 – Login & Register**
- **Autentikasi (Login & Register)**: Fernando Lawrence  
- **Drawer**: Muhammad Azzam Fathurrahman

### **Fase 3 – Modul Inti**
**modul pribadi masing-masing anggota**.  
- Pembuatan UI halaman modul
- Logic integrasi API (GET/POST)
- Pengambilan dan pengiriman data ke backend Django
- Pembuatan halaman List, Detail, dan Form
- Penyesuaian dependensi antar modul

Daftar modul lengkap per anggota:
- Modul Rifqy Pradipta Kurniawan: News
- Modul Daffa Syafitra: Stats Pemain
- Modul Petrus Wermasaubun: Forum
- Modul Fernando Lawrence: Merch
- Modul Hasanul Muttaqin: Pembelian Tiket
- Modul Muhammad Azzam Fathurrahman: Jadwal Pertandingan

### **Fase 4 – Finalisasi**
- Penggabungan seluruh modul  
- Penyelesaian bug fixing  
- Verifikasi integrasi  

### **Fase 5 – Video Promosi**

## 5. Peran atau Aktor Pengguna Aplikasi
- **User terautentikasi**: Menggunakan modul yang memerlukan login  
- **Admin**: Otorisasi create, delete dan update

## 6. Alur Pengintegrasian Data Flutter <-> Django (PWS)
Integrasi data dilakukan melalui **web service Django** (REST API).  
Alurnya sebagai berikut:

1. Flutter mengirim request HTTP (GET/POST) menggunakan `http` package.
2. Endpoint Django pada PWS menerima request dan memproses data.  
3. Django mengembalikan response dalam format **JSON**.  
4. Flutter melakukan:
   - Parsing JSON  
   - Menampilkan data pada UI  
   - Mengirim data baru (misalnya dari Form) ke backend  
5. Setiap modul pribadi anggota menggunakan endpoint API masing-masing untuk fitur CRUD atau tampilan data.

Contoh siklus integrasi modul:
- Flutter menampilkan **Form** → user mengisi → data dikirim ke API Django  
- Django menyimpan data → Flutter menampilkan kembali melalui **List/Detail Screen**

Semua modul berjalan di atas pola integrasi yang sama.

### Endpoint Backend yang Dipakai (ringkas)
- Auth: `/accounts/login-mobile/` (CookieRequest menyimpan session + cookie).
- News: `/news/api/news/` (GET list/paging, POST admin), `/news/api/news/delete/<uuid:id>/` (POST admin).
- Squad: `/squad/api/players/` (GET), `/squad/api/players/create/` (POST admin), `/squad/api/players/<id>/edit/`, `/squad/api/players/<id>/delete/`.
- Schedule: `/schedule/api/match/` (GET list), `/schedule/api/match/add/` (POST admin), `/schedule/api/match/edit/<uuid:id>/`, `/schedule/api/match/delete/<uuid:id>/`.
- Ticket: `/tickets/json/` (GET list), `/tickets/json/<uuid:match_uuid>/` (GET detail), `/tickets/create/` (POST admin), `/tickets/edit/<uuid:id>/`, `/tickets/delete/<uuid:id>/`, `/tickets/link/create/<uuid:match_uuid>/`, `/tickets/link/delete/<uuid:id>/`.
- Merch: `/merch/json/` (GET list), `/merch/api/update/<id>/` (POST admin), `/merch/api/delete/<id>/` (POST admin).

## 7. Tautan Design Figma dan Video Promosi
[FIGMA](https://www.figma.com/files/team/1405405366915688940/all-projects?fuid=1405405363221989470)
[GDrive video promosi](https://drive.google.com/drive/u/0/folders/177ytMnZFzX1YUFqtcLQVqVOK2IOdFSOR)

## 8. Cara Menjalankan Flutter Client (lokal)
1. Pastikan backend Django berjalan di `http://localhost:8000` (atau sesuaikan base URL di file service modul jika perlu).
2. `flutter pub get`
3. Jalankan: `flutter run -d chrome` (web) atau emulator target.
4. Login via akun admin (default dari backend migrasi: `admin` / `admin123`, atau admin lokal `flutter_admin` / `FlutterPass123`).

## 9. Catatan Modul
- Ticket (`lib/tiket/`): CRUD tiket + link vendor; tombol admin muncul jika `isAdmin` atau `isSuperuser` dari login response.
- Schedule (`lib/schedule/`): daftar jadwal dengan filter/sort; admin dapat add/edit/delete.
- Merch (`lib/merch/`): katalog dengan filter/sort; admin CRUD.
- News (`lib/news/`) & Squad (`lib/Squad/`): list/detail/CRUD sesuai peran admin.

## 10. Bitrise
Link : https://app.bitrise.io/app/0ceec09a-a6e7-4753-a041-f623f6ddc255/installable-artifacts/5bb65871b45a2a15/public-install-page/6eacc771acf7a2a64bed28f04fbb9a6a