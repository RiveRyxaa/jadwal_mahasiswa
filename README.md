<div align="center">
  <img src="assets/banner.png" />
  <br><br>
  
  [![Android](https://img.shields.io/badge/Platform-Android_Native-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)
  [![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](#)
  [![Provider](https://img.shields.io/badge/State_Management-Provider-8A2BE2?style=for-the-badge)](#)
  [![Firebase](https://img.shields.io/badge/Auth-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](#)
  [![Storage](https://img.shields.io/badge/Storage-Offline_First-4A4A55?style=for-the-badge)](#)
</div>

# 🎓 SobatKuliah (Smart College Schedule & Productivity)

[cite_start]**SobatKuliah** adalah aplikasi *mobile* cerdas berbasis Android yang dirancang khusus untuk meningkatkan produktivitas mahasiswa universitas[cite: 10, 12, 14]. [cite_start]Aplikasi ini hadir sebagai asisten pribadi untuk mengatur jadwal kuliah mingguan dan tenggat waktu tugas secara efisien[cite: 20, 21, 22]. [cite_start]Dibangun dengan pendekatan *Offline-First*, aplikasi ini memberikan performa secepat kilat sambil tetap menjaga notifikasi pengingat berjalan secara presisi di latar belakang[cite: 23, 28].

---

### ✨ Fitur Unggulan (MVP v1.0.0)

<table align="center">
  <tr>
    <td width="50%">
      <h4>🔐 Autentikasi Multijalur</h4>
      [cite_start]Sistem keamanan berlapis menggunakan <strong>Firebase Auth</strong>[cite: 32]. [cite_start]Mendukung <em>Login/Register</em> standar, <strong>Google Sign-In</strong> untuk akses instan, dan alur pemulihan <em>password</em> otomatis via Firebase SMTP yang masuk ke kotak masuk utama[cite: 35, 36, 37, 38, 49, 50].
    </td>
    <td width="50%">
      <h4>📊 Dashboard & Analitik Pintar</h4>
      [cite_start]Beranda interaktif yang menampilkan <em>countdown</em> presisi menuju kelas berikutnya[cite: 55]. [cite_start]Dilengkapi dengan <em>badge</em> status <strong>"SEDANG BERLANGSUNG"</strong> untuk kelas yang aktif, serta kalkulasi statistik IPK dan tugas selesai[cite: 56, 58, 77].
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h4>🔔 Advanced Background Services</h4>
      [cite_start]Sistem notifikasi <em>push</em> yang beroperasi penuh di latar belakang menggunakan <code>flutter_local_notifications</code>[cite: 110, 112]. [cite_start]Jadwal akan diingatkan 15 menit dan tepat waktu sebelum kelas dimulai[cite: 114, 115]. [cite_start]Alarm tugas terpicu 1 hari, 3 jam, dan 1 jam sebelum tenggat waktu[cite: 118, 119, 120].
    </td>
    <td width="50%">
      <h4>📝 Prioritas Tugas & Jadwal</h4>
      Manajemen jadwal mingguan (Senin-Sabtu) dan <em>Tracker</em> Tugas dengan label prioritas visual (Tinggi, Sedang, Rendah)[cite: 75, 82, 89, 97, 100]. Sistem menggunakan <em>Date/Time Picker</em> dinamis untuk fleksibilitas maksimal[cite: 83, 84, 95].
    </td>
  </tr>
</table>

---

### 🎨 Desain UI/UX Premium
[cite_start]Antarmuka pengguna (UI) dirancang dengan konsep modern dan premium, mengadopsi elemen *Glassmorphism* dan transisi animasi yang halus[cite: 151, 152, 154, 155].
* [cite_start]**Tema Warna:** Dominasi warna utama Ungu (`#6C63FF`) dan Navy (`#1B365D`)[cite: 423, 424].
* [cite_start]**Aksesibilitas:** Mendukung peralihan penuh antara **Mode Terang** dan **Mode Gelap**[cite: 138, 146].
* [cite_start]**Tipografi:** Menggunakan <em>Google Fonts: Inter</em> dengan dukungan Bahasa Indonesia secara menyeluruh[cite: 156, 157].

---

### 🛠️ Arsitektur Teknis & Permissions
[cite_start]Proyek ini mengimplementasikan pemisahan logika (*separation of concerns*) yang ketat antara *UI (Screens)*, *State (Providers)*, *Data (Models)*, dan *Services*[cite: 340, 344, 348, 353, 372].

**Penyimpanan Data Lokal (SharedPreferences):**
[cite_start]Data jadwal, tugas, dan profil disimpan dalam format *JSON encoding* secara lokal (`shared_preferences`), memastikan aplikasi dapat diakses tanpa koneksi internet sama sekali[cite: 204, 205].

**Android Native Integrations:**
* [cite_start]`POST_NOTIFICATIONS`: Izin spesifik untuk Android 13+[cite: 125, 445].
* [cite_start]`SCHEDULE_EXACT_ALARM`: Penjadwalan akurat tingkat OS[cite: 124, 447].
* [cite_start]`RECEIVE_BOOT_COMPLETED`: Memanfaatkan `ScheduledNotificationBootReceiver` agar sistem notifikasi otomatis menyala kembali setelah perangkat Android di-*restart*[cite: 123, 446, 452].

---

### 🚀 Roadmap Pengembangan
- [x] [cite_start]**Phase 1:** Integrasi Firebase Auth (Email & Google) & Konfigurasi SMTP[cite: 389, 392, 393, 394].
- [x] [cite_start]**Phase 2:** CRUD Jadwal Kuliah & Dashboard Statistik[cite: 395, 397, 398, 399].
- [x] [cite_start]**Phase 3:** *Tracker* Tugas Prioritas & Notifikasi *Push* Latar Belakang[cite: 400, 402, 403].
- [x] [cite_start]**Phase 4:** Mode Gelap/Terang, *Glassmorphism UI*, Lokalisasi ID[cite: 406, 408, 409, 410].
- [ ] [cite_start]**Phase 5 (Segera Hadir):** AI Assistant Jadwal, Pemindai Jadwal via Foto, dan Sinkronisasi *Cloud*[cite: 413, 415, 416, 417].

---
<div align="center">
  <i>Dikembangkan menggunakan Flutter dengan mengutamakan logika performa dan estetika desain.</i><br>
  [cite_start]<b>Siap untuk rilis di Google Play Store.</b> [cite: 418, 461]
</div>