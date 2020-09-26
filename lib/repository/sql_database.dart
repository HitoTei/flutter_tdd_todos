import 'package:flutter_riverpod/all.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final sqlDatabaseClient = Provider.autoDispose((_) => SqlDatabase());

class SqlDatabase {
  factory SqlDatabase() => _cache ??= SqlDatabase._internal();
  SqlDatabase._internal() {
    _database = _createDatabase();
  }
  static SqlDatabase _cache;
  Future<Database> _database;
  static const _table = 'todo';

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final db = await _database;
    final jsonList = await db.query(_table);
    return jsonList.map((e) {
      return {
        'id': e['id'],
        'label': e['label'],
        'completed': e['completed'] == 1,
      };
    }).toList();
  }

  Future<int> insert(Map<String, dynamic> todo) async {
    final db = await _database;

    return db.insert(
      _table,
      {
        'id': todo['id'],
        'label': todo['label'],
        'completed': todo['completed'] ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(Map<String, dynamic> todo) async {
    final db = await _database;
    return db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [
        todo['id'],
      ],
    );
  }

  Future<Database> _createDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'tdd_todo_list.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          label TEXT,
          completed INTEGER
        );
        ''');
      },
    );
  }
}
