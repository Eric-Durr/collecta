import 'dart:math';

import 'package:collecta/models/species.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SepeciesNamesDatabase {
  static final SepeciesNamesDatabase instance = SepeciesNamesDatabase._init();

  static Database? _database;

  SepeciesNamesDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('species_names.db');
    return _database!;
  }

  Future<Database> _initDB(String s) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, s);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableSimpleSpecies (
      ${SimpleSpeciesFields.id} $idType,
      ${SimpleSpeciesFields.name} $textType,
       )
  ''');
  }

  Future<SimpleSpecies> create(SimpleSpecies species) async {
    final db = await instance.database;
    final id = await db.insert(tableSimpleSpecies, species.toJSON());
    return species.copy(id: id);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<dynamic>> readAllSpecies(String lat, String lon) async {
    final db = await instance.database;

    var orderBy = "${SimpleSpeciesFields.name} ASC";
    final maps = await db.query(
      tableSimpleSpecies,
      columns: SimpleSpeciesFields.values,
      // Question marks and argument syntax intends to prevent SQL injection attacks
      orderBy: orderBy,
    );
    return maps.map((json) => SimpleSpecies.fromJSON(json)).toList();
  }

  Future<int> update(SimpleSpecies measureArea) async {
    final db = await instance.database;

    return db.update(
      tableSimpleSpecies,
      measureArea.toJSON(),
      where: '${SimpleSpeciesFields.id} = ?',
      whereArgs: [measureArea.id],
    );
  }
}
