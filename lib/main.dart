import 'package:flutter/material.dart';
import 'package:podswitch/dll.dart';
import 'package:podswitch/updater.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DynamicLibraryLoader.loadLibs();
  AutoUpdater().initUpdate();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PodSwitch',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
