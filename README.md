<p >
<a href="https://www.buymeacoffee.com/abhayrawat" target="_blank"><img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p> 

## libsignal protocol hive store

This package has the hive implementation of libsignal_protocol_dart.

## Usage

NOTE: 220,221,222 Hive type ids are used in this project.(Not sure if 0-223) is the limit of types.

```dart
import 'package:libsignal_protocol_hive_store/libsignal_protocol_hive_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MyApp());
}

initHive() async {
  await Hive.initFlutter();
  await HiveSignalStore.initialize(Hive);
}

```

```
// Contains following Hive Implementations
HiveIdentityKeyStore
HivePreKeyStore
HiveSenderKeyStore
HiveSessionStore
HiveSignalProtocolStore
HiveSignedPreKeyStore
```