import 'package:sqflite/sqflite.dart';
import 'package:my_app_frontend/databases/dbhelper.dart';

class DBDoctor {
  static const tableName = 'doctor';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS doctor (
             doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT,
             state_id INTEGER,
             country_id INTEGER,
             phone INTEGER,
             created_by_id INTEGER,
             validated TEXT,
             specialty_id INTEGER
           );''';

  static Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final database = await DBHelper.getDatabase();

    return database.rawQuery('''SELECT 
            doctor_id ,
            name,
            state_id,
            country_id,
            phone,
            created_by_id,
            validated,
            specialty_id
          from ${tableName}
          ''');
  }

  static Future<List<Map<String, dynamic>>> getAllDoctorsByKeyword(
      String keyword) async {
    if (keyword.trim().isEmpty) return getAllDoctors();

    final database = await DBHelper.getDatabase();

    // Use parameterized query to avoid SQL injection
    final keywordPattern = '%${keyword.trim()}%'.toLowerCase();

    final query = '''
    SELECT 
      doctor_id,
      name,
      specialty_id
    FROM $tableName
    WHERE LOWER(name) LIKE ?
    ORDER BY name ASC
  ''';

    // Execute the query
    return await database.rawQuery(query, [keywordPattern]);
  }

  static Future<int> getDoctorByName(String name) async {
    final database = await DBHelper.getDatabase();

    List<Map> res = await database.rawQuery('''SELECT 
            id  
          from ${tableName}
          where name='$name'
          ''');
    return res[0]['id'] ?? 0;
  }

  static Future<int> insertDoctor(
      String name, int specialtyId, int countryid) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'name': name,
      'country_id': countryid,
      'specialty_id': specialtyId,
    };
    int id = await database.insert(
      'doctor',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<bool> deleteDoctor(int doctorId) async {
    final database = await DBHelper.getDatabase();
    int result = await database.delete(
      tableName,
      where: "doctor_id = ?",
      whereArgs: [doctorId],
    );
    return result > 0;
  }

  static Future<bool> updateDoctor(int id, Map<String, dynamic> data) async {
    final database = await DBHelper.getDatabase();
    database.update(tableName, data, where: "id=?", whereArgs: [id]);
    return true;
  }
}
