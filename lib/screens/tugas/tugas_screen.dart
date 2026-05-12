import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../models/tugas_model.dart';
import '../../widgets/tugas_card.dart';
import 'tambah_tugas_screen.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});
  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final tugasProv = context.watch<TugasProvider>();
    final userId = auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: AppColors.primaryPurple,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Semua (${tugasProv.tugasList.length})'),
            Tab(text: 'Aktif (${tugasProv.tugasAktif.length})'),
            Tab(text: 'Selesai (${tugasProv.tugasSelesai.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(tugasProv.tugasList, tugasProv, userId),
          _buildList(tugasProv.tugasAktif, tugasProv, userId),
          _buildList(tugasProv.tugasSelesai, tugasProv, userId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TambahTugasScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildList(List<TugasModel> tugas, TugasProvider prov, String userId) {
    if (tugas.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.task_alt, size: 64, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textHint),
          const SizedBox(height: 12),
          Text('Belum ada tugas', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textHint)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tugas.length,
      itemBuilder: (context, index) {
        final t = tugas[index];
        return TugasCard(
          tugas: t,
          onToggle: () => prov.toggleStatus(userId, t.id),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TambahTugasScreen(tugas: t))),
          onDelete: () => _confirmDelete(userId, t, prov),
        );
      },
    );
  }

  void _confirmDelete(String userId, TugasModel t, TugasProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Hapus tugas "${t.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(onPressed: () { prov.deleteTugas(userId, t.id); Navigator.pop(ctx); }, child: const Text('Hapus', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
