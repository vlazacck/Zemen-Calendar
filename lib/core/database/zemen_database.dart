import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ZemenDatabase {
  static final ZemenDatabase instance = ZemenDatabase._init();

  static Database? _database;

  ZemenDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('zemen_calendar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        title_amharic TEXT,
        notes TEXT,
        calendar_system TEXT NOT NULL,
        eth_year INTEGER,
        eth_month INTEGER,
        eth_day INTEGER,
        greg_date TEXT,
        time_hour INTEGER NOT NULL,
        time_minute INTEGER NOT NULL,
        recurrence_type TEXT NOT NULL,
        recurrence_interval INTEGER NOT NULL,
        is_active INTEGER NOT NULL,
        category TEXT NOT NULL,
        color_hex TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        title_amharic TEXT,
        description TEXT,
        calendar_system TEXT NOT NULL,
        eth_year INTEGER NOT NULL,
        eth_month INTEGER NOT NULL,
        eth_day INTEGER NOT NULL,
        greg_date TEXT NOT NULL,
        is_recurring_yearly INTEGER NOT NULL,
        event_type TEXT NOT NULL,
        color_hex TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_notes (
        id TEXT PRIMARY KEY,
        eth_year INTEGER NOT NULL,
        eth_month INTEGER NOT NULL,
        eth_day INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_queue (
        id TEXT PRIMARY KEY,
        reminder_id TEXT,
        notification_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        scheduled_for TEXT NOT NULL,
        status TEXT NOT NULL,
        payload TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
