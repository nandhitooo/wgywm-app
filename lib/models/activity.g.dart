// GENERATED CODE - DO NOT MODIFY BY HAND
// Jika pakai build_runner, hapus file ini lalu jalankan:
// flutter pub run build_runner build

part of 'activity.dart';

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 0;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      id: fields[0] as String,
      name: fields[1] as String,
      durationMinutes: fields[2] as int,
      calories: fields[3] as int,
      reps: fields[4] as int,
      date: fields[5] as DateTime,
      userId: fields[6] as String,
      synced: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.reps)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
