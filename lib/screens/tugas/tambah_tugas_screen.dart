import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/tugas_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class TambahTugasScreen extends StatefulWidget {
  final TugasModel? tugas;
  const TambahTugasScreen({super.key, this.tugas});
  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  Prioritas _prioritas = Prioritas.sedang;

  bool get _isEditing => widget.tugas != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _judulController.text = widget.tugas!.judul;
      _deskripsiController.text = widget.tugas!.deskripsi;
      _deadline = widget.tugas!.deadline;
      _prioritas = widget.tugas!.prioritas;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null && mounted) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_deadline));
      if (time != null) {
        setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final tugasProv = context.read<TugasProvider>();
    final userId = auth.currentUser!.id;

    final tugas = TugasModel(
      id: widget.tugas?.id ?? '',
      userId: userId,
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      deadline: _deadline,
      prioritas: _prioritas,
      status: widget.tugas?.status ?? StatusTugas.aktif,
    );

    if (_isEditing) {
      await tugasProv.updateTugas(userId, tugas);
    } else {
      await tugasProv.addTugas(userId, tugas);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing ? 'Tugas berhasil diupdate' : 'Tugas berhasil ditambahkan'),
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Tugas' : 'Tambah Tugas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(controller: _judulController, labelText: 'Judul Tugas', hintText: 'Contoh: Tugas Basis Data', prefixIcon: Icons.assignment_outlined, validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _deskripsiController, labelText: 'Deskripsi', hintText: 'Deskripsi tugas (opsional)', prefixIcon: Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 16),

              // Deadline
              Text('Deadline', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('dd MMMM yyyy, HH:mm').format(_deadline), style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Priority
              Text('Prioritas', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: Prioritas.values.map((p) {
                  final isSelected = _prioritas == p;
                  final color = p == Prioritas.tinggi ? AppColors.priorityHigh : p == Prioritas.sedang ? AppColors.priorityMedium : AppColors.priorityLow;
                  final label = p == Prioritas.tinggi ? 'Tinggi' : p == Prioritas.sedang ? 'Sedang' : 'Rendah';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: p != Prioritas.rendah ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _prioritas = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? AppColors.darkSurface : AppColors.white),
                            border: Border.all(color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.border), width: isSelected ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(label, style: TextStyle(color: isSelected ? color : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14))),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              CustomButton(text: _isEditing ? 'Update Tugas' : 'Simpan Tugas', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
