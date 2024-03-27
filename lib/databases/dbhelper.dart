import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app_frontend/databases/DBappointment.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/databases/DBfamily.dart';
import 'package:my_app_frontend/databases/DBimage.dart';
import 'package:my_app_frontend/databases/DBrecord.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//DBHelper class is a utility class for managing an SQLite database in a Flutter application (creation and versioning.)
class DBHelper {
  //Constants for the database name and version.
  static const _database_name = "Medhistory.db";
  static const _database_version = 17;

  //A variable to hold the reference to the database.
  static var database;

  // A method to get or create the database.
  static Future getDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    if (database != null) {
      return database;
    }

    //list named sql_create_code, which is a list of strings. Each string in the list represents the SQL code necessary to create a table in an SQLite database
    List sql_create_code = [
      DBDoctor.sql_code,
      DBRecord.sql_code,
      DBImage.sql_code,
      DBFamily.sql_code,
      DBAppointment.sql_code,
    ];

    // Open the database, create tables if they don't exist.
    database = openDatabase(join(await getDatabasesPath(), _database_name),
        onCreate: (database, version) {
          for (var sql_code in sql_create_code) database.execute(sql_code);
        },
        version: _database_version,
        onUpgrade: (database, oldVersion, newVersion) {
          print(">>>>>>>>>>>>>$oldVersion vs $newVersion");
          if (oldVersion != newVersion) {
            database.execute('DROP TABLE IF EXISTS doctor');
            database.execute(''' CREATE TABLE IF NOT EXISTS doctor (
             doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT,
             state_id INTEGER,
             country_id INTEGER,
             wilaya TEXT,
             specialty TEXT,
             phone INTEGER,
             created_by_id INTEGER,
             validated TEXT,
             specialty_id INTEGER,
             user_id TEXT
          );''');
            for (var sql_code in sql_create_code) database.execute(sql_code);
          }
        });
    return database;
  }
}
