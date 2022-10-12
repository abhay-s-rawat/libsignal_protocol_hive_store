import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:libsignal_protocol_hive_store/libsignal_protocol_hive_store.dart';

class SignalHelperModel {
  static const int defaultDeviceId = 1;
  String name;
  HiveSignalProtocolStore signalStore;
  HiveSenderKeyStore senderKeyStore;
  SignalHelperModel({
    required this.name,
    required this.signalStore,
    required this.senderKeyStore,
  });
  //
  String getPreKeyBundleFromServer() {
    // Server will only send 1 pre key and deletes that pre key
    Map<String, dynamic> data =
        jsonDecode(signalStore.hiveModel.getServerPreKeyBundle);
    List preKeysList = data['preKeys'];
    if (preKeysList.isNotEmpty) {
      data['preKey'] = preKeysList.first;
    }
    data.remove('preKeys');
    return jsonEncode(data);
  }

  // Session validation
  Future<Fingerprint?> generateSessionFingerPrint(String target) async {
    try {
      IdentityKey? targetIdentity = await signalStore
          .getIdentity(SignalProtocolAddress(target, defaultDeviceId));
      if (targetIdentity != null) {
        final generator = NumericFingerprintGenerator(5200);
        final localFingerprint = generator.createFor(
          1,
          Uint8List.fromList(utf8.encode(name)),
          (await signalStore.getIdentityKeyPair()).getPublicKey(),
          Uint8List.fromList(utf8.encode(target)),
          targetIdentity,
        );
        return localFingerprint;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

// Group implementation
  Future<String> createGroupSession(String groupName) async {
    SignalProtocolAddress senderName =
        SignalProtocolAddress(name, defaultDeviceId);
    SenderKeyName groupSender = SenderKeyName(groupName, senderName);
    GroupSessionBuilder sessionBuilder = GroupSessionBuilder(senderKeyStore);
    SenderKeyDistributionMessageWrapper distributionMessage =
        await sessionBuilder.create(groupSender);
    Map<String, dynamic> temp = {
      "from": name,
      "msg": base64Encode(distributionMessage.serialize()),
      "type": CiphertextMessage.senderKeyDistributionType,
    };
    String kdmMsg = jsonEncode(temp);
    return kdmMsg;
  }

  Future<String?> getGroupEncryptedText(String groupName, String text) async {
    try {
      SenderKeyName senderKeyName = SenderKeyName(
          groupName, SignalProtocolAddress(name, defaultDeviceId));
      GroupCipher groupSession = GroupCipher(senderKeyStore, senderKeyName);
      Uint8List cipherText =
          await groupSession.encrypt(Uint8List.fromList(utf8.encode(text)));
      Map<String, dynamic> data = {
        "from": name,
        "msg": base64Encode(cipherText),
        "type": CiphertextMessage.senderKeyType,
      };
      return jsonEncode(data);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> registerKdm(String groupName, String kdm) async {
    try {
      Map data = jsonDecode(kdm);
      if (data["type"] == CiphertextMessage.senderKeyDistributionType) {
        SenderKeyName groupSender = SenderKeyName(
            groupName, SignalProtocolAddress(data['from'], defaultDeviceId));
        GroupSessionBuilder sessionBuilder =
            GroupSessionBuilder(senderKeyStore);
        SenderKeyDistributionMessageWrapper distributionMessage =
            SenderKeyDistributionMessageWrapper.fromSerialized(
                base64Decode(data['msg']));
        await sessionBuilder.process(groupSender, distributionMessage);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String?> getGroupDecryptedText(String groupName, String msg) async {
    try {
      Map data = jsonDecode(msg);
      SenderKeyName skey = SenderKeyName(
          groupName, SignalProtocolAddress(data["from"], defaultDeviceId));
      GroupCipher groupCipher = GroupCipher(senderKeyStore, skey);
      final plainText = await groupCipher.decrypt(base64Decode(data['msg']));
      return utf8.decode(plainText);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

// one to one implementation
  Future<void> buildSession(
    String target,
    String remoteBundle,
  ) async {
    SignalProtocolAddress targetAddress =
        SignalProtocolAddress(target, defaultDeviceId);
    SessionBuilder sessionBuilder =
        SessionBuilder.fromSignalStore(signalStore, targetAddress);
    PreKeyBundle temp = preKeyBundleFromJson(jsonDecode(remoteBundle));
    await sessionBuilder.processPreKeyBundle(temp);
  }

  PreKeyBundle preKeyBundleFromJson(Map<String, dynamic> remoteBundle) {
    // One time pre key calculation
    Map<String, dynamic>? tempPreKey = remoteBundle["preKey"];
    ECPublicKey? tempPrePublicKey;
    int? tempPreKeyId;
    if (tempPreKey != null) {
      tempPrePublicKey = Curve.decodePoint(
          DjbECPublicKey(base64Decode(tempPreKey['key'])).serialize(), 1);
      tempPreKeyId = tempPreKey['id'];
    }
    // Signed pre key
    int tempSignedPreKeyId = remoteBundle["signedPreKey"]['id'];
    Map? tempSignedPreKey = remoteBundle["signedPreKey"];
    ECPublicKey? tempSignedPreKeyPublic;
    Uint8List? tempSignedPreKeySignature;
    if (tempSignedPreKey != null) {
      tempSignedPreKeyPublic = Curve.decodePoint(
          DjbECPublicKey(base64Decode(remoteBundle["signedPreKey"]['key']))
              .serialize(),
          1);
      tempSignedPreKeySignature =
          base64Decode(remoteBundle["signedPreKey"]['signature']);
    }
    // Identity key calculation
    IdentityKey tempIdentityKey = IdentityKey(Curve.decodePoint(
        DjbECPublicKey(base64Decode(remoteBundle["identityKey"])).serialize(),
        1));
    return PreKeyBundle(
      remoteBundle['registrationId'],
      1,
      tempPreKeyId,
      tempPrePublicKey,
      tempSignedPreKeyId,
      tempSignedPreKeyPublic,
      tempSignedPreKeySignature,
      tempIdentityKey,
    );
  }

  Future<String?> getEncryptedText(String text, String target) async {
    try {
      SessionCipher session = SessionCipher.fromStore(
          signalStore, SignalProtocolAddress(target, defaultDeviceId));
      final ciphertext =
          await session.encrypt(Uint8List.fromList(utf8.encode(text)));
      Map<String, dynamic> data = {
        "msg": base64Encode(ciphertext.serialize()),
        "type": ciphertext.getType(),
      };
      return jsonEncode(data);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<String?> getDecryptedText(String source, String msg) async {
    try {
      SessionCipher session = SessionCipher.fromStore(
          signalStore, SignalProtocolAddress(source, defaultDeviceId));
      Map data = jsonDecode(msg);
      if (data["type"] == CiphertextMessage.prekeyType) {
        PreKeySignalMessage pre =
            PreKeySignalMessage(base64Decode(data["msg"]));
        Uint8List plaintext = await session.decrypt(pre);
        String dectext = utf8.decode(plaintext);
        return dectext;
      } else if (data["type"] == CiphertextMessage.whisperType) {
        SignalMessage signalMsg =
            SignalMessage.fromSerialized(base64Decode(data["msg"]));
        Uint8List plaintext = await session.decryptFromSignal(signalMsg);
        String dectext = utf8.decode(plaintext);
        return dectext;
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  changeSignature() async {
    SignedPreKeyRecord signedPreKey = generateSignedPreKey(
        await signalStore.getIdentityKeyPair(), defaultDeviceId);
    await signalStore.signedPreKeyStore.removeSignedPreKey(defaultDeviceId);
    await signalStore.signedPreKeyStore
        .storeSignedPreKey(defaultDeviceId, signedPreKey);
    log("replaced signedprekey for $name");
  }
}
