import 'package:sqflite/sqflite.dart';
import 'package:my_app_frontend/databases/dbhelper.dart';

class DBRecord {
  static const tableName = 'record';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS record (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             title TEXT,
             date TEXT,
             description TEXT,
             doctor_id INTEGER,
             record_type_id INTEGER,
             user_id TEXT,
             family_member_id INTEGER,
             is_favorite INTEGER DEFAULT 0
           );''';

  static Future<int> insertRecord(int doctorId, int recordTypeId, String title,
      String date, String des, String userId, int? familyMemberId) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'doctor_id': doctorId,
      'record_type_id': recordTypeId,
      'title': title,
      'date': date,
      'description': des,
      'user_id': userId,
      'family_member_id': familyMemberId,
    };
    int id = await database.insert(
      'record',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> insertRecord1(int doctorId, int recordTypeId, String title,
      String date, String des, String userId) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'doctor_id': doctorId,
      'record_type_id': recordTypeId,
      'title': title,
      'date': date,
      'description': des,
      'user_id': userId,
    };
    int id = await database.insert(
      'record',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // Method to fetch all records but only returning type_record_id, doctor_id, and date
  static Future<List<Map<String, dynamic>>> fetchAllRecords() async {
    final database = await DBHelper.getDatabase();
    // Prepare the SQL query to select only doctor_id, record_type_id, and date columns from all records
    final String sqlQuery = '''
      SELECT id,title,description,doctor_id, record_type_id, date,is_favorite FROM $tableName
      ORDER BY date DESC; 
    '''; // Assuming you want to order the records by date in descending order
    // Execute the query
    final List<Map<String, dynamic>> records =
        await database.rawQuery(sqlQuery);
    return records;
  }

  static Future<List<Map<String, dynamic>>> fetchAllRecordsForUser(
      String? userId) async {
    final database = await DBHelper.getDatabase();
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final String sql =
        'SELECT id,title,description,doctor_id,record_type_id, date,is_favorite FROM $tableName WHERE user_id = ? AND family_member_id IS NULL ORDER BY date DESC;';
    final List<Map<String, dynamic>> records =
        await database.rawQuery(sql, [userId]);
    return records;
  }

  static Future<List<Map<String, dynamic>>> fetchAllRecordsForFamilyMember(
      String? userId, int familyMemberId) async {
    final database = await DBHelper.getDatabase();
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final String sql = '''
      SELECT id, title, description, doctor_id, record_type_id, date, is_favorite 
      FROM $tableName 
      WHERE user_id = ? AND family_member_id = ? 
      ORDER BY date DESC;
    ''';
    // Execute the query with userId and familyMemberId as parameters
    final List<Map<String, dynamic>> records =
        await database.rawQuery(sql, [userId, familyMemberId]);
    return records;
  }

  static Future<bool> deleteRecord(int recordId) async {
    final database = await DBHelper.getDatabase();
    int result = await database.delete(
      tableName,
      where: "id = ?",
      whereArgs: [recordId],
    );
    return result > 0;
  }

  static Future<void> toggleFavorite(int id, int currentFavorite) async {
    final db = await DBHelper.getDatabase();
    int newFavorite =
        currentFavorite == 1 ? 0 : 1; // Toggle the favorite status
    await db.update(
      tableName,
      {'is_favorite': newFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> fetchFavoriteRecordsForUser(
      String? userId) async {
    final db = await DBHelper.getDatabase();
    final String sql = '''
    SELECT * FROM $tableName
    WHERE user_id = ? AND is_favorite = 1
    ORDER BY date DESC;
  ''';
    final List<Map<String, dynamic>> records = await db.rawQuery(sql, [userId]);
    return records;
  }

  // A method to fetch all favorite records for the user and their family members, sorted by user first
  static Future<List<Map<String, dynamic>>> fetchSortedFavoriteRecords(
      String? userId) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }

    final db = await DBHelper.getDatabase();
    final String sql = '''
    SELECT r.id, r.title, r.description, r.doctor_id, r.record_type_id, r.date, r.is_favorite, r.family_member_id, f.name as family_member_name
    FROM $tableName as r
    LEFT JOIN family as f ON r.family_member_id = f.id
    WHERE r.user_id = ? AND r.is_favorite = 1
    ORDER BY r.family_member_id ASC, r.date DESC;
  ''';
    final List<Map<String, dynamic>> records = await db.rawQuery(sql, [userId]);
    return records;
  }
}
