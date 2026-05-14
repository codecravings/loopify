// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_prefs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPrefsAdapter extends TypeAdapter<UserPrefs> {
  @override
  final int typeId = 4;

  @override
  UserPrefs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPrefs(
      proteinTarget: fields[0] as int,
      meditationDefault: fields[1] as int,
      studyDefault: fields[2] as int,
      chessDefault: fields[3] as int,
      cyclingDefault: fields[4] as int,
      strictStreakMode: fields[5] as bool,
      hapticsEnabled: fields[6] as bool,
      highContrastMode: fields[7] as bool,
      onboardingComplete: fields[8] as bool,
      notificationsEnabled: fields[9] as bool,
      reminderHour: fields[10] as int,
      reminderMinute: fields[11] as int,
      hiddenHabits:
          fields[12] == null ? [] : (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPrefs obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.proteinTarget)
      ..writeByte(1)
      ..write(obj.meditationDefault)
      ..writeByte(2)
      ..write(obj.studyDefault)
      ..writeByte(3)
      ..write(obj.chessDefault)
      ..writeByte(4)
      ..write(obj.cyclingDefault)
      ..writeByte(5)
      ..write(obj.strictStreakMode)
      ..writeByte(6)
      ..write(obj.hapticsEnabled)
      ..writeByte(7)
      ..write(obj.highContrastMode)
      ..writeByte(8)
      ..write(obj.onboardingComplete)
      ..writeByte(9)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.reminderHour)
      ..writeByte(11)
      ..write(obj.reminderMinute)
      ..writeByte(12)
      ..write(obj.hiddenHabits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPrefsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
