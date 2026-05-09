import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

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
  };
  final List<Map<String, dynamic>> _workoutCategories = [
    {
      'name': 'Strength Training',
      'types': ['Push Up', 'Pull Up', 'Squat', 'Sit Up'],
    },
    {
      'name': 'Cardio',
      'types': ['Morning Run', 'Cycling', 'Swimming'],
    },
    {
      'name': 'Core & Flexibility',
      'types': ['Plank', 'Yoga', 'Stretch', 'Pilates'],
    },
    {
      'name': 'Sport',
      'types': ['Badminton', 'Football'],
    },
    {
      'name': 'HIIT',
      'types': ['Jump Rope', 'Burpees', 'Stair Climbing'],
    },
    {
      'name': 'Outdoor',
      'types': ['Hiking'],
    },
  ];
  String? _selectedCategory;
  String? _selectedType;
  bool _loading = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadUserWeight();
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
    _workoutCtrl.dispose(); _durationCtrl.dispose();
    _calCtrl.dispose(); _repsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context, initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.orange)),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _save() async {
    final workoutName = _selectedType ?? _workoutCtrl.text.trim();
    if (workoutName.isEmpty) {
      _showSnack('Pilih jenis workout atau masukkan nama workout.', isError: true);
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
      _workoutCtrl.clear(); _durationCtrl.clear();
      _calCtrl.clear(); _repsCtrl.clear();
      _showSnack('Aktivitas tersimpan!');
    } catch (e) {
      _showSnack('Gagal menyimpan: $e', isError: true);
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
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppTheme.dark, letterSpacing: 1.2)),
      );

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.orange),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        hintStyle: GoogleFonts.dmSans(color: AppTheme.gray, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [BoxShadow(color: AppTheme.orange.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20, right: 20, bottom: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log your workout',
                    style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text('ADD ACTIVITIES',
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
                  _label('Select Category'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                      border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _workoutCategories.map((category) {
                        final selected = _selectedCategory == category['name'];
                        return ChoiceChip(
                          label: Text(category['name'],
                              style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : AppTheme.gray)),
                          selected: selected,
                          selectedColor: AppTheme.orange,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected ? AppTheme.orange : const Color(0xFFE8E8E8),
                            width: selected ? 0 : 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          onSelected: (onSelected) {
                            setState(() {
                              _selectedCategory = onSelected ? category['name'] as String : null;
                              _selectedType = null;
                              _workoutCtrl.clear();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Workout Type Selection
                  if (_selectedCategory != null) ...[
                    _label('Choose Workout Type'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List<String>.from(
                                _workoutCategories.firstWhere((cat) => cat['name'] == _selectedCategory!)['types'] as List)
                            .map<Widget>((type) {
                          final selected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(type,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : AppTheme.gray)),
                            selected: selected,
                            selectedColor: AppTheme.orange,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: selected ? AppTheme.orange : const Color(0xFFE8E8E8),
                              width: selected ? 0 : 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            onSelected: (onSelected) {
                              setState(() {
                                _selectedType = onSelected ? type : null;
                                if (onSelected) {
                                  _workoutCtrl.text = type;
                                }
                                _updateCalories();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Custom Workout Input
                  _label('Custom Workout Name'),
                  _buildInputField(
                    _workoutCtrl,
                    'Enter workout name',
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                      border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Duration'),
                        _buildInputField(
                          _durationCtrl,
                          'e.g. 30',
                          Icons.schedule_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateCalories(),
                        ),
                        const SizedBox(height: 20),

                        _label('Calories Burned'),
                        Text(
                          'Auto-calculated from duration and weight',
                          style: GoogleFonts.dmSans(color: AppTheme.gray, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          _calCtrl,
                          'e.g. 200',
                          Icons.local_fire_department_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        _label('Reps (Optional)'),
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
                        colors: [AppTheme.orange, AppTheme.orange.withOpacity(0.85)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppTheme.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('SAVE ACTIVITY',
                                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
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
