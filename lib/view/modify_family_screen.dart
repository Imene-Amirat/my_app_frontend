import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_app_frontend/databases/DBfamily.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ModifyFamilyScreen extends StatefulWidget {
  final int memberId;

  const ModifyFamilyScreen({super.key, required this.memberId});

  @override
  State<ModifyFamilyScreen> createState() => _ModifyFamilyScreenState();
}

class _ModifyFamilyScreenState extends State<ModifyFamilyScreen> {
  final _formKey = GlobalKey<FormState>(); //uniquely identifies the Form
  String name = '';
  String relation = '';
  late int selectedRelationId;
  List<Map<String, dynamic>> relations = [];
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fetchData();
    fetchFamilyMemberDetails();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> fetchFamilyMemberDetails() async {
    final memberDetails = await DBFamily.fetchFamilyMemberById(widget.memberId);
    if (memberDetails != null) {
      setState(() {
        nameController.text = memberDetails['name'];
        print(nameController.text);
        selectedRelationId = memberDetails['relation_id'];
        relation = relations.firstWhere(
            (rel) => rel['id'] == selectedRelationId,
            orElse: () => {"name": ""})['name'];
        print(relation);
      });
    }
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
          "Modify Family Member",
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
                  controller: nameController,
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
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Relation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  value:
                      selectedRelationId, // La valeur actuellement sélectionnée, qui doit être un int
                  items: relations
                      .map<DropdownMenuItem<int>>((Map<String, dynamic> value) {
                    return DropdownMenuItem<int>(
                      value: value[
                          'id'], // Utilisez l'ID de la relation comme valeur, doit être un int
                      child: Text(value['name']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    // Assurez-vous que le type correspond à celui des items
                    setState(() {
                      selectedRelationId =
                          newValue!; // Mettez à jour l'ID de relation sélectionné avec le nouvel ID
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a relation' : null,
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: GlobalColors.mainColor, // Text color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print(name + relation);
                      String? userId = await getUserId();
                      if (userId != null) {
                        await DBFamily.updateFamilyMember(
                          widget.memberId,
                          name,
                          selectedRelationId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Family member updated successfully!')));
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                  icon: Icon(Icons.done),
                  label: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
