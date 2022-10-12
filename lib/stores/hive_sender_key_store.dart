import 'dart:typed_data';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../models/hive_sender_key_name/hive_sender_key_name.dart';
import '../models/hive_signal_key_store/hive_signal_key_store.dart';

class HiveSenderKeyStore extends SenderKeyStore {
  HiveSenderKeyStore(this.hiveModel);
  HiveSignalKeyStoreModel hiveModel;

  @override
  Future<SenderKeyRecord> loadSenderKey(SenderKeyName senderKeyName) async {
    try {
      final Uint8List? record = hiveModel
          .senderKeyStore[HiveSenderKeyName.fromSignalName(senderKeyName)];
      if (record == null) {
        return SenderKeyRecord();
      } else {
        return SenderKeyRecord.fromSerialized(record);
      }
    } on Exception catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  Future<void> storeSenderKey(
      SenderKeyName senderKeyName, SenderKeyRecord record) async {
    hiveModel.senderKeyStore[HiveSenderKeyName.fromSignalName(senderKeyName)] =
        record.serialize();
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }
}
