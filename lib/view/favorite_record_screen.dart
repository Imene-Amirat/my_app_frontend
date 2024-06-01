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
  List<Map<String, dynamic>> sps = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    recordsFuture = Future.value([]);
    //Load type records
    fetchTypeRecord();
    fetchDoctors();
    fetchRecords();
    fetchsp();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  void fetchRecords() async {
    final userId = await getUserId();
    setState(() {
      recordsFuture = DBRecord.fetchSortedFavoriteRecords(userId);
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

  Future<void> fetchsp() async {
    try {
      final response = await http.get(
          Uri.parse('https://flask-app-medical.vercel.app/specialties.get'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          sps = jsonData
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(sps);
      } else {
        print('Failed to load options. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading options: $e');
    }
  }

  String _getDoctorSpById(int doctorId) {
    // Find the doctor by ID to get their specialty_id
    final doctor = doctors.firstWhere(
      (doc) => doc['doctor_id'] == doctorId,
      orElse: () => {'specialty_id': -1},
    );

    // Use the doctor's specialty_id to find the corresponding specialty name
    final specialty = sps.firstWhere(
      (sp) => sp['id'] == doctor['specialty_id'],
      orElse: () => {'name': 'loading...'},
    );

    return doctor['specialty'];
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: recordsFuture ?? Future.value([]),
              builder: (context, snapshot) {
                if (options.isEmpty) {
                  //data is still loading, show a placeholder or loading indicator
                  return Center(child: CircularProgressIndicator());
                }
                if (sps.isEmpty) {
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
                  return buildRecordList(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecordList(List<Map<String, dynamic>> records) {
    String? currentGroupName;

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        bool isUserRecord = records[index]['family_member_id'] == null;
        String groupName = isUserRecord
            ? "My Records"
            : "${records[index]['family_member_name']} Records";

        // Determine if this is the start of a new group
        bool isNewGroup = index == 0 || currentGroupName != groupName;
        if (isNewGroup) {
          currentGroupName = groupName; // Update the current group tracker
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNewGroup) // Only add a new title if it's a new group
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  groupName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            Card(
              elevation: 10,
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title:
                    Text(_getTypeRecordById(records[index]['record_type_id'])),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getDoctorNameById(records[index]['doctor_id']) +
                        "," +
                        _getDoctorSpById(records[index]['doctor_id'])),
                    Text(records[index]['date']),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        records[index]['is_favorite'] == 1
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: records[index]['is_favorite'] == 1
                            ? Colors.red
                            : null,
                      ),
                      onPressed: () async {
                        await DBRecord.toggleFavorite(records[index]['id'],
                            records[index]['is_favorite']);
                        fetchRecords();
                      },
                    ),
                    IconButton(
                      icon: Icon(LineAwesomeIcons.angle_right, size: 25),
                      onPressed: () async {
                        String doctorName =
                            _getDoctorNameById(records[index]['doctor_id']);
                        String recordTypeName = _getTypeRecordById(
                            records[index]['record_type_id']);
                        String spName =
                            _getDoctorSpById(records[index]['doctor_id']);
                        Map<String, dynamic> recordWithDetails =
                            Map.from(records[index]);
                        recordWithDetails['doctorName'] = doctorName;
                        recordWithDetails['recordTypeName'] = recordTypeName;
                        recordWithDetails['doctorSp'] = spName;
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecordDetailScreen(record: recordWithDetails),
                          ),
                        );
                        if (res == true) {
                          fetchRecords();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
