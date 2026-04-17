import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/activity_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _actSvc = ActivityService();
  bool _uploadingPhoto = false;
  bool _savingName = false;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _auth.getProfile().then((data) {
      if (data != null && mounted) {
        setState(() => _photoBase64 = data['photoBase64']);
      }
    });
  }

  void _editName() {
    final ctrl =
        TextEditingController(text: _auth.currentUser?.displayName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubah Nama',
            style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 1)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Batal', style: GoogleFonts.dmSans(color: AppTheme.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              setState(() => _savingName = true);
              await _auth.updateName(ctrl.text.trim());
              if (mounted) setState(() => _savingName = false);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: Text('Simpan', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  void _pickPhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Pilih Foto Profil',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppTheme.orange),
              ),
              title: Text('Pilih dari Galeri',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _uploadPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppTheme.orange),
              ),
              title: Text('Buka Kamera',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _uploadPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 50, maxWidth: 300);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await _auth.updatePhoto(File(picked.path));
      if (mounted) setState(() => _photoBase64 = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e', style: GoogleFonts.dmSans()),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Widget _avatarFallback(String initials) {
    return Container(
      color: Colors.white.withOpacity(0.3),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.bebasNeue(
                color: Colors.white, fontSize: 28, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final activities = _actSvc.getAll(_auth.userId);
    final totalCal = activities.fold(0, (s, a) => s + a.calories);
    final totalMin = activities.fold(0, (s, a) => s + a.durationMinutes);
    final initials = (user?.displayName ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    final now = DateTime.now();
    final weekCal = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return activities
          .where((a) =>
              a.date.year == day.year &&
              a.date.month == day.month &&
              a.date.day == day.day)
          .fold(0, (s, a) => s + a.calories)
          .toDouble();
    });

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          // Header orange
          Container(
            width: double.infinity,
            color: AppTheme.orange,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6), width: 3),
                      ),
                      child: ClipOval(
                        child: _uploadingPhoto
                            ? Container(
                                color: Colors.white.withOpacity(0.3),
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : _photoBase64 != null
                                ? Image.memory(
                                    base64Decode(_photoBase64!.split(',').last),
                                    fit: BoxFit.cover,
                                  )
                                : _avatarFallback(initials),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: AppTheme.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Nama + edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _savingName
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            user?.displayName ?? 'User',
                            style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 26,
                                letterSpacing: 1),
                          ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _editName,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.75), fontSize: 12),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('YOUR PROGRESS',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.dark,
                        letterSpacing: 0.8)),
                const SizedBox(height: 10),

                // Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kalori 7 Hari Terakhir',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.dark)),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 120,
                        child: BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (weekCal.isEmpty
                                  ? 200
                                  : weekCal.reduce((a, b) => a > b ? a : b) +
                                      100)
                              .clamp(200, 1000)
                              .toDouble(),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, _) {
                                  const days = [
                                    'Sen',
                                    'Sel',
                                    'Rab',
                                    'Kam',
                                    'Jum',
                                    'Sab',
                                    'Min'
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(days[val.toInt()],
                                        style: GoogleFonts.dmSans(
                                            fontSize: 9, color: AppTheme.gray)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(
                              7,
                              (i) => BarChartGroupData(x: i, barRods: [
                                    BarChartRodData(
                                      toY: weekCal[i],
                                      color: i == 6
                                          ? AppTheme.orange
                                          : const Color(0xFFFAD38F),
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(5)),
                                    )
                                  ])),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Stats
                Row(
                  children: [
                    _StatCard(value: '${activities.length}', label: 'Workouts'),
                    const SizedBox(width: 10),
                    _StatCard(value: '$totalCal', label: 'Total Cal'),
                    const SizedBox(width: 10),
                    _StatCard(
                        value: '${(totalMin / 60).toStringAsFixed(1)}h',
                        label: 'Total Waktu'),
                  ],
                ),
                const SizedBox(height: 14),

                // Logout
                OutlinedButton(
                  onPressed: () async {
                    await _auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.orange,
                    side: const BorderSide(color: AppTheme.orange),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('LOGOUT',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.bebasNeue(
                    fontSize: 24, color: AppTheme.dark, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.gray)),
          ],
        ),
      ),
    );
  }
}
