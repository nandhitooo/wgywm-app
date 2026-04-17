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
  bool _loading = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

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
    if (_workoutCtrl.text.trim().isEmpty) {
      _showSnack('Masukkan nama workout.', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await _activityService.add(
        userId: _authService.userId,
        name: _workoutCtrl.text.trim(),
        durationMinutes: int.tryParse(_durationCtrl.text) ?? 20,
        calories: int.tryParse(_calCtrl.text) ?? 100,
        reps: int.tryParse(_repsCtrl.text) ?? 0,
      );
      _workoutCtrl.clear(); _durationCtrl.clear();
      _calCtrl.clear(); _repsCtrl.clear();
      _showSnack('Aktivitas tersimpan!');
    } catch (e) {
      _showSnack('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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

  Widget _addBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42, height: 42,
          decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
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
                  Row(children: [
                    Expanded(child: TextField(controller: _workoutCtrl,
                        decoration: const InputDecoration(hintText: 'e.g. Push Up'))),
                    const SizedBox(width: 10),
                    _addBtn(() {}),
                  ]),
                  const SizedBox(height: 20),
                  _label('Duration (minutes)'),
                  Row(children: [
                    Expanded(child: TextField(controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 30'))),
                    const SizedBox(width: 10),
                    _addBtn(() {}),
                  ]),
                  const SizedBox(height: 20),
                  _label('Calories Burned'),
                  Row(children: [
                    Expanded(child: TextField(controller: _calCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 200'))),
                    const SizedBox(width: 10),
                    _addBtn(() {}),
                  ]),
                  const SizedBox(height: 20),
                  _label('Enter Reps'),
                  Row(children: [
                    Expanded(child: TextField(controller: _repsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 20'))),
                    const SizedBox(width: 10),
                    _addBtn(() {}),
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
