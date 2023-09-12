import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class DynamicLibraryLoader {
  static void loadLibs() async {
    if (kReleaseMode) {
      void loadsqlite3Lib() {
        // I'm on release mode, absolute linking
        final String sqlite3Lib =
            join('data', 'flutter_assets', 'assets', 'bin', 'sqlite3.dll');
        String pathToLib = join(
            Directory(Platform.resolvedExecutable).parent.path, sqlite3Lib);
        DynamicLibrary.open(pathToLib);
      }

      void copyMicMuteToggleExecutable() {
        final String micMuteToggleExecutable = join(
            'data', 'flutter_assets', 'assets', 'bin', 'MicMuteToggle.exe');
        String pathToExecutable = join(
            Directory(Platform.resolvedExecutable).parent.path,
            micMuteToggleExecutable);
        File(pathToExecutable).copySync('MicMuteToggle.exe');
      }

      if (Platform.isWindows) {
        copyMicMuteToggleExecutable();
        loadsqlite3Lib();
      }
    } else {
      void loadsqlite3Lib() {
        // I'm on debug mode, local linking
        var path = Directory.current.path;
        DynamicLibrary.open('$path/assets/bin/sqlite3.dll');
      }

      if (Platform.isWindows) {
        loadsqlite3Lib();
      }
    }
  }
}
