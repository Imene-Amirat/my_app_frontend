import 'package:my_app_frontend/databases/dbhelper.dart';
import 'package:sqflite/sqflite.dart';

class DBAppointment {
  static const tableName = 'Appointment';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS Appointment (
             Appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
             Date TEXT,
             Time TEXT,
             title TEXT,
             user_id TEXT
           );''';

  static Future<int> insertAppointment(
      String date, String time, String title, String userId) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'Date': date,
      'Time': time,
      'title': title,
      'user_id': userId,
    };
    int id = await database.insert(
      'Appointment',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> fetchAllAppointment(
      String? userId) async {
    final database = await DBHelper.getDatabase();
    // Prepare the SQL query to select
    final String sqlQuery = '''
      SELECT Appointment_id,Date,Time,title FROM $tableName WHERE user_id = ? ORDER BY Appointment_id DESC;
    ''';
    // Execute the query
    final List<Map<String, dynamic>> Appointment =
        await database.rawQuery(sqlQuery, [userId]);
    return Appointment;
  }

  static Future<bool> deleteAppointment(int id) async {
    final database = await DBHelper.getDatabase();
    int result = await database.delete(
      tableName,
      where: "Appointment_id = ?",
      whereArgs: [id],
    );
    return result > 0;
  }

  static Future<List<Map<String, dynamic>>> fetchAppointmentsByDate(
      String date, String? userId) async {
    final database = await DBHelper.getDatabase();
    final String sqlQuery = '''
    SELECT Appointment_id, Date, Time, title FROM $tableName WHERE user_id = ? AND Date = ? ORDER BY Appointment_id DESC;
  ''';
    final List<Map<String, dynamic>> appointments =
        await database.rawQuery(sqlQuery, [userId, date]);
    return appointments;
  }
}
