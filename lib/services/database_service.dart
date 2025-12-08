import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prediction.dart';
import '../utils/constants.dart';

class DatabaseService {
  Database? _database;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        top3_predictions TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Create - Insert new prediction
  Future<int> insertPrediction(Prediction prediction) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableName,
      prediction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read - Get all predictions (sorted by newest)
  Future<List<Prediction>> getAllPredictions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableName,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Prediction.fromMap(maps[i]);
    });
  }

  // Read - Get prediction by ID
  Future<Prediction?> getPredictionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Prediction.fromMap(maps.first);
    }
    return null;
  }

  // Delete - Remove prediction by ID
  Future<int> deletePrediction(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Remove all predictions
  Future<int> deleteAllPredictions() async {
    final db = await database;
    return await db.delete(AppConstants.tableName);
  }

  // Get count of predictions
  Future<int> getPredictionCount() async {
    final db = await database;
    // FIXED: Use rawQuery with COUNT directly
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableName}');
    if (result.isNotEmpty) {
      return result.first['count'] as int? ?? 0;
    }
    return 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}