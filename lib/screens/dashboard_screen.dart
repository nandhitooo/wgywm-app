import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
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
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _authService.userId;
    await _activityService.syncPending(uid);
    await _activityService.fetchFromFirestore(uid);
    final profile = await _authService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _userName = profile['displayName'] ?? profile['name'] ?? 'User';
      });
    }
  }

  List<Activity> get _todayActivities {
    final uid = _authService.userId;
    final now = DateTime.now();
    return _activityService
        .getAll(uid)
        .where((a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day)
        .toList();
  }

  List<double> get _weeklyCalories {
    final uid = _authService.userId;
    final all = _activityService.getAll(uid);
    final now = DateTime.now();
    List<double> weekly = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayActivities = all.where((a) =>
          a.date.year == day.year &&
          a.date.month == day.month &&
          a.date.day == day.day);
      weekly[i] = dayActivities.fold(0.0, (s, a) => s + a.calories);
    }
    return weekly;
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
          final weeklyCal = _weeklyCalories;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.orange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 24,
                    right: 24,
                    bottom: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(),
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  _authService.currentUser?.displayName ??
                                      _userName,
                                  style: GoogleFonts.bebasNeue(
                                      color: Colors.white,
                                      fontSize: 32,
                                      letterSpacing: 1)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatItem(
                                    value: '$cal',
                                    label: 'kCal',
                                    icon: Icons.local_fire_department),
                                Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withOpacity(0.2)),
                                _StatItem(
                                    value: _formatTime(min),
                                    label: 'Time',
                                    icon: Icons.timer),
                                Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.white.withOpacity(0.2)),
                                _StatItem(
                                    value: '$reps',
                                    label: 'Reps',
                                    icon: Icons.fitness_center),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WEEKLY PROGRESS',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 1)),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: _WeeklyChart(data: weeklyCal),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RECENT ACTIVITIES',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 1)),
                          Text('See All',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              today.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center,
                                size: 64,
                                color: AppTheme.gray.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text('No activities yet today.',
                                style: GoogleFonts.dmSans(
                                    color: AppTheme.gray,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ActivityCard(
                              activity: today[index], showToday: true),
                          childCount: today.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.bebasNeue(
                color: Colors.white, fontSize: 20, letterSpacing: 0.5)),
        Text(label,
            style: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCal = data.reduce((a, b) => a > b ? a : b);
    final limit = maxCal < 500 ? 500.0 : (maxCal * 1.2);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: limit,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final now = DateTime.now();
                final index = value.toInt();
                if (index < 0 || index >= 7) return const SizedBox();

                final dayDate = now.subtract(Duration(days: 6 - index));
                final dayLabel = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ][dayDate.weekday - 1];

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayLabel.substring(0, 1),
                    style: GoogleFonts.dmSans(
                      color: AppTheme.gray,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                gradient: LinearGradient(
                  colors: [AppTheme.orange, AppTheme.orange.withOpacity(0.6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 12,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: limit,
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
