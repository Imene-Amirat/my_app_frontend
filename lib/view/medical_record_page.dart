import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/databases/DBfamily.dart';

import 'package:my_app_frontend/databases/DBrecord.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/add_record_screen.dart';
import 'package:my_app_frontend/view/profile_screen.dart';
import 'package:my_app_frontend/view/record_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalRecordsPage extends StatefulWidget {
  static final pageRoute = '/medicalrecord';

  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> options = [];
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> records = [];
  List<Map<String, dynamic>> sps = [];
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    recordsFuture = Future.value([]);
    FamilyFuture = Future.value([]);
    //Load type records
    fetchTypeRecord();
    fetchDoctors();
    fetchRecords();
    fetchFamily(lastFetched: true);
    fetchData();
    fetchsp();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://flask-app-medical.vercel.app/relations.get'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          relations = jsonData
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(relations);
      } else {
        print('Failed to load options. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading options: $e');
    }
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

  Future<void> fetchDoctors() async {
    doctors = await DBDoctor.getAllDoctors();
  }

  //update the state with the new list of records
  Future<void> updatFetchRecords() async {
    bool isUserRecordsTab = _tabController?.index == 0;
    final userId = await getUserId();
    int? familyMemberId;

    // If it's not the user's records tab, get the family member ID
    if (!isUserRecordsTab) {
      familyMemberId = familyMembers.isNotEmpty
          ? familyMembers[_currentFamilyMemberIndex]['id']
          : null;
    }
    /*setState(() {
      recordsFuture = DBRecord.fetchAllRecordsForUser(userId);
    });*/
    if (isUserRecordsTab) {
      // Fetch and refresh user records if it's the user's tab
      setState(() {
        recordsFuture = DBRecord.fetchAllRecordsForUser(userId);
      });
    } else {
      // Fetch and refresh family records if it's the family records tab
      setState(() {
        FamilyFuture =
            DBRecord.fetchAllRecordsForFamilyMember(userId, familyMemberId!);
      });
    }
    /*try {
      final String? userId = await getUserId();
      // Fetch the latest records
      final List<Map<String, dynamic>> updatedRecords =
          await DBRecord.fetchAllRecordsForUser(userId);
      setState(() {
        // Update your state with the new records
        this.records = updatedRecords;
      });
    } catch (e) {
      print('Error fetching records: $e');
    }*/
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

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  Future<void> _navigateAndRefreshList() async {
    final String? userId = await getUserId();
    // Check if the current tab is for the user's records or family records
    bool isUserRecordsTab = _tabController?.index == 0;
    final int? familyMemberId = isUserRecordsTab
        ? null // Don't pass any familyMemberId when it's the user's tab
        : familyMembers.isNotEmpty
            ? familyMembers[_currentFamilyMemberIndex]['id']
            : null;
    print(familyMemberId);
    // Navigate and wait for the result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => AddRecordScreen(
                userId: userId,
                familyMemberId: familyMemberId,
              )),
    );
    if (result == true) {
      /*await updatFetchRecords();
      setState(() {
        //trigger a rebuild of the widget with the updated records
      });*/
      fetchRecords();
      /*setState(() {
        FamilyFuture =
            DBRecord.fetchAllRecordsForFamilyMember(userId, familyMemberId!);
      });*/
      if (!isUserRecordsTab) {
        // Only update FamilyFuture if it's the Family Records tab
        setState(() {
          FamilyFuture =
              DBRecord.fetchAllRecordsForFamilyMember(userId, familyMemberId!);
        });
      }
    }
  }

  void fetchRecords() async {
    final userId =
        await getUserId(); // Assuming getUserId() is a Future<String?>
    setState(() {
      recordsFuture = DBRecord.fetchAllRecordsForUser(userId);
    });
  }

  void fetchFamily({bool lastFetched = false}) async {
    final userId = await getUserId();
    print("Fetching family for user ID: $userId");
    final List<Map<String, dynamic>> fetchedFamilyMembers =
        await DBFamily.fetchAllFamily(userId);
    setState(() {
      FamilyFuture = DBFamily.fetchAllFamily(userId);
      familyMembers = fetchedFamilyMembers;
      if (lastFetched && familyMembers.isNotEmpty) {
        // Set the index to the last fetched member
        _currentFamilyMemberIndex = familyMembers.length - 1;
        // Fetch records for the last family member
        fetchRecordsForFamilyMember(
            familyMembers[_currentFamilyMemberIndex]['id']);
      }
    });
  }

  bool isFabVisible = true;

  Future<List<Map<String, dynamic>>>? recordsFuture;
  Future<List<Map<String, dynamic>>>? FamilyFuture;
  List<Map<String, dynamic>> relations = [];
  List<Map<String, dynamic>> familyMembers = [];
  int _currentFamilyMemberIndex = 0;

  void fetchRecordsForFamilyMember(int? familyMemberId) async {
    final userId = await getUserId();
    if (familyMemberId == null) return;
    final records =
        await DBRecord.fetchAllRecordsForFamilyMember(userId, familyMemberId);
    setState(() {
      FamilyFuture =
          Future.value(records); // Update the Future for the FutureBuilder
    });
  }

  String _getTypeRelationById(int id) {
    var typeRecord = relations.firstWhere((option) => option['id'] == id,
        orElse: () => {"id": -1, "name": 'loading....'});
    return typeRecord['name'];
  }

  //method to determine the avatar based on the relation
  Widget getRelationAvatar(String relation) {
    switch (relation.toLowerCase()) {
      case "father":
        return Image.asset('assets/avatars/father.png', fit: BoxFit.cover);
      case "grandfather":
        return Image.asset('assets/avatars/grandpa.png', fit: BoxFit.cover);
      case "mother":
        return Image.asset('assets/avatars/mother.png', fit: BoxFit.cover);
      case "grandmother":
        return Image.asset('assets/avatars/grandmother.png', fit: BoxFit.cover);
      case "son":
        return Image.asset('assets/avatars/son.png', fit: BoxFit.cover);
      case "daughter":
        return Image.asset('assets/avatars/daughter.png', fit: BoxFit.cover);
      default:
        return Image.asset('assets/avatars/father.png', fit: BoxFit.cover);
    }
  } // This could be populated from a database or API call

  Future<void> _updateDoctorsList() async {
    setState(() {});
  }

  Map<dynamic, Widget> children = <dynamic, Widget>{
    0: Text('My Records'),
    1: Text('Family Records'),
  };

  int selectedControl = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left,
            size: 30,
          ),
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: const Text('List of Medical Records ',
            style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.grey,
          tabs: [
            Tab(text: 'My Records'),
            Tab(text: 'Family Records'),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        // show/hide FAB
        visible: isFabVisible,
        child: FloatingActionButton.extended(
          label: Text("Add Record"),
          icon: Icon(Icons.add),
          onPressed: _navigateAndRefreshList,
          backgroundColor: GlobalColors.mainColor, // Background color
          foregroundColor: Colors.white, // Text color
          elevation: 5,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Records Tab
          FutureBuilder<List<Map<String, dynamic>>>(
            future: recordsFuture ?? Future.value([]),
            builder: (context, snapshot) =>
                _build_list_records(context, snapshot),
          ),
          // Family Records Tab
          Column(
            children: [
              _buildFamilyMemberNavigation(), // This will be displayed above the list
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: FamilyFuture ?? Future.value([]),
                  builder: (context, snapshot) =>
                      _build_list_records(context, snapshot),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build_list_records(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<Map> items = snapshot.data!;
      if (options.isEmpty) {
        //data is still loading, show a placeholder or loading indicator
        return Center(child: CircularProgressIndicator());
      }
      if (sps.isEmpty) {
        //data is still loading, show a placeholder or loading indicator
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.data.isEmpty) {
        return Center(child: Text('No records found.\n      Add a new one!'));
      }
      // detect scroll direction changes and adjust the visibility of the FAB accordingly
      return Expanded(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              //up
              if (!isFabVisible) setState(() => isFabVisible = true);
            } else if (notification.direction == ScrollDirection.reverse) {
              //down
              if (isFabVisible) setState(() => isFabVisible = false);
            }
            return true;
          },
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 10,
                margin: EdgeInsets.all(8.0), //spacing around the card
                child: ListTile(
                  title:
                      Text(_getTypeRecordById(items[index]['record_type_id'])),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dr." +
                          _getDoctorNameById(items[index]['doctor_id']) +
                          "," +
                          _getDoctorSpById(items[index]['doctor_id'])),
                      Text(items[index]['date']),
                    ],
                  ),
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
                              items[index]['id'], items[index]['is_favorite']);
                          // Fetch the updated records to refresh the UI
                          fetchRecords();
                          final String? userId = await getUserId();
                          // Check if the current tab is for the user's records or family records
                          bool isUserRecordsTab = _tabController?.index == 0;
                          final int? familyMemberId = isUserRecordsTab
                              ? null // Don't pass any familyMemberId when it's the user's tab
                              : familyMembers.isNotEmpty
                                  ? familyMembers[_currentFamilyMemberIndex]
                                      ['id']
                                  : null;
                          if (!isUserRecordsTab) {
                            // Only update FamilyFuture if it's the Family Records tab
                            setState(() {
                              FamilyFuture =
                                  DBRecord.fetchAllRecordsForFamilyMember(
                                      userId, familyMemberId!);
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          LineAwesomeIcons.angle_right,
                          size: 25,
                        ),
                        onPressed: () async {
                          // Find the doctor's name using the doctor_id
                          String doctorName =
                              _getDoctorNameById(items[index]['doctor_id']);
                          // Find the record type name using the record_type_id
                          String recordTypeName = _getTypeRecordById(
                              items[index]['record_type_id']);
                          String spName =
                              _getDoctorSpById(items[index]['doctor_id']);
                          // Add the doctor's name and record type name to the record map
                          Map<String, dynamic> recordWithDetails =
                              Map.from(items[index]);
                          recordWithDetails['doctorName'] = doctorName;
                          recordWithDetails['recordTypeName'] = recordTypeName;
                          recordWithDetails['doctorSp'] = spName;
                          print(items[index]);
                          // Navigate to the detail screen with the selected record
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecordDetailScreen(record: recordWithDetails),
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
            },
          ),
        ),
      );
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return CircularProgressIndicator();
  }

  Widget _buildFamilyMemberNavigation() {
    // Dropdown menu items list
    List<DropdownMenuItem<int>> familyMemberItems = familyMembers
        .map<DropdownMenuItem<int>>((member) => DropdownMenuItem<int>(
              value: member['id'],
              child: Text(member['name']),
            ))
        .toList();

    // Handle the case when there are no family members
    if (familyMemberItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("No family members found."),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<int>(
        isExpanded: true,
        items: familyMemberItems,
        onChanged: (value) {
          // When a new item is selected, update the UI and fetch records for the selected family member
          setState(() {
            _currentFamilyMemberIndex =
                familyMembers.indexWhere((member) => member['id'] == value);
            print(_currentFamilyMemberIndex);
          });
          fetchRecordsForFamilyMember(value);
        },
        value: familyMembers.isNotEmpty
            ? familyMembers[_currentFamilyMemberIndex]['id']
            : null,
        underline: Container(
          height: 2,
          color: GlobalColors.mainColor,
        ),
      ),
    );
  }
}
