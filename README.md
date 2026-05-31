<div align="center">
  <img src="assets/banner.png" width="100%" alt="SobatKuliah Banner" />
  <br><br>
  
  [![Android](https://img.shields.io/badge/Platform-Android_Native-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)
  [![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](#)
  [![Provider](https://img.shields.io/badge/State_Management-Provider-8A2BE2?style=for-the-badge)](#)
  [![Firebase](https://img.shields.io/badge/Auth-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](#)
  [![Storage](https://img.shields.io/badge/Storage-Offline_First-4A4A55?style=for-the-badge)](#)
</div>

# 🎓 SobatKuliah (Smart College Schedule & Productivity)

**SobatKuliah** adalah aplikasi *mobile* cerdas berbasis Android yang dirancang khusus untuk meningkatkan produktivitas mahasiswa universitas. Aplikasi ini hadir sebagai asisten pribadi untuk mengatur jadwal kuliah mingguan dan tenggat waktu tugas secara efisien. Dibangun dengan pendekatan *Offline-First*, aplikasi ini memberikan performa secepat kilat sambil tetap menjaga notifikasi pengingat berjalan secara presisi di latar belakang.

---

### ✨ Fitur Unggulan (MVP v1.0.0)

<table align="center">
  <tr>
    <td width="50%">
      <h4>🔐 Autentikasi Multijalur</h4>
      Sistem keamanan berlapis menggunakan <strong>Firebase Auth</strong>. Mendukung <em>Login/Register</em> standar, <strong>Google Sign-In</strong> untuk akses instan, dan alur pemulihan <em>password</em> otomatis via Firebase SMTP yang masuk ke kotak masuk utama.
    </td>
    <td width="50%">
      <h4>📊 Dashboard & Analitik Pintar</h4>
      Beranda interaktif yang menampilkan <em>countdown</em> presisi menuju kelas berikutnya. Dilengkapi dengan <em>badge</em> status <strong>"SEDANG BERLANGSUNG"</strong> untuk kelas yang aktif, serta kalkulasi statistik IPK dan tugas selesai.
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h4>🔔 Advanced Background Services</h4>
      Sistem notifikasi <em>push</em> yang beroperasi penuh di latar belakang menggunakan <code>flutter_local_notifications</code>. Jadwal akan diingatkan 15 menit dan tepat waktu sebelum kelas dimulai. Alarm tugas terpicu 1 hari, 3 jam, dan 1 jam sebelum tenggat waktu.
    </td>
    <td width="50%">
      <h4>📝 Prioritas Tugas & Jadwal</h4>
      Manajemen jadwal mingguan (Senin-Sabtu) dan <em>Tracker</em> Tugas dengan label prioritas visual (Tinggi, Sedang, Rendah). Sistem menggunakan <em>Date/Time Picker</em> dinamis untuk fleksibilitas maksimal.
    </td>
  </tr>
</table>

---

### 🎨 Desain UI/UX Premium
Antarmuka pengguna (UI) dirancang dengan konsep modern dan premium, mengadopsi elemen *Glassmorphism* dan transisi animasi yang halus.
* **Tema Warna:** Dominasi warna utama Ungu (`#6C63FF`) dan Navy (`#1B365D`).
* **Aksesibilitas:** Mendukung peralihan penuh antara **Mode Terang** dan **Mode Gelap**.
* **Tipografi:** Menggunakan <em>Google Fonts: Inter</em> dengan dukungan Bahasa Indonesia secara menyeluruh.

---

### 🛠️ Arsitektur Teknis & Permissions
Proyek ini mengimplementasikan pemisahan logika (*separation of concerns*) yang ketat antara *UI (Screens)*, *State (Providers)*, *Data (Models)*, dan *Services*.

**Penyimpanan Data Lokal (SharedPreferences):**
Data jadwal, tugas, dan profil disimpan dalam format *JSON encoding* secara lokal (`shared_preferences`), memastikan aplikasi dapat diakses tanpa koneksi internet sama sekali.

**Android Native Integrations:**
* `POST_NOTIFICATIONS`: Izin spesifik untuk Android 13+.
* `SCHEDULE_EXACT_ALARM`: Penjadwalan akurat tingkat OS.
* `RECEIVE_BOOT_COMPLETED`: Memanfaatkan `ScheduledNotificationBootReceiver` agar sistem notifikasi otomatis menyala kembali setelah perangkat Android di-*restart*.

---

### 🚀 Roadmap Pengembangan
- [x] **Phase 1:** Integrasi Firebase Auth (Email & Google) & Konfigurasi SMTP.
- [x] **Phase 2:** CRUD Jadwal Kuliah & Dashboard Statistik.
- [x] **Phase 3:** *Tracker* Tugas Prioritas & Notifikasi *Push* Latar Belakang.
- [x] **Phase 4:** Mode Gelap/Terang, *Glassmorphism UI*, Lokalisasi ID.
- [ ] **Phase 5 (Segera Hadir):** AI Assistant Jadwal, Pemindai Jadwal via Foto, dan Sinkronisasi *Cloud*.

---
<div align="center">
  <i>Dikembangkan menggunakan Flutter dengan mengutamakan logika performa dan estetika desain.</i><br>
  <b>by Rivegoodboy.</b>
</div>