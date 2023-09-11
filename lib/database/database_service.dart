import 'dart:async';
import 'package:path/path.dart';
import 'package:podswitch/database/models/favorites_db.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // lazily instantiate the db the first time it is accessed
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'favorites.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await FavoritesDB().createTable(db);
        
        // Create indexes here
        await db.execute(
          'CREATE INDEX IF NOT EXISTS address_index ON favorites (bluetoothAddress)');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS name_index ON favorites (localName)');
      },
      singleInstance: true,
    );
    return database;
  }
}
