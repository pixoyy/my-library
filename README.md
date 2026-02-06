# 🍂 Autumn Library

Aplikasi penemuan buku yang indah dan modern yang dibangun dengan **Flutter**. Autumn Library memungkinkan pengguna untuk menjelajahi buku, mengelola bookmark, dan menyesuaikan profil mereka, semuanya dibalut dalam desain hangat bertema musim gugur.

## ✨ Fitur

### 🔐 Autentikasi (Authentication)
- **Login & Register Aman**: Buat akun dan masuk ke app. Buku yang di simpan(bookmark) sesuai dengan akun yang login.
- **Validasi**: Penerapan kata sandi (min 6 karakter) dan validasi email untuk memastikan integritas data.
- **UX yang Mulus**: Transisi halus dan formulir yang bersih dengan umpan balik kesalahan yang jelas.

### 📚 Penemuan Buku (Book Discovery)
- **Jelajahi Buku**
- **Navigasi Halaman (Pagination)**
- **Detail Buku**: sampul, judul, penulis, bahasa, tahun terbit, dan deskripsi.
- **Judul Sticky**: Saat Anda menggulir ke bawah pada halaman detail, judul buku akan muncul dengan elegan di bilah aplikasi (app bar) untuk menjaga konteks.

### 📑 Bookmark
- **Simpan Favorit**: Tandai buku untuk akses cepat nanti.

### 👤 Manajemen Profil
- **Edit Profil**: Perbarui nama pengguna, email, dan kata sandi Anda dengan mudah.
- **Validasi**: Formulir "Edit Profil" menggunakan aturan validasi yang sama dengan registrasi.
- **Logout**: Keluar dari akun Anda dengan aman.

### 🎨 Desain & UI
- **Tema Musim Gugur (Autumn Theme)**: Palet warna yang kohesif terinspirasi oleh musim gugur (Krem, Coklat, Oranye).
- **Navigasi Responsif**: Bilah navigasi bawah (bottom navigation bar) yang bersih dengan indikator status aktif.
- **Animasi**: Animasi Hero untuk sampul buku dan transisi halaman yang halus.

## 🚀 Memulai (Getting Started)

### Prasyarat
- [Flutter SDK](https://flutter.dev/docs/get-started/install) telah terinstal di mesin Anda.
- IDE (VS Code atau Android Studio) dengan ekstensi Flutter.

### Instalasi

1.  **Clone repositori**
    ```bash
    git clone https://github.com/yourusername/autumn-library.git
    cd my_library
    ```

2.  **Instal Dependensi**
    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

## 📂 Struktur Proyek

```
lib/
├── core/
│   ├── routes/         # Rute navigasi aplikasi
│   ├── theme/          # AppTheme (Warna, Gaya)
│   └── utils/          # Validator dan helper
├── data/
│   ├── fake_db/        # Penyimpanan data mock (Auth, Bookmarks)
│   ├── models/         # Model data (User, Book)
│   └── services/       # Layanan API (OpenLibraryService)
├── features/
│   ├── auth/           # Halaman Login & Register
│   ├── bookmarks/      # Halaman Bookmark
│   ├── category/       # Halaman Kategori
│   ├── home/           # Halaman Home & Detail Buku
│   └── profile/        # Halaman Profil
├── layout/             # Layout Utama & Navigasi
└── widgets/            # Widget yang dapat digunakan kembali (BookCard, dll.)
```

## 🛠 Dependensi

- **Flutter**: UI Toolkit
- **http**: Untuk mengambil data buku dari Open Library API.
- **provider** (atau sejenisnya): Untuk manajemen state (mis., AuthStore).
