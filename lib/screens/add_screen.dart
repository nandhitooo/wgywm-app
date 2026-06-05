import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import 'package:wgym/l10n/app_localizations.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _workoutCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _activityService = ActivityService();
  final _authService = AuthService();
  double? _userWeight;
  final Map<String, double> _metValues = {
    'Plank': 3.0,
    'Yoga': 3.0,
    'Sit Up': 4.5,
    'Squat': 4.5,
    'Push Up': 8.0,
    'Pull Up': 8.0,
    'Morning Run': 9.0,
    'Cycling': 7.5,
    'Swimming': 9.0,
    'Jump Rope': 11.5,
    'Stretch': 3.0,
    'Pilates': 3.0,
    'Badminton': 5.5,
    'Football': 8.0,
    'Burpees': 10.0,
    'Stair Climbing': 8.0,
    'Hiking': 6.5,
    'Walking': 3.5,
    'Weight Lifting': 5.0,
    'Dancing': 4.5,
    'Zumba': 6.5,
    'Boxing': 12.0,
    'Jumping Jacks': 8.0,
    'Mountain Climbers': 10.0,
    'Basketball': 8.0,
    'Tennis': 7.0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserWeight();
  }

  List<Map<String, dynamic>> _getWorkoutCategories(AppLocalizations l10n) {
    return [
      {
        'name': l10n.strengthTraining,
        'icon': Icons.fitness_center_rounded,
        'types': ['Push Up', 'Pull Up', 'Squat', 'Sit Up', 'Weight Lifting'],
      },
      {
        'name': l10n.cardio,
        'icon': Icons.directions_run_rounded,
        'types': ['Morning Run', 'Cycling', 'Swimming', 'Walking'],
      },
      {
        'name': l10n.coreFlexibility,
        'icon': Icons.self_improvement_rounded,
        'types': ['Plank', 'Yoga', 'Stretch', 'Pilates'],
      },
      {
        'name': l10n.sport,
        'icon': Icons.sports_soccer_rounded,
        'types': ['Badminton', 'Football', 'Basketball', 'Tennis'],
      },
      {
        'name': l10n.hiit,
        'icon': Icons.bolt_rounded,
        'types': [
          'Jump Rope',
          'Burpees',
          'Stair Climbing',
          'Jumping Jacks',
          'Mountain Climbers'
        ],
      },
      {
        'name': l10n.outdoor,
        'icon': Icons.terrain_rounded,
        'types': ['Hiking'],
      },
      {
        'name': l10n.danceFun,
        'icon': Icons.music_note_rounded,
        'types': ['Dancing', 'Zumba'],
      },
      {
        'name': l10n.combat,
        'icon': Icons.sports_mma_rounded,
        'types': ['Boxing'],
      },
    ];
  }

  Future<void> _loadUserWeight() async {
    final profile = await _authService.getProfile();
    if (profile != null) {
      final weightValue = profile['weight']?.toString();
      final parsedWeight = double.tryParse(weightValue ?? '');
      if (parsedWeight != null && mounted) {
        setState(() => _userWeight = parsedWeight);
        _updateCalories();
      }
    }
  }

  @override
  void dispose() {
    _workoutCtrl.dispose();
    _durationCtrl.dispose();
    _calCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  String? _selectedCategory;
  String? _selectedType;
  bool _loading = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final workoutName = _selectedType ?? _workoutCtrl.text.trim();
    if (workoutName.isEmpty) {
      _showSnack(l10n.pickWorkoutType, isError: true);
      return;
    }
    final computedCalories = _calculateCalories();
    final calories = computedCalories ?? int.tryParse(_calCtrl.text) ?? 100;
    setState(() => _loading = true);
    try {
      await _activityService.add(
        userId: _authService.userId,
        name: workoutName,
        durationMinutes: int.tryParse(_durationCtrl.text) ?? 20,
        calories: calories,
        reps: int.tryParse(_repsCtrl.text) ?? 0,
      );
      _selectedCategory = null;
      _selectedType = null;
      _workoutCtrl.clear();
      _durationCtrl.clear();
      _calCtrl.clear();
      _repsCtrl.clear();
      _showSnack(l10n.activitySaved);
    } catch (e) {
      _showSnack('${l10n.failedToSave}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _calculateCalories() {
    final duration = int.tryParse(_durationCtrl.text);
    if (duration == null || duration <= 0) return null;
    final typeName = _selectedType ?? _workoutCtrl.text.trim();
    if (typeName.isEmpty) return null;
    final met = _metValues[typeName];
    if (met == null) return null;
    final weight = _userWeight ?? 70.0;
    final calories = met * 3.5 * weight / 200 * duration;
    return calories.round();
  }

  void _updateCalories() {
    final calories = _calculateCalories();
    if (calories != null) {
      _calCtrl.text = calories.toString();
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text.toUpperCase(),
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1.2)),
      );

  Widget _buildInputField(
      TextEditingController controller, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface),
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
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final bool isSelected = _selectedCategory == category['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : category['name'] as String;
          _selectedType = null;
          _workoutCtrl.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.orange
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
          border: Border.all(
            color: isSelected
                ? AppTheme.orange
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'] as IconData,
              color: isSelected ? Colors.white : AppTheme.orange,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              category['name']
                  .toString()
                  .split(' ')[0], // Show first word to keep it neat
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.gray,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getWorkoutCategories(l10n);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Gradient Header
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
              bottom: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.logYourWorkout,
                    style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(l10n.addActivities,
                    style: GoogleFonts.bebasNeue(
                        color: Colors.white, fontSize: 32, letterSpacing: 1.5)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  _label(l10n.selectCategory),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _buildCategoryCard(categories[index]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Workout Type Selection
                  if (_selectedCategory != null) ...[
                    _label(l10n.chooseWorkoutType),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<String>.from(categories.firstWhere((cat) =>
                                  cat['name'] == _selectedCategory!)['types']
                              as List)
                          .map<Widget>((type) {
                        final selected = _selectedType == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = selected ? null : type;
                              if (!selected) {
                                _workoutCtrl.text = type;
                              }
                              _updateCalories();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.orange.withOpacity(0.15)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.orange
                                    : Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color:
                                    selected ? AppTheme.orange : AppTheme.gray,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Custom Workout Name
                  _label(l10n.customWorkoutName),
                  _buildInputField(
                    _workoutCtrl,
                    l10n.workoutName,
                    Icons.fitness_center_outlined,
                    onChanged: (value) {
                      if (_selectedType != null && value != _selectedType) {
                        setState(() => _selectedType = null);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Form Fields Section
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4))
                      ],
                      border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                          width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(l10n.time),
                        _buildInputField(
                          _durationCtrl,
                          'e.g. 30',
                          Icons.schedule_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateCalories(),
                        ),
                        const SizedBox(height: 20),
                        _label(l10n.calories),
                        Text(
                          l10n.autoCalculatedHint,
                          style: GoogleFonts.dmSans(
                              color: AppTheme.gray,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          _calCtrl,
                          'e.g. 200',
                          Icons.local_fire_department_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        _label(l10n.repsOptional),
                        _buildInputField(
                          _repsCtrl,
                          'e.g. 20',
                          Icons.repeat_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.orange,
                          AppTheme.orange.withOpacity(0.85)
                        ],
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
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(l10n.saveActivity,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
