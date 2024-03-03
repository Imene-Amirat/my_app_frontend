import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:my_app_frontend/databases/dbhelper.dart';

class DBImage {
  static const tableName = 'images';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            record_id INTEGER,
            image_path TEXT
           );''';

  static Future<int> insertImagePath(int recordId, String imagePath) async {
    final database = await DBHelper.getDatabase();
    final data = {
      'record_id': recordId,
      'image_path': imagePath,
    };
    return await database.insert('images', data);
  }

  //
  static Future<List<String>> getImagePathsForRecord(int recordId) async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> pathsData = await database.query(
      'images',
      columns: ['image_path'],
      where: 'record_id = ?',
      whereArgs: [recordId],
    );

    return pathsData
        .map((pathData) => pathData['image_path'] as String)
        .toList();
  }

  static Future<void> deleteImagesForRecord(int recordId) async {
    final database = await DBHelper.getDatabase();
    await database.delete(
      'images',
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
  }
}
