import 'package:collecta/models/transect_point.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransectPointDatabase {
  static final TransectPointDatabase instance = TransectPointDatabase._init();

  static Database? _database;

  TransectPointDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transect_point.db');
    return _database!;
  }

  Future<Database> _initDB(String s) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, s);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
    CREATE TABLE $tableTransectPoint (
      ${TransectPointFields.id} $idType,
      ${TransectPointFields.species} $textType,
      ${TransectPointFields.soil} $boolType,
      ${TransectPointFields.mulch} $boolType,
      ${TransectPointFields.stone} $boolType,
      ${TransectPointFields.rock} $boolType,
      ${TransectPointFields.annotations} $textType,
      ${TransectPointFields.created} $textType,
      ${TransectPointFields.mark} $textType,
      ${TransectPointFields.hits} $intType,
      ${TransectPointFields.areaId} $intType,
      ${TransectPointFields.teamId} $intType
       )
  ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Create Point
  Future<TransectPoint> create(TransectPoint measureArea) async {
    final db = await instance.database;
    final id = await db.insert(tableTransectPoint, measureArea.toJSON());
    return measureArea.copy(id: id);
  }

  // Read single Point
  Future<TransectPoint> readTransectPoint(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTransectPoint,
      columns: TransectPointFields.values,
      where: '${TransectPointFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransectPoint.fromJSON(maps.first);
    } else {
      throw Exception('ID not found');
    }
  }

  // Read all points
  Future<List<TransectPoint>> readAll() async {
    final db = await instance.database;
    final result = await db.query(tableTransectPoint);

    return result.map((e) => TransectPoint.fromJSON(e)).toList();
  }

  Future<int> update(TransectPoint measureArea) async {
    final db = await instance.database;

    return db.update(
      tableTransectPoint,
      measureArea.toJSON(),
      where: '${TransectPointFields.id} = ?',
      whereArgs: [measureArea.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableTransectPoint,
      where: '${TransectPointFields.id} = ?',
      whereArgs: [id],
    );
  }
}
