// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 2;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      colorHex: fields[2] as String,
      icon: fields[3] as String,
      active: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      archivedAt: fields[6] as DateTime?,
      description: fields[7] == null ? '' : fields[7] as String,
      milestones: fields[8] == null ? [] : (fields[8] as List?)?.cast<String>(),
      milestoneCompleted:
          fields[9] == null ? [] : (fields[9] as List?)?.cast<bool>(),
      targetDate: fields[10] as DateTime?,
      hoursSpent: fields[11] == null ? 0 : fields[11] as int,
      sessionDates:
          fields[12] == null ? [] : (fields[12] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorHex)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.active)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.archivedAt)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.milestones)
      ..writeByte(9)
      ..write(obj.milestoneCompleted)
      ..writeByte(10)
      ..write(obj.targetDate)
      ..writeByte(11)
      ..write(obj.hoursSpent)
      ..writeByte(12)
      ..write(obj.sessionDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
