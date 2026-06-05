import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../widgets/activity_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _activityService = ActivityService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Sync pending data dan fetch dari Firestore saat buka app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = _authService.userId;
      await _activityService.syncPending(uid);
      await _activityService.fetchFromFirestore(uid);
      if (mounted) setState(() {});
    });
  }

  List<Activity> get _todayActivities {
    final uid = _authService.userId;
    final now = DateTime.now();
    return _activityService.getAll(uid).where((a) =>
        a.date.year == now.year &&
        a.date.month == now.month &&
        a.date.day == now.day).toList();
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder(
        stream: _activityService.watchBox,
        builder: (context, _) {
          final today = _todayActivities;
          final cal = today.fold(0, (s, a) => s + a.calories);
          final min = today.fold(0, (s, a) => s + a.durationMinutes);
          final reps = today.fold(0, (s, a) => s + a.reps);

          return Column(
            children: [
              Container(
                width: double.infinity, 
                color: AppTheme.orange,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20, right: 20, bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Summary",
                        style: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('DASHBOARD',
                        style: GoogleFonts.bebasNeue(
                            color: Colors.white, fontSize: 30, letterSpacing: 2)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _StatCard(value: '$cal', label: 'Cal Burned'),
                        const SizedBox(width: 10),
                        _StatCard(value: _formatTime(min), label: 'Workout Time'),
                        const SizedBox(width: 10),
                        _StatCard(value: '$reps', label: 'Reps'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: today.isEmpty
                    ? Center(
                        child: Text('Belum ada aktivitas hari ini.',
                            style: GoogleFonts.dmSans(color: AppTheme.gray)))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text('RECENT ACTIVITIES',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          ...today.map((a) => ActivityCard(activity: a, showToday: true)),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.bebasNeue(
                color: Colors.white, fontSize: 22, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.75), fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
