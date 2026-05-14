// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 8;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Challenge(
      id: fields[0] as String,
      habitName: fields[1] as String,
      habitDisplayName: fields[2] as String,
      isCustomHabit: fields[3] as bool,
      deadlineTime: fields[4] as DateTime,
      createdAt: fields[5] as DateTime,
      status: fields[6] as int,
      completedAt: fields[7] as DateTime?,
      saveChoice: fields[8] as int,
      snoozedUntil: fields[9] as DateTime?,
      snoozeCount: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitName)
      ..writeByte(2)
      ..write(obj.habitDisplayName)
      ..writeByte(3)
      ..write(obj.isCustomHabit)
      ..writeByte(4)
      ..write(obj.deadlineTime)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.saveChoice)
      ..writeByte(9)
      ..write(obj.snoozedUntil)
      ..writeByte(10)
      ..write(obj.snoozeCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
