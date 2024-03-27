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
             wilaya TEXT,
             specialty TEXT,
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
            specialty_id,
            specialty,
            wilaya
          from ${tableName}
          ''');
  }

  /*static Future<List<Map<String, dynamic>>> getAllDoctorsByKeyword(
      String keywordName, int keySp, int keyRg) async {
    if (keywordName.trim().isEmpty) return getAllDoctors();

    final database = await DBHelper.getDatabase();

    // Use parameterized query to avoid SQL injection
    final keywordPattern = '%${keywordName.trim()}%'.toLowerCase();

    final query = '''
    SELECT 
      doctor_id,
      name,
      specialty_id,
      country_id
    FROM $tableName
    WHERE (LOWER(name) LIKE ? OR specialty_id = ? OR country_id = ? )
    ORDER BY name ASC
  ''';

    // Execute the query
    return await database.rawQuery(query, [keywordPattern, keySp, keyRg]);
  }*/

  static Future<List<Map<String, dynamic>>> getAllDoctorsByKeyword(
      String keywordName, String keySp, String keyRg) async {
    final database = await DBHelper.getDatabase();

    // Start with a base query that fetches all doctors
    String query = '''
    SELECT 
      doctor_id,
      name,
      specialty_id,
      country_id,
      wilaya,
      specialty
    FROM $tableName
    WHERE 1=1
  ''';

    List<dynamic> params = [];

    // filter by name if keywordName is not empty
    if (keywordName.trim().isNotEmpty) {
      query += ' AND LOWER(name) LIKE ?';
      params.add('%${keywordName.trim().toLowerCase()}%');
    }

    // filter by specialty if keySp is provided
    if (keySp.isNotEmpty) {
      // Assuming 0 is an invalid ID and thus not used
      query += ' AND LOWER(specialty) LIKE ?';
      params.add('%${keySp.toLowerCase()}%');
    }

    // filter by region if keyRg is provided
    if (keyRg.isNotEmpty) {
      // Assuming 0 is an invalid ID and thus not used
      query += ' AND LOWER(wilaya) LIKE ?';
      params.add('%${keyRg.toLowerCase()}%');
    }

    query += ' ORDER BY name ASC';

    return await database.rawQuery(query, params);
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
      String name, int specialtyId, int countryid, String sp, String rg) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'name': name,
      'country_id': countryid,
      'specialty_id': specialtyId,
      'wilaya': rg,
      'specialty': sp,
    };
    int id = await database.insert(
      'doctor',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> insertDoctor1(Map<String, dynamic> doctor) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'name': doctor['name'],
      'wilaya': doctor['wilaya'],
      'specialty': doctor['specialty'],
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
