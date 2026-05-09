// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakStateAdapter extends TypeAdapter<StreakState> {
  @override
  final int typeId = 3;

  @override
  StreakState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakState(
      currentStreak: fields[0] as int,
      bestStreak: fields[1] as int,
      lastLoggedDate: fields[2] as DateTime?,
      gracePassesUsedThisWeek: fields[3] as int,
      weekStartDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StreakState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.bestStreak)
      ..writeByte(2)
      ..write(obj.lastLoggedDate)
      ..writeByte(3)
      ..write(obj.gracePassesUsedThisWeek)
      ..writeByte(4)
      ..write(obj.weekStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
