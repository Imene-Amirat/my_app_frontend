import 'package:sqflite/sqflite.dart';
import 'package:my_app_frontend/databases/dbhelper.dart';

class DBFamily {
  static const tableName = 'family';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS family (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(255) NOT NULL,
            relation_id INTEGER,
            user_id TEXT
           );''';

  static Future<List<Map<String, dynamic>>> fetchAllFamily(
      String? userId) async {
    final database = await DBHelper.getDatabase();
    // Prepare the SQL query to select
    final String sqlQuery = '''
      SELECT id,name,relation_id FROM $tableName WHERE user_id = ? ORDER BY id DESC;
    ''';
    // Execute the query
    final List<Map<String, dynamic>> FamilyMembers =
        await database.rawQuery(sqlQuery, [userId]);
    return FamilyMembers;
  }

  static Future<int> insertFamilyMember(
      String name, int relationId, String userId) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'name': name,
      'relation_id': relationId,
      'user_id': userId,
    };
    int id = await database.insert(
      'family',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<bool> deleteFamilyMember(int familyMemberId) async {
    final database = await DBHelper.getDatabase();
    int result = await database.delete(
      tableName,
      where: "id = ?",
      whereArgs: [familyMemberId],
    );
    return result > 0;
  }

  static Future<Map<String, dynamic>?> fetchFamilyMemberById(
      int memberId) async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> result = await database.query(
      tableName,
      where: "id = ?",
      whereArgs: [memberId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  static Future<void> updateFamilyMember(
    int id,
    String name,
    int relationId,
  ) async {
    final database = await DBHelper.getDatabase();
    final data = {
      'name': name,
      'relation_id': relationId,
    };
    await database.update(
      tableName,
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
