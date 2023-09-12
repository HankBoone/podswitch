import 'dart:convert';
import 'dart:typed_data';

import 'package:podswitch/database/database_service.dart';
import 'package:podswitch/database/models/favorite.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesDB {
  final tableName = 'favorites';
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "bluetoothAddress" TEXT NOT NULL,
    "rssi" TEXT DEFAULT '',
    "timestamp" TEXT DEFAULT '',
    "advType" TEXT DEFAULT '',
    "localName" TEXT NOT NULL UNIQUE,
    "serviceUuids" TEXT DEFAULT '',
    "manufacturerData" TEXT DEFAULT ''
  )""");
  }

  Future<int> create({
  required String address,
  required String rssi,
  required String timestamp,
  required String advType,
  required String name,
  required List<String> serviceUuids,
  required Uint8List manufacturerData,
}) async {
  final database = await DatabaseService().database;

  return await database.rawInsert(
    '''INSERT INTO $tableName (
      bluetoothAddress,
      rssi,
      timestamp,
      advType,
      localName,
      serviceUuids,
      manufacturerData
    ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
    [
      address,
      rssi,
      timestamp,
      advType,
      name,
      jsonEncode(serviceUuids), // Store as JSON string
      Uint8List.fromList(manufacturerData), // Store as Blob
    ],
  );
}




  Future<List<Favorite>> fetchAll() async {
    final database = await DatabaseService().database;
    final favorites = await database.rawQuery(
      '''SELECT * from $tableName''',
    );
    return favorites
        .map((favorite) => Favorite.fromSqfliteDatabase(favorite))
        .toList();
  }

  Future<Favorite> fetchById({required int id}) async {
    final database = await DatabaseService().database;
    final favorite = await database.rawQuery(
      '''SELECT * from $tableName WHERE id = ?''',
      [id],
    );
    return Favorite.fromSqfliteDatabase(favorite.first);
  }

  Future<Favorite> fetchByAddress({required String address}) async {
    final database = await DatabaseService().database;
    final favorite = await database.rawQuery(
      '''SELECT * from $tableName WHERE bluetoothAddress = ?''',
      [address],
    );
    return Favorite.fromSqfliteDatabase(favorite.first);
  }

  Future<int> update({required int id, String? address}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (address != null) 'address': address,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete({int? id}) async {
    final database = await DatabaseService().database;
    await database.rawDelete(''' DELETE FROM $tableName WHERE id = ?''', [id]);
  }
}
