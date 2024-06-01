import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBfamily.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/add_family_member_screen.dart';
import 'package:my_app_frontend/view/modify_family_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  List<Map<String, dynamic>> familyMembers = [];
  List<Map<String, dynamic>> relations = [];
  String _userId = '';

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  void initState() {
    super.initState();
    fetchData();
    getUserId().then((id) {
      _userId = id!;
      updatFetchRecords(); // Now calls update without needing to pass userId
    });
  }

  //update the state with the new list of records
  Future<void> updatFetchRecords() async {
    try {
      // Fetch the latest records
      final List<Map<String, dynamic>> updatedRecords =
          await DBFamily.fetchAllFamily(_userId);
      setState(() {
        // Update your state with the new records
        this.familyMembers = updatedRecords;
      });
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  Future<void> _navigateAndRefreshList() async {
    // Navigate and wait for the result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddFamilyMemberPage()),
    );
    //waits for a result to come back,
    // Check if the record list needs to be refreshed
    if (result == true) {
      await updatFetchRecords();
      setState(() {
        //trigger a rebuild of the widget with the updated records
      });
    }
  }

  Future<void> _updateDoctorsList() async {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Family Members",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left,
            size: 30,
          ),
          color: Colors.white,
        ),
        backgroundColor: GlobalColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: _userId == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading until _userId is fetched
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: DBFamily.fetchAllFamily(_userId), // Now safe to use !
              builder: (context, snapshot) =>
                  _build_list_records(context, snapshot),
            ),
      /*FutureBuilder<List<Map<String, dynamic>>>(
        future: DBFamily.fetchAllFamily(_userId!),
        builder: (context, snapshot) => _build_list_records(context, snapshot),
      ),*/
      /*ListView.builder(
        itemCount: familyMembers.length,
        itemBuilder: (context, index) {
          final member = familyMembers[index];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: GlobalColors.mainColor), //border color
              borderRadius: BorderRadius.circular(27),
              color: Colors.transparent,
            ),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Padding(
              padding: EdgeInsets.all(1),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      24), // Match the outer Container border radius
                ),
                color: Colors.grey[100],
                elevation: 2,
                margin: EdgeInsets.all(0),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    child: getRelationAvatar(member["relation"]),
                  ),
                  title: Text(member['name']),
                  subtitle: Text("Relation: ${member['relation']}"),
                ),
              ),
            ),
          );
        },
      ),*/
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlobalColors.mainColor,
        foregroundColor: Colors.white,
        onPressed:
            _navigateAndRefreshList, //() => Get.to(() => AddFamilyMemberPage()),
        icon: Icon(Icons.add),
        label: Text('Add New Member'),
      ),
    );
  }

  Widget _build_list_records(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<Map> items = snapshot.data!;
      if (relations.isEmpty) {
        //data is still loading, show a placeholder or loading indicator
        return Center(child: CircularProgressIndicator());
      }
      //after data fetch but no data is available.
      if (snapshot.data.isEmpty) {
        return Center(
            child: Text('No family members found.\n          Add a new one!'));
      }
      return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: GlobalColors.mainColor), //border color
                borderRadius: BorderRadius.circular(27),
                color: Colors.transparent,
              ),
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        24), // Match the outer Container border radius
                  ),
                  color: Colors.grey[100],
                  elevation: 2,
                  margin: EdgeInsets.all(0),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      child: getRelationAvatar(
                          _getTypeRelationById(items[index]['relation_id'])),
                    ),
                    title: Text(items[index]['name']),
                    subtitle: Text("Relation: " +
                        _getTypeRelationById(items[index]['relation_id'])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            int memberId = familyMembers[index]['id'];
                            print(memberId);
                            final ress = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModifyFamilyScreen(memberId: memberId),
                              ),
                            );
                            if (ress == true) {
                              await updatFetchRecords();
                              setState(() {
                                //trigger a rebuild of the widget with the updated records
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: const Color.fromARGB(255, 138, 132, 132),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Family Member"),
                                    content: Text(
                                        "Are you sure you want to delete this family member?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); //close the dialog
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Perform the deletion
                                          await DBFamily.deleteFamilyMember(
                                              items[index]['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Family member deleted successfully!')));
                                          /*Fluttertoast.showToast(
                                              msg:
                                                  "Family member deleted successfully!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity
                                                  .BOTTOM, // This is to show toast at the center of the screen; you can change the gravity according to your needs
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.grey[300],
                                              textColor: Colors.black,
                                              fontSize: 15.0);*/
                                          Navigator.of(context).pop();
                                          _updateDoctorsList(); // Refresh the list
                                        },
                                        child: Text("Delete"),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return CircularProgressIndicator();
  }
}
