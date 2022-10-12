import 'package:hive_flutter/hive_flutter.dart';

import 'models/hive_sender_key_name/hive_sender_key_name.dart';
import 'models/hive_signal_key_store/hive_signal_key_store.dart';
import 'models/hive_signal_protocol_address/hive_signal_protocol_address.dart';

class HiveSignalStore {
  static Future<void> initialize(HiveInterface hive) async {
    if (!hive.isAdapterRegistered(220)) {
      hive.registerAdapter<HiveSignalKeyStoreModel>(
          HiveSignalKeyStoreModelAdapter());
    }
    if (!hive.isAdapterRegistered(221)) {
      hive.registerAdapter<HiveSignalProtocolAddress>(
          HiveSignalProtocolAddressAdapter());
    }
    if (!hive.isAdapterRegistered(222)) {
      hive.registerAdapter<HiveSenderKeyName>(HiveSenderKeyNameAdapter());
    }
  }
}
