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
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.gray, letterSpacing: 0.8)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          Container(
            width: double.infinity, color: AppTheme.orange,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log your workout',
                    style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.75), fontSize: 13)),
                const SizedBox(height: 4),
                Text('ADD ACTIVITIES',
                    style: GoogleFonts.bebasNeue(
                        color: Colors.white, fontSize: 30, letterSpacing: 2)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _label('Your Workout'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
                        backgroundColor: AppTheme.white,
                        side: BorderSide(color: selected ? AppTheme.orange : AppTheme.gray.withOpacity(0.35)),
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
                  if (_selectedCategory != null) ...[
                    const SizedBox(height: 16),
                    _label('Jenis Workout'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
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
                          backgroundColor: AppTheme.white,
                          side: BorderSide(color: selected ? AppTheme.orange : AppTheme.gray.withOpacity(0.35)),
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
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _workoutCtrl,
                    onChanged: (value) {
                      if (_selectedType != null && value != _selectedType) {
                        setState(() => _selectedType = null);
                      }
                    },
                    decoration: const InputDecoration(
                        hintText: 'Pilih jenis workout atau masukkan nama workout'),
                  ),
                  const SizedBox(height: 20),
                  _label('Duration (minutes)'),
                  TextField(controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateCalories(),
                      decoration: const InputDecoration(hintText: 'e.g. 30')),
                  const SizedBox(height: 20),
                  _label('Calories Burned (auto-calculated, can edit manually)'),
                  TextField(controller: _calCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 200')),
                  const SizedBox(height: 20),
                  _label('Enter Reps'),
                  Row(children: [
                    Expanded(child: TextField(controller: _repsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 20'))),
                    const SizedBox(width: 10),
                  ]),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SAVE ACTIVITY'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
