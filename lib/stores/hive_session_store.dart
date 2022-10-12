import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../models/hive_signal_key_store/hive_signal_key_store.dart';
import '../models/hive_signal_protocol_address/hive_signal_protocol_address.dart';

class HiveSessionStore extends SessionStore {
  HiveSessionStore(this.hiveModel);
  HiveSignalKeyStoreModel hiveModel;

  @override
  Future<bool> containsSession(SignalProtocolAddress address) async {
    return hiveModel.sessionStore
        .containsKey(HiveSignalProtocolAddress.fromSignalAddress(address));
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    for (final k in hiveModel.sessionStore.keys.toList()) {
      if (k.name == name) {
        hiveModel.sessionStore.remove(k);
      }
    }
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }

  @override
  Future<void> deleteSession(SignalProtocolAddress address) async {
    hiveModel.sessionStore
        .remove(HiveSignalProtocolAddress.fromSignalAddress(address));
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    final deviceIds = <int>[];

    for (final key in hiveModel.sessionStore.keys) {
      if (key.name == name && key.deviceId != 1) {
        deviceIds.add(key.deviceId);
      }
    }

    return deviceIds;
  }

  @override
  Future<SessionRecord> loadSession(SignalProtocolAddress address) async {
    try {
      if (await containsSession(address)) {
        return SessionRecord.fromSerialized(hiveModel.sessionStore[
            HiveSignalProtocolAddress.fromSignalAddress(address)]!);
      } else {
        return SessionRecord();
      }
    } on Exception catch (e) {
      throw AssertionError(e);
    }
  }

  @override
  Future<void> storeSession(
      SignalProtocolAddress address, SessionRecord record) async {
    hiveModel.sessionStore[
            HiveSignalProtocolAddress.fromSignalAddress(address)] =
        record.serialize();
    if (hiveModel.isInBox) {
      await hiveModel.save();
    }
  }
}
