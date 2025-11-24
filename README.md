# GarudaSpot — Flutter Mobile Application

## 1. Daftar Anggota Kelompok
- Rifqy Pradipta Kurniawan
- Petrus Wermasaubun
- Daffa Syafitra
- Muhammad Azzam Fathurrahman
- Hasanul Muttaqin 
- Fernando Lawrence

## 2. Tautan APK
Belum tersedia (akan ditambahkan pada Tahap II).

## 3. Deskripsi Aplikasi
**GarudaSpot** adalah aplikasi mobile berbasis Flutter yang terintegrasi dengan layanan web (Django/PWS) yang telah dikembangkan pada Proyek Tengah Semester.  
Aplikasi ini berfungsi sebagai platform yang menyediakan berbagai modul sesuai perencanaan kelompok, termasuk autentikasi, modul pribadi setiap anggota, serta navigasi yang lengkap.

## 4. Daftar Modul yang Diimplementasikan dan Pembagian Kerja

### **Fase 0 - Inisiasi Git**
- **Inisiasi Git, Inisiasi Repository dan README.md**: Hasan

### **Fase 1 – Design**
- **Design Figma**: Azzam & Hasan

### **Fase 2 – Login & Register**
- **Autentikasi (Login & Register)**: Fernando  
- **Drawer**: Azzam

### **Fase 3 – Modul Inti**
**modul pribadi masing-masing anggota**.  
- Pembuatan UI halaman modul
- Logic integrasi API (GET/POST)
- Pengambilan dan pengiriman data ke backend Django
- Pembuatan halaman List, Detail, dan Form
- Penyesuaian dependensi antar modul

Daftar modul lengkap per anggota:
- Modul Rifqy: News
- Modul Daffa: Stats Pemain
- Modul Petrus: Forum
- Modul Fernando: Merch
- Modul Hasan: Pembelian Tiket
- Modul Azzam: Jadwal Pertandingan

### **Fase 4 – Finalisasi**
- Penggabungan seluruh modul  
- Penyelesaian bug fixing  
- Verifikasi integrasi  

### **Fase 5 – Video Promosi**

## 5. Peran atau Aktor Pengguna Aplikasi
- **User umum**: Mengakses fitur inti aplikasi  
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

## 7. Tautan Design Figma
[FIGMA](https://www.figma.com/files/team/1405405366915688940/all-projects?fuid=1405405363221989470)
