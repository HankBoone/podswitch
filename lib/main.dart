import 'package:flutter/material.dart';
import 'package:podswitch/updater.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        primaryColor: Colors.blue, // Change to your desired accent color
        secondaryHeaderColor: Colors.green,
        fontFamily: 'Roboto', // Use a modern font
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}
