// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_sender_key_name.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSenderKeyNameAdapter extends TypeAdapter<HiveSenderKeyName> {
  @override
  final int typeId = 222;

  @override
  HiveSenderKeyName read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSenderKeyName(
      groupId: fields[0] as String,
      sender: fields[1] as HiveSignalProtocolAddress,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSenderKeyName obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.sender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSenderKeyNameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
