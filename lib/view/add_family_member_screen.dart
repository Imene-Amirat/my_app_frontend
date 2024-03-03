import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBfamily.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>(); //uniquely identifies the Form
  String name = '';
  String relation = '';
  late int selectedRelationId;
  List<Map<String, dynamic>> relations = [];

  void initState() {
    super.initState();
    fetchData();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  Future<void> _addFamilyMember(String name) async {
    String? userId = await getUserId();
    print(selectedRelationId);
    /* await DBFamily.insertFamilyMember(name, selectedRelationId);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Family member added successfully!')));
    Navigator.of(context).pop(true);*/
    if (userId != null) {
      int newRecordId =
          await DBFamily.insertFamilyMember(name, selectedRelationId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Family member added successfully!')));
      print("Record Added Successfully:");
      print("ID: $newRecordId");
      print("Doctor ID: $name");
      print("Type Record ID: $selectedRelationId");
      print("Title: $userId");
      Navigator.of(context).pop(true);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Member",
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
      //the form can be scrolled preventing UI overflow when the keyboard is visible
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    //validate its input
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ??
                      '', // save its value  to a variable "name" called when FormState.save is invoked
                ),
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Relation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  value: relation.isEmpty
                      ? null
                      : relation, //ensure there's no initial value if relation is empty
                  items: relations.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> value) {
                    return DropdownMenuItem<String>(
                      child: Text(value['name']),
                      value: value['name'],
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      relation = newValue!;
                      selectedRelationId = relations.firstWhere(
                          (option) => option['name'] == newValue)['id'];
                      print(selectedRelationId);
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a relation' : null,
                  onSaved: (value) => relation = value.toString(),
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: GlobalColors.mainColor, // Button color
                    onPrimary: Colors.white, // Text color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                  //This runs all validator functions of the form fields.
                  //if all validators return null  is called  "_formKey.currentState!.save()"
                  //triggering all onSaved functions to save their values to the corresponding variables.
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print(name + relation);
                      _addFamilyMember(name);
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Member'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
