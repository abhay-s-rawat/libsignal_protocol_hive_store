import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../models/hive_signal_key_store/hive_signal_key_store.dart';

class HivePreKeyStore extends PreKeyStore {
  HivePreKeyStore(this.hiveModel);
  HiveSignalKeyStoreModel hiveModel;

  @override
  Future<bool> containsPreKey(int preKeyId) async =>
      hiveModel.preKeyStore.containsKey(preKeyId);

  @override
  Future<PreKeyRecord> loadPreKey(int preKeyId) async {
    if (!hiveModel.preKeyStore.containsKey(preKeyId)) {
      throw InvalidKeyIdException('No such prekeyrecord! - $preKeyId');
    }
    return PreKeyRecord.fromBuffer(hiveModel.preKeyStore[preKeyId]!);
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    hiveModel.preKeyStore.remove(preKeyId);
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    hiveModel.preKeyStore[preKeyId] = record.serialize();
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }
}
