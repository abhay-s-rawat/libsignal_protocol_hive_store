import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import '../models/hive_signal_key_store/hive_signal_key_store.dart';
import '../models/hive_signal_protocol_address/hive_signal_protocol_address.dart';
import 'eq.dart';

class HiveIdentityKeyStore extends IdentityKeyStore {
  HiveIdentityKeyStore(
    this.identityKeyPair,
    this.localRegistrationId,
    this.hiveModel,
  );

  final IdentityKeyPair identityKeyPair;
  final int localRegistrationId;
  HiveSignalKeyStoreModel hiveModel;

  @override
  Future<IdentityKey?> getIdentity(SignalProtocolAddress address) async {
    HiveSignalProtocolAddress addr =
        HiveSignalProtocolAddress.fromSignalAddress(address);
    Uint8List? trustedKey = hiveModel.identityKeyStore[addr];
    if (trustedKey != null) {
      return IdentityKey.fromBytes(trustedKey, 0);
    }
    return null;
  }

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async => identityKeyPair;

  @override
  Future<int> getLocalRegistrationId() async => localRegistrationId;

  @override
  Future<bool> isTrustedIdentity(SignalProtocolAddress address,
      IdentityKey? identityKey, Direction? direction) async {
    Uint8List? trustedKey = hiveModel
        .identityKeyStore[HiveSignalProtocolAddress.fromSignalAddress(address)];
    if (identityKey == null) {
      return false;
    }
    return trustedKey == null || eq(trustedKey, identityKey.serialize());
  }

  @override
  Future<bool> saveIdentity(
      SignalProtocolAddress address, IdentityKey? identityKey) async {
    HiveSignalProtocolAddress addr =
        HiveSignalProtocolAddress.fromSignalAddress(address);
    final Uint8List? existing = hiveModel.identityKeyStore[addr];
    if (identityKey == null) {
      return false;
    }
    IdentityKey? existingIdentity;
    if (existing != null) {
      existingIdentity = IdentityKey.fromBytes(existing, 0);
    }
    if (identityKey != existingIdentity) {
      hiveModel.identityKeyStore[addr] = identityKey.serialize();
      if (hiveModel.isInBox) {
        await hiveModel.save();
      }
      return true;
    } else {
      return false;
    }
  }
}
