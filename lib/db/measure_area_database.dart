import 'dart:math';

import 'package:collecta/models/measure_area.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Earth radius
const double R = 6378137;
// Offset tolerance in meters
const double EPS = 500;

class MeasureAreaDatabase {
  static final MeasureAreaDatabase instance = MeasureAreaDatabase._init();

  static Database? _database;

  MeasureAreaDatabase._init();

  double latPlusOffset(String lat, double meters) {
    return (double.parse(lat) + (meters / R) * 180 / pi);
  }

  double latMinusOffset(String lat, double meters) {
    return (double.parse(lat) - (meters / R) * 180 / pi);
  }

  double lonPlusOffset(String lat, String lon, double meters) {
    return (double.parse(lon) +
        (meters / (R * cos(pi * double.parse(lat) / 180))) * 180 / pi);
  }

  double lonMinusOffset(String lat, String lon, double meters) {
    return (double.parse(lon) -
        (meters / (R * cos(pi * double.parse(lat) / 180))) * 180 / pi);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('measure_area.db');
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
    final intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableMeasureArea (
      ${MeasureAreaFields.id} $idType,
      ${MeasureAreaFields.lat} $textType,
      ${MeasureAreaFields.lon} $textType,
      ${MeasureAreaFields.annotations} $textType,
      ${MeasureAreaFields.uTMZone} $textType,
      ${MeasureAreaFields.geographicSystem} $textType,
      ${MeasureAreaFields.projectId} $intType
       )
  ''');
  }

  Future<MeasureArea> create(MeasureArea measureArea) async {
    final db = await instance.database;
    final id = await db.insert(tableMeasureArea, measureArea.toJSON());
    return measureArea.copy(id: id);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<dynamic>> readCloseAreas(String lat, String lon) async {
    final db = await instance.database;

    var orderBy = "${MeasureAreaFields.lat} ASC, ${MeasureAreaFields.lon} ASC";
    final maps = await db.query(tableMeasureArea,
        columns: MeasureAreaFields.values,
        // Question marks and argument syntax intends to prevent SQL injection attacks
        where:
            'CAST(${MeasureAreaFields.lat} as FLOAT) <= ?  AND CAST(${MeasureAreaFields.lat} as FLOAT) >= ? AND CAST(${MeasureAreaFields.lon} as FLOAT) <= ? AND CAST(${MeasureAreaFields.lon} as FLOAT) >= ?',
        orderBy: orderBy,
        whereArgs: [
          latPlusOffset(lat, EPS),
          latMinusOffset(lat, EPS),
          lonPlusOffset(lat, lon, EPS),
          lonMinusOffset(lat, lon, EPS),
        ]);
    return maps.map((json) => MeasureArea.fromJSON(json)).toList();
  }

  Future<int> update(MeasureArea measureArea) async {
    final db = await instance.database;

    return db.update(
      tableMeasureArea,
      measureArea.toJSON(),
      where: '${MeasureAreaFields.id} = ?',
      whereArgs: [measureArea.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableMeasureArea,
      where: '${MeasureAreaFields.id} = ?',
      whereArgs: [id],
    );
  }
}
