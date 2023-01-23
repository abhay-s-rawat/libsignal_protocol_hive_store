import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import '../hive_sender_key_name/hive_sender_key_name.dart';
import '../hive_signal_protocol_address/hive_signal_protocol_address.dart';
part 'hive_signal_key_store.g.dart';

@HiveType(typeId: 220)
class HiveSignalKeyStoreModel extends HiveObject {
  @HiveField(0)
  final Uint8List identityKeyPair;
  @HiveField(1)
  final int registrationId;
  @HiveField(2)
  final Map<int, Uint8List> preKeyStore;
  @HiveField(3)
  final Map<HiveSignalProtocolAddress, Uint8List> identityKeyStore;
  @HiveField(4)
  final Map<HiveSignalProtocolAddress, Uint8List> sessionStore;
  @HiveField(5)
  final Map<int, Uint8List> signedPreKeyStore;
  @HiveField(6)
  final Map<HiveSenderKeyName, Uint8List> senderKeyStore;

  HiveSignalKeyStoreModel({
    required this.identityKeyPair,
    required this.registrationId,
    required this.preKeyStore,
    required this.identityKeyStore,
    required this.sessionStore,
    required this.signedPreKeyStore,
    required this.senderKeyStore,
  });

  factory HiveSignalKeyStoreModel.generateFreshKeys({
    int preKeysStart = 0,
    int preKeysCount = 100,
    int signedPreKeyid = 1,
  }) {
    final IdentityKeyPair identityKeyPair = generateIdentityKeyPair();
    final int registrationId = generateRegistrationId(true);
    final List<PreKeyRecord> preKeys =
        generatePreKeys(preKeysStart, preKeysCount);
    final SignedPreKeyRecord signedPreKey =
        generateSignedPreKey(identityKeyPair, signedPreKeyid);
    Map<int, Uint8List> preKeyStore = {};
    for (final PreKeyRecord p in preKeys) {
      preKeyStore[p.id] = p.serialize();
    }
    Map<int, Uint8List> signedPreKeyStore = {};
    signedPreKeyStore[signedPreKey.id] = signedPreKey.serialize();
    return HiveSignalKeyStoreModel(
      identityKeyPair: identityKeyPair.serialize(),
      registrationId: registrationId,
      preKeyStore: preKeyStore,
      identityKeyStore: {},
      sessionStore: {},
      signedPreKeyStore: signedPreKeyStore,
      senderKeyStore: {},
    );
  }

  String get getServerPreKeyBundle {
    //Send to server
    return jsonEncode(getServerPreKeyBundleMap);
  }

  Map get getServerPreKeyBundleMap {
    //Send to server
    Map<String, dynamic> req = {};
    req['registrationId'] = registrationId;
    req['identityKey'] = base64Encode(
        IdentityKeyPair.fromSerialized(identityKeyPair)
            .getPublicKey()
            .serialize());
    SignedPreKeyRecord signedPreKey =
        SignedPreKeyRecord.fromSerialized(signedPreKeyStore.values.first);
    req['signedPreKey'] = {
      'id': signedPreKey.id,
      'signature': base64Encode(signedPreKey.signature),
      'key': base64Encode(signedPreKey.getKeyPair().publicKey.serialize()),
    };
    List pKeysList = [];
    for (int pKey in preKeyStore.keys) {
      Map<String, dynamic> pKeys = {};
      pKeys['id'] = pKey;
      pKeys['key'] = base64Encode(PreKeyRecord.fromBuffer(preKeyStore[pKey]!)
          .getKeyPair()
          .publicKey
          .serialize());
      pKeysList.add(pKeys);
    }
    req['preKeys'] = pKeysList;
    return req;
  }
}
