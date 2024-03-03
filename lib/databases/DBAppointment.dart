import 'package:my_app_frontend/databases/dbhelper.dart';
import 'package:sqflite/sqflite.dart';

class DBAppointment {
  static const tableName = 'Appointment';

  static const sql_code = '''
         CREATE TABLE IF NOT EXISTS Appointment (
             Appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
             Date TEXT,
             Time TEXT,
             title TEXT
           );''';

  static Future<int> insertAppointment(String date, String time) async {
    final database = await DBHelper.getDatabase();
    final Map<String, dynamic> data = {
      'Date': date,
      'Time': time,
    };
    int id = await database.insert(
      'Appointment',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }
}
