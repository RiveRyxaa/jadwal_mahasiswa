import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../widgets/jadwal_card.dart';
import 'tambah_jadwal_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _days = JadwalModel.hariList;

  @override
  void initState() {
    super.initState();
    // Default to today's day tab
    final todayIndex = DateTime.now().weekday - 1; // 0=Monday
    _tabController = TabController(length: _days.length, vsync: this, initialIndex: todayIndex.clamp(0, 5));
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
    final jadwalProv = context.watch<JadwalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: AppColors.primaryPurple,
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) {
          final dayJadwal = jadwalProv.getJadwalByHari(day);
          if (dayJadwal.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.event_note, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                const SizedBox(height: 12),
                Text('Tidak ada jadwal di hari $day', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textHint)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _navigateToAdd(day),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Jadwal'),
                ),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dayJadwal.length,
            itemBuilder: (context, index) {
              final j = dayJadwal[index];
              return JadwalCard(
                jadwal: j,
                onTap: () => _navigateToEdit(j),
                onDelete: () => _confirmDelete(auth.currentUser!.id, j),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(_days[_tabController.index]),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  void _navigateToAdd(String hari) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TambahJadwalScreen(defaultHari: hari)));
  }

  void _navigateToEdit(JadwalModel jadwal) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TambahJadwalScreen(jadwal: jadwal)));
  }

  void _confirmDelete(String userId, JadwalModel jadwal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Hapus jadwal ${jadwal.namaMatkul}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<JadwalProvider>().deleteJadwal(userId, jadwal.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
