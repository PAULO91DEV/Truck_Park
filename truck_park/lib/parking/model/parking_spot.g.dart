// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParkingSpotAdapter extends TypeAdapter<ParkingSpot> {
  @override
  final int typeId = 1;

  @override
  ParkingSpot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingSpot(
      plate: fields[2] as String?,
      id: fields[0] as String,
      name: fields[1] as String,
      vacancy: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingSpot obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.plate)
      ..writeByte(3)
      ..write(obj.vacancy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingSpotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
