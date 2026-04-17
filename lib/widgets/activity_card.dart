import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool showToday;
  final bool showYesterday;

  const ActivityCard({
    super.key,
    required this.activity,
    this.showToday = false,
    this.showYesterday = false,
  });

  @override
  Widget build(BuildContext context) {
    String label = '';
    Color labelColor = AppTheme.gray;
    if (showToday) {
      label = 'Today';
      labelColor = AppTheme.orange;
    } else if (showYesterday) {
      label = 'Yesterday';
      labelColor = AppTheme.gray;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.reps > 0
                      ? '${activity.durationMinutes} min · ${activity.calories} cal · ${activity.reps} reps'
                      : '${activity.durationMinutes} min · ${activity.calories} cal',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
          if (label.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: showToday ? AppTheme.orange : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: showToday ? Colors.white : AppTheme.gray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
