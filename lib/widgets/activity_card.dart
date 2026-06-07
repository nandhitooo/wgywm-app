import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/activity.dart';
import 'package:wgym/l10n/app_localizations.dart';

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

  IconData _getIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('run')) return Icons.directions_run;
    if (n.contains('cycl') || n.contains('bike')) return Icons.directions_bike;
    if (n.contains('swim')) return Icons.pool;
    if (n.contains('push up')) return Icons.fitness_center;
    if (n.contains('sit up')) return Icons.accessibility_new;
    if (n.contains('yoga') || n.contains('stretch')) {
      return Icons.self_improvement;
    }
    if (n.contains('football') || n.contains('soccer')) {
      return Icons.sports_soccer;
    }
    if (n.contains('badminton')) return Icons.sports_tennis;
    if (n.contains('hike')) return Icons.terrain;
    if (n.contains('jump rope')) return Icons.reorder;
    if (n.contains('stair')) return Icons.stairs;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label = '';
    Color labelColor = AppTheme.orange;
    if (showToday) {
      label = l10n.today;
    } else if (showYesterday) {
      label = l10n.yesterday;
      labelColor = AppTheme.gray;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.02),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: showToday
                    ? AppTheme.orange
                    : AppTheme.gray.withOpacity(0.3),
              ),
              const SizedBox(width: 16),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (showToday ? AppTheme.orange : AppTheme.gray)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(activity.name),
                  color: showToday ? AppTheme.orange : AppTheme.gray,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 12, color: AppTheme.gray.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.durationMinutes} min',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.gray,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.local_fire_department_outlined,
                              size: 12, color: AppTheme.gray.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.calories} kcal',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.gray,
                                fontWeight: FontWeight.w500),
                          ),
                          if (activity.reps > 0) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.repeat,
                                size: 12,
                                color: AppTheme.gray.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.reps} reps',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppTheme.gray,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: labelColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
