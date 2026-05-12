import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class TambahJadwalScreen extends StatefulWidget {
  final JadwalModel? jadwal;
  final String? defaultHari;
  const TambahJadwalScreen({super.key, this.jadwal, this.defaultHari});
  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matkulController = TextEditingController();
  final _dosenController = TextEditingController();
  final _ruanganController = TextEditingController();
  final _catatanController = TextEditingController();
  String _selectedHari = 'Senin';
  TimeOfDay _jamMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamSelesai = const TimeOfDay(hour: 9, minute: 40);

  bool get _isEditing => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final j = widget.jadwal!;
      _matkulController.text = j.namaMatkul;
      _dosenController.text = j.namaDosen;
      _ruanganController.text = j.ruangan;
      _catatanController.text = j.catatan;
      _selectedHari = j.hari;
      final mulaiParts = j.jamMulai.split(':');
      _jamMulai = TimeOfDay(hour: int.parse(mulaiParts[0]), minute: int.parse(mulaiParts[1]));
      final selesaiParts = j.jamSelesai.split(':');
      _jamSelesai = TimeOfDay(hour: int.parse(selesaiParts[0]), minute: int.parse(selesaiParts[1]));
    } else if (widget.defaultHari != null) {
      _selectedHari = widget.defaultHari!;
    }
  }

  @override
  void dispose() {
    _matkulController.dispose();
    _dosenController.dispose();
    _ruanganController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _jamMulai : _jamSelesai);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final jadwalProv = context.read<JadwalProvider>();
    final userId = auth.currentUser!.id;

    final jadwal = JadwalModel(
      id: widget.jadwal?.id ?? '',
      userId: userId,
      namaMatkul: _matkulController.text.trim(),
      namaDosen: _dosenController.text.trim(),
      hari: _selectedHari,
      jamMulai: _formatTime(_jamMulai),
      jamSelesai: _formatTime(_jamSelesai),
      ruangan: _ruanganController.text.trim(),
      catatan: _catatanController.text.trim(),
    );

    if (_isEditing) {
      await jadwalProv.updateJadwal(userId, jadwal);
    } else {
      await jadwalProv.addJadwal(userId, jadwal);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Jadwal berhasil diupdate' : 'Jadwal berhasil ditambahkan'),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(controller: _matkulController, labelText: 'Nama Mata Kuliah', hintText: 'Contoh: Basis Data', prefixIcon: Icons.book_outlined, validator: (v) => v == null || v.isEmpty ? 'Nama matkul wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _dosenController, labelText: 'Nama Dosen', hintText: 'Contoh: Dr. Budi', prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),

              // Hari dropdown
              Text('Hari', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedHari,
                items: JadwalModel.hariList.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: (v) => setState(() => _selectedHari = v!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today, size: 20)),
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Jam Mulai', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                            color: isDark ? AppColors.darkSurface : AppColors.white,
                          ),
                          child: Row(children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(_formatTime(_jamMulai), style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Jam Selesai', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                            color: isDark ? AppColors.darkSurface : AppColors.white,
                          ),
                          child: Row(children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(_formatTime(_jamSelesai), style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(controller: _ruanganController, labelText: 'Ruangan', hintText: 'Contoh: A204', prefixIcon: Icons.location_on_outlined),
              const SizedBox(height: 16),
              CustomTextField(controller: _catatanController, labelText: 'Catatan', hintText: 'Catatan tambahan (opsional)', prefixIcon: Icons.note_outlined, maxLines: 3),
              const SizedBox(height: 32),
              CustomButton(text: _isEditing ? 'Update Jadwal' : 'Simpan Jadwal', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
