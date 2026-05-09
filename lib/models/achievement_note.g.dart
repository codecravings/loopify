// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementNoteAdapter extends TypeAdapter<AchievementNote> {
  @override
  final int typeId = 10;

  @override
  AchievementNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementNote(
      id: fields[0] as String,
      note: fields[1] as String,
      date: fields[2] as DateTime,
      emoji: fields[3] as String,
      category: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
