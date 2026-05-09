// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayLogAdapter extends TypeAdapter<DayLog> {
  @override
  final int typeId = 1;

  @override
  DayLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as String?,
      notes: fields[3] as String?,
      meditation: fields[4] as HabitLog,
      serum: fields[5] as HabitLog,
      coldShower: fields[6] as HabitLog,
      jawGym: fields[7] as HabitLog,
      chewQuest: fields[8] as HabitLog,
      protein: fields[9] as HabitLog,
      study: fields[10] as HabitLog,
      chess: fields[11] as HabitLog,
      cycling: fields[12] as HabitLog,
      buildStreak: fields[13] as HabitLog,
      madScientist: fields[14] as HabitLog,
      customHabits: (fields[15] as Map?)?.cast<String, HabitLog>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayLog obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.meditation)
      ..writeByte(5)
      ..write(obj.serum)
      ..writeByte(6)
      ..write(obj.coldShower)
      ..writeByte(7)
      ..write(obj.jawGym)
      ..writeByte(8)
      ..write(obj.chewQuest)
      ..writeByte(9)
      ..write(obj.protein)
      ..writeByte(10)
      ..write(obj.study)
      ..writeByte(11)
      ..write(obj.chess)
      ..writeByte(12)
      ..write(obj.cycling)
      ..writeByte(13)
      ..write(obj.buildStreak)
      ..writeByte(14)
      ..write(obj.madScientist)
      ..writeByte(15)
      ..write(obj.customHabits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
