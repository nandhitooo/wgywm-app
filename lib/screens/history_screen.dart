import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Map<String, List<Activity>> _groupByDate(List<Activity> activities) {
    final map = <String, List<Activity>>{};
    for (final a in activities) {
      final key = DateFormat('MMMM d, yyyy').format(a.date);
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  // Dialog edit aktivitas
  void _showEditDialog(BuildContext context, Activity activity) {
    final namCtrl = TextEditingController(text: activity.name);
    final durCtrl =
        TextEditingController(text: activity.durationMinutes.toString());
    final calCtrl = TextEditingController(text: activity.calories.toString());
    final repsCtrl = TextEditingController(text: activity.reps.toString());
    final actSvc = ActivityService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Aktivitas',
            style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 1)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namCtrl,
                decoration: const InputDecoration(labelText: 'Nama Workout'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Durasi (menit)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kalori'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Reps (0 jika tidak ada)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Batal', style: GoogleFonts.dmSans(color: AppTheme.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namCtrl.text.trim().isEmpty) return;
              // Update data di Hive
              activity.name = namCtrl.text.trim();
              activity.durationMinutes =
                  int.tryParse(durCtrl.text) ?? activity.durationMinutes;
              activity.calories =
                  int.tryParse(calCtrl.text) ?? activity.calories;
              activity.reps = int.tryParse(repsCtrl.text) ?? activity.reps;
              activity.synced = false;
              await activity.save();
              // Sync ke Firestore
              await actSvc.syncPending(AuthService().userId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: Text('Simpan', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi hapus
  void _showDeleteDialog(BuildContext context, Activity activity) {
    final actSvc = ActivityService();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Aktivitas',
            style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 1)),
        content: Text(
          'Hapus "${activity.name}"?\nData tidak bisa dikembalikan.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Batal', style: GoogleFonts.dmSans(color: AppTheme.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await actSvc.delete(activity);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              minimumSize: const Size(80, 40),
            ),
            child: Text('Hapus', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actSvc = ActivityService();
    final uid = AuthService().userId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder(
        stream: actSvc.watchBox,
        builder: (context, _) {
          final activities = actSvc.getAll(uid);
          final grouped = _groupByDate(activities);
          final now = DateFormat('MMMM d, yyyy').format(DateTime.now());
          final yesterday = DateFormat('MMMM d, yyyy')
              .format(DateTime.now().subtract(const Duration(days: 1)));

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppTheme.orange,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your workout log',
                        style: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('HISTORY ACTIVITIES',
                        style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 30,
                            letterSpacing: 2)),
                  ],
                ),
              ),

              // List
              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history,
                                size: 56,
                                color: AppTheme.gray.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('Belum ada aktivitas.',
                                style:
                                    GoogleFonts.dmSans(color: AppTheme.gray)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: grouped.entries.map((entry) {
                          final isToday = entry.key == now;
                          final isYesterday = entry.key == yesterday;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10, top: 4),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.gray,
                                      letterSpacing: 0.8),
                                ),
                              ),
                              ...entry.value.map((a) => _ActivityCard(
                                    activity: a,
                                    isToday: isToday,
                                    isYesterday: isYesterday,
                                    onEdit: () => _showEditDialog(context, a),
                                    onDelete: () =>
                                        _showDeleteDialog(context, a),
                                  )),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Card dengan swipe gesture untuk edit/hapus
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isToday;
  final bool isYesterday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.isToday,
    required this.isYesterday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String label = '';
    bool labelOrange = false;
    if (isToday) {
      label = 'Today';
      labelOrange = true;
    } else if (isYesterday) {
      label = 'Yesterday';
    }

    return Dismissible(
      key: Key(activity.id),
      // Swipe kanan → Edit (orange)
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.white),
            const SizedBox(width: 8),
            Text('Edit',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // Swipe kiri → Hapus (merah)
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Hapus',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            const Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe kanan → buka dialog edit, jangan dismiss
          onEdit();
          return false;
        } else {
          // Swipe kiri → konfirmasi hapus
          onDelete();
          return false;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.name,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 3),
                  Text(
                    activity.reps > 0
                        ? '${activity.durationMinutes} min · ${activity.calories} cal · ${activity.reps} reps'
                        : '${activity.durationMinutes} min · ${activity.calories} cal',
                    style:
                        GoogleFonts.dmSans(fontSize: 11, color: AppTheme.gray),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (label.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: labelOrange ? AppTheme.orange : Theme.of(context).brightness == Brightness.dark ? Colors.white10 : AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(label,
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: labelOrange ? Colors.white : AppTheme.gray)),
                  ),
                // Tombol edit & hapus
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.edit_outlined,
                        size: 18, color: AppTheme.orange),
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline,
                        size: 18, color: Colors.red.shade400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
