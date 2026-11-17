# ChainTodo

Aplikasi to-do list Flutter yang datanya **disimpan di smart contract** pada jaringan uji **Sepolia**, bukan di server atau database lokal.

Proyek mata kuliah Pemrograman Mobile 2, D4 Teknologi Rekayasa Komputer, Jurusan TIK, Politeknik Negeri Samarinda.

- **Anggota:** 
Lulu Aulia 246661009
Anggito Bayu Dwi Permadi 246661021

## Alamat kontrak dan Etherscan

| | |
|---|---|
| Jaringan | Sepolia Testnet (chain ID `11155111`) |
| Alamat kontrak | `0xb8548Dc8898Cf260fed451cbF763ebF690197542` |
| Link Etherscan | `https://sepolia.etherscan.io/address/0xb8548Dc8898Cf260fed451cbF763ebF690197542` |
| Compiler | Solidity `0.8.30+commit.73712a01` |
| Optimization | Tidak aktif |
| EVM version | default (osaka) |
| Lisensi | MIT |

Kode kontrak ada di [`contracts/ChainTodo.sol`](contracts/ChainTodo.sol).

## Versi paket

| Paket | Versi |
|---|---|
| Flutter |  `3.47.0` |
| Dart SDK | `^3.13.0` |
| `web3dart` | `^3.0.3` |
| `http` | `^1.6.0` |
| `flutter_dotenv` | `^6.0.2` |
| `wallet` | 0xf0049FeB881e8fE6E7868E36aCCbDcD195798c47|

## Fitur

- Menampilkan daftar tugas yang dibaca langsung dari kontrak (`jumlahTugas` dan `ambilTugas`).
- Tugas selesai ditampilkan dicoret dan dengan ikon centang hijau.
- Menambah tugas lewat formulir (mengirim transaksi `tambahTugas`).
- Menandai tugas selesai (mengirim transaksi `tandaiSelesai`). Tombol hanya muncul untuk tugas yang dibuat wallet yang sama, karena kontrak menolak selain pembuat.
- Indikator status transaksi: memproses, berhasil (dengan hash transaksi), dan gagal (dengan pesan error).
- Tombol refresh dan tarik-untuk-memuat-ulang.
- Alamat kontrak, RPC URL, dan chain ID dikelola di satu tempat: [`lib/config/app_config.dart`](lib/config/app_config.dart).

## Arsitektur

```
Aplikasi Flutter  ->  web3dart (HTTP RPC)  ->  Alchemy (Sepolia)  ->  Smart contract ChainTodo
```

```
chain_todo/
  contracts/ChainTodo.sol          kode smart contract
  assets/abi/ChainTodo.json        ABI kontrak
  lib/config/app_config.dart       alamat kontrak, chain ID, pembaca .env
  lib/models/tugas.dart            model data tugas
  lib/services/chain_todo_service.dart   koneksi dan pemanggilan kontrak
  lib/screens/add_todo_page.dart   halaman tambah tugas
  lib/main.dart                    halaman daftar tugas dan status transaksi
  .env.example                     contoh konfigurasi (tanpa isi rahasia)
```

## Cara menjalankan

### Prasyarat

- Flutter SDK (stabil), Android Studio atau VS Code, dan Git.
- Akun MetaMask **baru khusus tugas** (jangan memakai wallet pribadi) di jaringan **Sepolia**, dengan Sepolia ETH gratis dari faucet.
- Akun gratis Alchemy (atau Infura) dengan app untuk **Ethereum Sepolia**.

### Langkah

1. Clone repositori dan pasang dependensi:
   ```bash
   git clone https://github.com/anggitobdp/chain-todo.git
   cd chain-todo
   flutter pub get
   ```
2. Buat berkas `.env` dari contohnya:
   ```bash
   copy .env.example .env
   ```
   (di macOS atau Linux: `cp .env.example .env`)
3. Isi `.env` (berkas ini tidak masuk repositori):
   ```
   RPC_URL=https://eth-sepolia.g.alchemy.com/v2/API_KEY_KAMU
   PRIVATE_KEY=private_key_wallet_khusus_tugas
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run -d chrome
   ```
   atau sambungkan HP Android lalu jalankan `flutter run`.
5. Membuat APK:
   ```bash
   flutter build apk --release
   ```
   Hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Pengujian kontrak

Kontrak diuji lebih dulu di Remix VM sebelum di-deploy ke Sepolia:

- `tambahTugas("Tes 1")` menambah tugas dan `jumlahTugas` bertambah.
- `ambilTugas(0)` mengembalikan judul, status, waktu, dan alamat pembuat.
- `tandaiSelesai(0)` mengubah status menjadi selesai.
- Judul kosong ditolak ("Judul tidak boleh kosong").
- Id yang tidak ada ditolak ("Tugas tidak ada").
- Akun selain pembuat ditolak ("Bukan pembuat tugas").

## Keamanan

- Aplikasi hanya dipakai di **testnet Sepolia**. Tidak ada transaksi di mainnet dan tidak ada pembelian kripto.
- `PRIVATE_KEY` dan API key RPC hanya ada di `.env`, yang masuk `.gitignore`. Repositori hanya memuat `.env.example`.
- **Kompromi yang disadari:** karena `.env` didaftarkan sebagai asset Flutter, isinya ikut terbungkus di APK dan bisa diekstrak orang yang memegang APK-nya. Ini diterima hanya karena wallet-nya khusus tugas dan berisi ETH testnet tanpa nilai. Untuk aplikasi sungguhan, penandatanganan transaksi sebaiknya lewat dompet pengguna (misalnya WalletConnect/Reown) sehingga private key tidak pernah ada di aplikasi.
- Tidak ada data pribadi yang disimpan on-chain. Data di blockchain publik bersifat permanen dan dapat dibaca siapa saja.

## Sumber dan atribusi

- Kerangka kontrak `ChainTodo.sol` berasal dari dokumen tugas dosen.
- Alur koneksi Flutter ke kontrak diadaptasi dari video tutorial "Build Your First Blockchain Flutter App" dan "Building a Blockchain Decentralized App with Flutter and Dart on Ethereum", disesuaikan ke Sepolia dan `web3dart` 3.x.
- Dokumentasi: web3dart, Flutter, Remix IDE, dan Etherscan.

## Tautan luaran

- Video demo: https://drive.google.com/drive/folders/180d3uHWTPmWx7FYfZbg2jf9WbBeD6lZt
- APK: build\app\outputs\flutter-apk\app-release.apk
