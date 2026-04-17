import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 0)
class Activity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  int calories;

  @HiveField(4)
  int reps;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String userId;

  @HiveField(7)
  bool synced;

  Activity({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.calories,
    required this.reps,
    required this.date,
    required this.userId,
    this.synced = false,
  });

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'durationMinutes': durationMinutes,
        'calories': calories,
        'reps': reps,
        'date': date.toIso8601String(),
        'userId': userId,
      };

  factory Activity.fromFirestore(Map<String, dynamic> data) => Activity(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        durationMinutes: data['durationMinutes'] ?? 0,
        calories: data['calories'] ?? 0,
        reps: data['reps'] ?? 0,
        date: DateTime.parse(data['date']),
        userId: data['userId'] ?? '',
        synced: true,
      );
}
