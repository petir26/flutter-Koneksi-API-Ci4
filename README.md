# Flutter UMKM

Aplikasi Flutter untuk melihat dan mengelola data UMKM melalui REST API CI4. Fitur meliputi daftar dan pencarian, detail, tambah, edit, serta hapus data.

## Persyaratan

- Flutter SDK
- Backend CI4 berjalan pada `http://127.0.0.1:8080`

## Menjalankan

Dari folder repository:

```powershell
flutter pub get
flutter run -d chrome
```

Jalankan backend CI4 terlebih dahulu. Secara default Flutter Web menggunakan `http://127.0.0.1:8080/api/umkm`. Untuk perangkat fisik atau host khusus, sesuaikan `customHost` pada `lib/services/api_service.dart`.

## Implementasi

- Request HTTP memakai package `http`.
- Parsing JSON menggunakan model `Umkm` dengan `fromJson` dan `toJson`.
- Operasi jaringan menggunakan `async`/`await` dan penanganan error.
- Field data utama: `nama_umkm`, `pemilik`, `alamat`, `kategori`, dan `kontak`.
