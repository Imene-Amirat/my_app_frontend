import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/databases/DBrecord.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/record_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRecordsScreen extends StatefulWidget {
  const FavoriteRecordsScreen({super.key});

  @override
  State<FavoriteRecordsScreen> createState() => _FavoriteRecordsScreenState();
}

class _FavoriteRecordsScreenState extends State<FavoriteRecordsScreen> {
  Future<List<Map<String, dynamic>>>? recordsFuture;
  List<Map<String, dynamic>> options = [];
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    recordsFuture = Future.value([]);
    //Load type records
    fetchTypeRecord();
    fetchDoctors();
    fetchRecords();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  void fetchRecords() async {
    final userId =
        await getUserId(); // Assuming getUserId() is a Future<String?>
    setState(() {
      recordsFuture = DBRecord.fetchFavoriteRecordsForUser(userId);
    });
  }

  String _getTypeRecordById(int id) {
    var typeRecord = options.firstWhere((option) => option['id'] == id,
        orElse: () => {"id": -1, "name": 'loading....'});
    return typeRecord['name'];
  }

  String _getDoctorNameById(int doctorId) {
    final doctor = doctors.firstWhere(
      (doc) => doc['doctor_id'] == doctorId,
      orElse: () => {'name': 'loading....'},
    );
    return doctor['name'];
  }

  Future<void> fetchTypeRecord() async {
    try {
      final response = await http
          .get(Uri.parse('https://flask-app-medical.vercel.app/records.type'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          options = jsonData
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(options);
      } else {
        print('Failed to load options. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading options: $e');
    }
  }

  Future<void> fetchDoctors() async {
    final userId = await getUserId();
    doctors = await DBDoctor.getAllDoctors();
  }

  Future<void> updatFetchRecords() async {
    final userId = await getUserId();
    int? familyMemberId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: GlobalColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text("Favorite Records", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: recordsFuture ?? Future.value([]),
          builder: (context, snapshot) {
            if (options.isEmpty) {
              //data is still loading, show a placeholder or loading indicator
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.data!.isEmpty) {
              return Center(child: Text("No favorite records found."));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    List<Map> items = snapshot.data!;
                    return Card(
                      elevation: 10,
                      margin: EdgeInsets.all(8.0), //spacing around the card
                      child: ListTile(
                        title: Text(
                            _getTypeRecordById(items[index]['record_type_id'])),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, //start from the left
                          children: [
                            Text("Dr." +
                                _getDoctorNameById(items[index]['doctor_id'])),
                            Text(items[index]['date']),
                          ],
                        ),
                        // Add trailing to show the delete icon
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Add this line
                          children: [
                            IconButton(
                              icon: Icon(
                                items[index]['is_favorite'] == 1
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: items[index]['is_favorite'] == 1
                                    ? Colors.red
                                    : null,
                              ),
                              onPressed: () async {
                                // Toggle the favorite status in the database
                                await DBRecord.toggleFavorite(
                                    items[index]['id'],
                                    items[index]['is_favorite']);
                                // Fetch the updated records to refresh the UI
                                fetchRecords(); // Ensure this method reloads data including the is_favorite status
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                LineAwesomeIcons.angle_right,
                                size: 25,
                              ),
                              onPressed: () async {
                                // Find the doctor's name using the doctor_id
                                String doctorName = _getDoctorNameById(
                                    items[index]['doctor_id']);
                                // Find the record type name using the record_type_id
                                String recordTypeName = _getTypeRecordById(
                                    items[index]['record_type_id']);
                                // Add the doctor's name and record type name to the record map
                                Map<String, dynamic> recordWithDetails =
                                    Map.from(items[index]);
                                recordWithDetails['doctorName'] = doctorName;
                                recordWithDetails['recordTypeName'] =
                                    recordTypeName;
                                print(items[index]);
                                // Navigate to the detail screen with the selected record
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecordDetailScreen(
                                        record: recordWithDetails),
                                  ),
                                );
                                if (res == true) {
                                  await updatFetchRecords();
                                  setState(() {
                                    //trigger a rebuild of the widget with the updated records
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
