import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/activity_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import 'package:wgym/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _actSvc = ActivityService();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _uploadingPhoto = false;
  bool _savingName = false;
  bool _savingProfile = false;
  String? _photoBase64;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _auth.getProfile().then((data) {
      if (data != null && mounted) {
        DateTime? birthDate;
        final birthValue = data['birthDate'];
        if (birthValue is DateTime) {
          birthDate = birthValue;
        } else if (birthValue is String) {
          birthDate = DateTime.tryParse(birthValue);
        } else if (birthValue is Timestamp) {
          birthDate = birthValue.toDate();
        }

        setState(() {
          _photoBase64 = data['photoBase64'];
          _photoUrl = data['photoUrl'];
          _birthDate = birthDate;
          _weightCtrl.text = data['weight']?.toString() ?? '';
          _heightCtrl.text = data['height']?.toString() ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String get _birthDateText {
    final l10n = AppLocalizations.of(context)!;
    if (_birthDate == null) {
      return l10n.pickBirthDate;
    }
    final y = _birthDate!.year.toString();
    final m = _birthDate!.month.toString().padLeft(2, '0');
    final d = _birthDate!.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  int get _age {
    if (_birthDate == null) return 0;
    final today = DateTime.now();
    var age = today.year - _birthDate!.year;
    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age -= 1;
    }
    return age;
  }

  Future<void> _pickBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.orange),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _birthDate = selected);
    }
  }

  Future<void> _saveProfileDetails() async {
    final l10n = AppLocalizations.of(context)!;

    if (_birthDate == null) {
      _showSnack(l10n.pickBirthDate, isError: true);
      return;
    }
    if (_weightCtrl.text.trim().isEmpty) {
      _showSnack(l10n.allFieldsRequired, isError: true);
      return;
    }
    if (_heightCtrl.text.trim().isEmpty) {
      _showSnack(l10n.allFieldsRequired, isError: true);
      return;
    }

    setState(() => _savingProfile = true);
    try {
      await _auth.updateProfileData({
        'birthDate': _birthDate!.toIso8601String(),
        'weight': _weightCtrl.text.trim(),
        'height': _heightCtrl.text.trim(),
      });
      if (mounted) {
        _showSnack(l10n.activitySaved);
      }
    } catch (e) {
      _showSnack('${l10n.failedToSave}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _editName() {
    final l10n = AppLocalizations.of(context)!;
    final ctrl =
        TextEditingController(text: _auth.currentUser?.displayName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.changeName,
            style: GoogleFonts.bebasNeue(fontSize: 20, letterSpacing: 1)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.newName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: GoogleFonts.dmSans(color: AppTheme.gray)),
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
            child: Text(l10n.save, style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  void _pickPhoto() {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.pickProfilePhoto,
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
              title: Text(l10n.pickFromGallery,
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
              title: Text(l10n.openCamera,
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
      if (mounted) {
        setState(() {
          _photoBase64 = url;
          _photoUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('$e', isError: true);
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

  double get _bmi {
    if (_birthDate == null ||
        _weightCtrl.text.isEmpty ||
        _heightCtrl.text.isEmpty) {
      return 0;
    }
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final height = double.tryParse(_heightCtrl.text) ?? 0;
    if (weight <= 0 || height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String get _bmiStatus {
    if (_bmi == 0) return '-';
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    if (_bmi == 0) return AppTheme.gray;
    if (_bmi < 18.5) return Colors.blue;
    if (_bmi < 25) return Colors.green;
    if (_bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final activities = _actSvc.getAll(_auth.userId);
    final totalCal = activities.fold(0, (s, a) => s + a.calories);
    final totalMin = activities.fold(0, (s, a) => s + a.durationMinutes);
    final l10n = AppLocalizations.of(context)!;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.orange, AppTheme.orange.withOpacity(0.85)],
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.orange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 20,
                right: 20,
                bottom: 32),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.7), width: 4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 2)
                        ],
                      ),
                      child: ClipOval(
                        child: _uploadingPhoto
                            ? Container(
                                color: Colors.white.withOpacity(0.3),
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : (_photoBase64 != null && _photoBase64!.isNotEmpty)
                                ? Image.memory(
                                    base64Decode(_photoBase64!.split(',').last),
                                    fit: BoxFit.cover)
                                : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                    ? Image.network(_photoUrl!,
                                        fit: BoxFit.cover)
                                    : _avatarFallback(initials),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8)
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 16, color: AppTheme.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _savingName
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            user?.displayName ?? 'User',
                            style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 28,
                                letterSpacing: 1.2),
                          ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _editName,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildSectionTitle(l10n.profileDetails.toUpperCase()),
                const SizedBox(height: 12),
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.birthDate,
                          style: GoogleFonts.dmSans(
                              color: AppTheme.gray,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickBirthDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                                width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16, color: AppTheme.orange),
                              const SizedBox(width: 10),
                              Text(_birthDateText,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: _birthDate == null
                                          ? AppTheme.gray
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.age,
                                    style: GoogleFonts.dmSans(
                                        color: AppTheme.gray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF2C2C2C)
                                        : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.1),
                                        width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 16, color: AppTheme.orange),
                                      const SizedBox(width: 10),
                                      Text(
                                        _birthDate == null
                                            ? '-'
                                            : '$_age ${l10n.years}',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l10n.weight} (kg)',
                                    style: GoogleFonts.dmSans(
                                        color: AppTheme.gray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                _buildInputField(_weightCtrl, '70',
                                    Icons.monitor_weight_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('${l10n.height} (cm)',
                          style: GoogleFonts.dmSans(
                              color: AppTheme.gray,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _buildInputField(
                          _heightCtrl, '170', Icons.straighten_outlined),
                      const SizedBox(height: 18),
                      if (_bmi > 0)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _bmiColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: _bmiColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('BMI',
                                      style: GoogleFonts.dmSans(
                                          color: AppTheme.gray,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _bmi.toStringAsFixed(1),
                                    style: GoogleFonts.bebasNeue(
                                        fontSize: 20,
                                        color: _bmiColor,
                                        letterSpacing: 1),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _bmiColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _bmiStatus,
                                  style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      _buildSaveButton(l10n),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _buildSectionTitle(l10n.yourProgress.toUpperCase()),
                const SizedBox(height: 12),
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.caloriesLast7Days,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('kcal',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.orange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
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
                                  final day = now.subtract(
                                      Duration(days: 6 - val.toInt()));
                                  final dayLabel = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ][day.weekday - 1];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(dayLabel.substring(0, 1),
                                        style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            color: AppTheme.gray,
                                            fontWeight: FontWeight.w500)),
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
                                          : AppTheme.orange.withOpacity(0.4),
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                    )
                                  ])),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _EnhancedStatCard(
                      icon: Icons.fitness_center_outlined,
                      value: '${activities.length}',
                      label: 'Workouts',
                      color: AppTheme.orange,
                    ),
                    const SizedBox(width: 10),
                    _EnhancedStatCard(
                      icon: Icons.local_fire_department_outlined,
                      value: '$totalCal',
                      label: l10n.kCal,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 10),
                    _EnhancedStatCard(
                      icon: Icons.schedule_outlined,
                      value: '${(totalMin / 60).toStringAsFixed(1)}h',
                      label: 'Duration',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildSectionTitle(l10n.settings.toUpperCase()),
                const SizedBox(height: 12),
                _buildModernCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            ThemeService.isDarkMode
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: AppTheme.orange,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          l10n.darkMode,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing: Switch(
                          value: ThemeService.isDarkMode,
                          activeThumbColor: AppTheme.orange,
                          onChanged: (val) {
                            ThemeService.toggleTheme();
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(height: 1),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.language_outlined,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          l10n.changeLanguage,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<Locale>(
                                valueListenable: LanguageService.localeNotifier,
                                builder: (context, locale, _) {
                                  return Text(
                                    locale.languageCode == 'en'
                                        ? 'English'
                                        : 'Bahasa',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppTheme.gray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }),
                            const Icon(Icons.chevron_right,
                                color: AppTheme.gray),
                          ],
                        ),
                        onTap: _showLanguageDialog,
                      ),
                      if (user?.providerData
                              .any((p) => p.providerId == 'password') ??
                          false) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_reset_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.resetPassword,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppTheme.gray),
                          onTap: _showResetPasswordConfirm,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _buildLogoutButton(context, l10n.logout),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.changeLanguage,
            style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.english, style: GoogleFonts.dmSans()),
              leading: Radio<String>(
                value: 'en',
                groupValue: LanguageService.currentLanguageCode,
                activeColor: AppTheme.orange,
                onChanged: (val) {
                  LanguageService.setLocale('en');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                LanguageService.setLocale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.bahasaIndonesia, style: GoogleFonts.dmSans()),
              leading: Radio<String>(
                value: 'id',
                groupValue: LanguageService.currentLanguageCode,
                activeColor: AppTheme.orange,
                onChanged: (val) {
                  LanguageService.setLocale('id');
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                LanguageService.setLocale('id');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordConfirm() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.resetPassword,
            style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 1)),
        content: Text(
          l10n.resetPasswordConfirmMsg(_auth.currentUser?.email ?? ''),
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: GoogleFonts.dmSans(color: AppTheme.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _auth.resetPassword(_auth.currentUser?.email ?? '');
                _showSnack(l10n.resetPasswordEmailSent);
              } catch (e) {
                _showSnack('${l10n.failedToSave}: $e', isError: true);
              }
            },
            child: Text(l10n.send, style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.orange),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        hintStyle: GoogleFonts.dmSans(
            color: AppTheme.gray, fontWeight: FontWeight.w500),
      ),
      style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.orange, AppTheme.orange.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppTheme.orange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: ElevatedButton(
        onPressed: _savingProfile ? null : _saveProfileDetails,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _savingProfile
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_outlined,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(l10n.saveProfile,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ],
              ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange, width: 2),
      ),
      child: OutlinedButton(
        onPressed: () async {
          await _auth.logout();
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.orange,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
      ),
    );
  }
}

class _EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _EnhancedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.bebasNeue(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppTheme.gray,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
