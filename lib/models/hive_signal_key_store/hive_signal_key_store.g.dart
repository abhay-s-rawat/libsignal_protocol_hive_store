// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_signal_key_store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSignalKeyStoreModelAdapter
    extends TypeAdapter<HiveSignalKeyStoreModel> {
  @override
  final int typeId = 220;

  @override
  HiveSignalKeyStoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSignalKeyStoreModel(
      identityKeyPair: fields[0] as Uint8List,
      registrationId: fields[1] as int,
      preKeyStore: (fields[2] as Map)
          .map((dynamic k, dynamic v) => MapEntry(k as int, v as Uint8List)),
      identityKeyStore: (fields[3] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as HiveSignalProtocolAddress, v as Uint8List)),
      sessionStore: (fields[4] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as HiveSignalProtocolAddress, v as Uint8List)),
      signedPreKeyStore: (fields[5] as Map)
          .map((dynamic k, dynamic v) => MapEntry(k as int, v as Uint8List)),
      senderKeyStore: (fields[6] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as HiveSenderKeyName, v as Uint8List)),
    );
  }

  @override
  void write(BinaryWriter writer, HiveSignalKeyStoreModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.identityKeyPair)
      ..writeByte(1)
      ..write(obj.registrationId)
      ..writeByte(2)
      ..write(obj.preKeyStore)
      ..writeByte(3)
      ..write(obj.identityKeyStore)
      ..writeByte(4)
      ..write(obj.sessionStore)
      ..writeByte(5)
      ..write(obj.signedPreKeyStore)
      ..writeByte(6)
      ..write(obj.senderKeyStore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSignalKeyStoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
