// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 6;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      coldStreak: fields[0] as int,
      totalStreakBreaks: fields[1] as int,
      lastStreakBreakDate: fields[2] as DateTime?,
      lastBrokenStreak: fields[3] as int,
      lifetimeHabitsCompleted: fields[4] as int,
      totalDaysActive: fields[5] as int,
      unlockedBadges: (fields[6] as List).cast<String>(),
      streakRecoveryTokens: fields[7] as int,
      habitLevels: (fields[8] as Map).cast<String, int>(),
      currentTheme: fields[9] as String,
      streakBreakHistory: (fields[10] as List).cast<DateTime>(),
      longestColdStreak: fields[11] as int,
      totalMoneyLost: fields[12] as double,
      lastRecoveryDate: fields[13] as DateTime?,
      totalRecoveriesUsed: fields[14] == null ? 0 : fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.coldStreak)
      ..writeByte(1)
      ..write(obj.totalStreakBreaks)
      ..writeByte(2)
      ..write(obj.lastStreakBreakDate)
      ..writeByte(3)
      ..write(obj.lastBrokenStreak)
      ..writeByte(4)
      ..write(obj.lifetimeHabitsCompleted)
      ..writeByte(5)
      ..write(obj.totalDaysActive)
      ..writeByte(6)
      ..write(obj.unlockedBadges)
      ..writeByte(7)
      ..write(obj.streakRecoveryTokens)
      ..writeByte(8)
      ..write(obj.habitLevels)
      ..writeByte(9)
      ..write(obj.currentTheme)
      ..writeByte(10)
      ..write(obj.streakBreakHistory)
      ..writeByte(11)
      ..write(obj.longestColdStreak)
      ..writeByte(12)
      ..write(obj.totalMoneyLost)
      ..writeByte(13)
      ..write(obj.lastRecoveryDate)
      ..writeByte(14)
      ..write(obj.totalRecoveriesUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
