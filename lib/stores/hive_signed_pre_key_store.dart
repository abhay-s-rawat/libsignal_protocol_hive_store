import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import '../models/hive_signal_key_store/hive_signal_key_store.dart';

class HiveSignedPreKeyStore extends SignedPreKeyStore {
  HiveSignedPreKeyStore(this.hiveModel);
  HiveSignalKeyStoreModel hiveModel;

  @override
  Future<SignedPreKeyRecord> loadSignedPreKey(int signedPreKeyId) async {
    if (!hiveModel.signedPreKeyStore.containsKey(signedPreKeyId)) {
      throw InvalidKeyIdException(
          'No such signedprekeyrecord! $signedPreKeyId');
    }
    return SignedPreKeyRecord.fromSerialized(
        hiveModel.signedPreKeyStore[signedPreKeyId]!);
  }

  @override
  Future<List<SignedPreKeyRecord>> loadSignedPreKeys() async {
    final results = <SignedPreKeyRecord>[];
    for (final serialized in hiveModel.signedPreKeyStore.values) {
      results.add(SignedPreKeyRecord.fromSerialized(serialized));
    }
    return results;
  }

  @override
  Future<void> storeSignedPreKey(
      int signedPreKeyId, SignedPreKeyRecord record) async {
    hiveModel.signedPreKeyStore[signedPreKeyId] = record.serialize();
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async =>
      hiveModel.signedPreKeyStore.containsKey(signedPreKeyId);

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) async {
    hiveModel.signedPreKeyStore.remove(signedPreKeyId);
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }
}
