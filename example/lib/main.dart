import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:libsignal_protocol_hive_store/libsignal_protocol_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MyApp());
}

initHive() async {
  Directory dir = await getApplicationSupportDirectory();
  print(dir.path);
  Hive.init(
    dir.path,
    backendPreference: HiveStorageBackendPreference.native,
  );
  await HiveSignalStore.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Signal Protocol',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}
