import 'package:path_provider/path_provider.dart';
import 'package:podswitch/database/models/favorites_db.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Lazily instantiate the database the first time it is accessed
    _database = await _initialize();
    return _database!;
  }

  Future<String> get _fullPath async {
    try {
      const name = 'favorites.db';
      final localappdata = await getApplicationSupportDirectory();
      return '${localappdata.path}/$name';
    } catch (e) {
      rethrow;
    }
  }

  Future<Database> _initialize() async {
    final path = await _fullPath;
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: _create, // Use the private create method
      singleInstance: true,
    );
    return database;
  }

  Future<void> _create(Database database, int version) async {
    // Call the createTable method of your FavoritesDB class
    await FavoritesDB().createTable(database);
  }
}
