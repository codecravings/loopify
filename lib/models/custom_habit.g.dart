// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomHabitAdapter extends TypeAdapter<CustomHabit> {
  @override
  final int typeId = 5;

  @override
  CustomHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomHabit(
      id: fields[0] as String,
      name: fields[1] as String,
      microcopy: fields[2] as String,
      iconCodePoint: fields[3] as int,
      colorValue: fields[4] as int,
      isDuration: fields[5] as bool,
      isNumeric: fields[6] as bool,
      unit: fields[7] as String?,
      target: fields[8] as int?,
      active: fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomHabit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.microcopy)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.isDuration)
      ..writeByte(6)
      ..write(obj.isNumeric)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.target)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
