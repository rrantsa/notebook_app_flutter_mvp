import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/notebook.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('printable_notebook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notebooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        year INTEGER NOT NULL,
        subtitle TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notebookId INTEGER NOT NULL,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        caption TEXT NOT NULL,
        imagePath TEXT,
        FOREIGN KEY (notebookId) REFERENCES notebooks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertNotebook(Notebook notebook) async {
    final db = await instance.database;
    return await db.insert('notebooks', notebook.toMap());
  }

  Future<List<Notebook>> getNotebooks() async {
    final db = await instance.database;
    final result = await db.query('notebooks', orderBy: 'year DESC, id DESC');

    return result.map((json) => Notebook.fromMap(json)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesByNotebookId(int notebookId) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'notebookId = ?',
      whereArgs: [notebookId],
      orderBy: 'date DESC, id DESC',
    );

    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> deleteNotebook(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notebooks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}