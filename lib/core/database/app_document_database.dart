import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseDocument {
  const DatabaseDocument({required this.id, required this.payload});

  final String id;
  final Map<String, dynamic> payload;
}

class AppDocumentDatabase {
  AppDocumentDatabase._(this._database);

  final Database _database;

  static Future<AppDocumentDatabase> open() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'explore_nepal.db');

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents(
            collection TEXT NOT NULL,
            document_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            PRIMARY KEY(collection, document_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_state(
            collection TEXT PRIMARY KEY,
            synced_at TEXT NOT NULL,
            source TEXT
          )
        ''');
      },
    );

    return AppDocumentDatabase._(database);
  }

  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    final rows = await _database.query(
      'documents',
      columns: ['payload'],
      where: 'collection = ?',
      whereArgs: [collection],
      orderBy: 'document_id ASC',
    );

    return rows
        .map(
          (row) =>
              jsonDecode(row['payload']! as String) as Map<String, dynamic>,
        )
        .toList();
  }

  Future<void> upsert(String collection, DatabaseDocument document) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.insert('documents', {
      'collection': collection,
      'document_id': document.id,
      'payload': jsonEncode(document.payload),
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> replaceCollection(
    String collection,
    Iterable<DatabaseDocument> documents,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction((txn) async {
      await txn.delete(
        'documents',
        where: 'collection = ?',
        whereArgs: [collection],
      );

      final batch = txn.batch();
      for (final document in documents) {
        batch.insert('documents', {
          'collection': collection,
          'document_id': document.id,
          'payload': jsonEncode(document.payload),
          'updated_at': now,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> markCollectionSynced({
    required String collection,
    required DateTime syncedAt,
    String? source,
  }) async {
    await _database.insert('sync_state', {
      'collection': collection,
      'synced_at': syncedAt.toIso8601String(),
      'source': source,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime?> getLastSyncedAt(String collection) async {
    final rows = await _database.query(
      'sync_state',
      columns: ['synced_at'],
      where: 'collection = ?',
      whereArgs: [collection],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rows.first['synced_at']! as String);
  }
}
