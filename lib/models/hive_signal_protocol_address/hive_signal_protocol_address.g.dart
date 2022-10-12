// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_signal_protocol_address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSignalProtocolAddressAdapter
    extends TypeAdapter<HiveSignalProtocolAddress> {
  @override
  final int typeId = 221;

  @override
  HiveSignalProtocolAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSignalProtocolAddress(
      fields[0] as String,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSignalProtocolAddress obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSignalProtocolAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
